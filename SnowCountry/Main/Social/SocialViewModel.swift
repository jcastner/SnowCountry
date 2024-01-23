import SwiftUI
import Foundation
import FirebaseFirestore

@MainActor
class SocialViewModel: ObservableObject {
    @Published var user: User
    @Published var users = [User]()
    @Published var invites: [User]? = nil
    @Published var posts = [Post]()
    @Published var friends: [User]? = nil
    
    init(user: User) {
        self.user = user

        Task {
            try await fetchPosts()
            try await fetchAllUsers()
            try await fetchInvites()
            try await fetchFriends()
        }
    }
    
    @MainActor
    func fetchPosts() async throws {
        self.posts = try await PostService.fetchAllPosts()
    }
    
    @MainActor
    func fetchAllUsers() async throws {
        self.users = try await UserService.fetchAllUsers()
    }
    
    @MainActor
    func fetchInvites() async throws {
        // Could user a mapping here probably but im hungry and I couldn't figure out the correct optional unwrapping
        if let invites = user.friendInvites {
            var tmpInvites = [User]()
            for invite in invites {
                try await tmpInvites.append(UserService.fetchUser(withUID: invite))
            }
            self.invites = tmpInvites
        }
    }
    
    func fetchInvitesCount() async throws -> Int {
        // Check if there are friend invites
        guard let invites = user.friendInvites else {
            return 0 // No invites
        }
        
        return invites.count // Return the count of invites
    }

    
    // TODO: Make a function for uploading the data arry to firebase... Lots of reused code here
    
    // Add friend should add the focused users id to the current users "pending" array
    // And the current users id to the focused users invite array
    func sendFriendInvite(focusedUser: User) async throws {
        // Array could be empty here so use a data dict
        var data = [String: Any]()
        
        // Updates user object locally
        if var userFriendsPending = user.pendingFriends {
            userFriendsPending.append(focusedUser.id)
            data["pendingFriends"] = userFriendsPending
            user.pendingFriends = userFriendsPending
        } else {
            data["pendingFriends"] = [focusedUser.id]
            user.pendingFriends = [focusedUser.id]
        }
        
        try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        
        // Don't need to update the focused user object locally
        // but we should clear the data bc we need to switch documents
        data.removeAll()
        
        // This is more complicated than I thought
        // Need to grab the list of the focused user friend invites see if it exists and append to that
        if var focusedUserFriendInvites = focusedUser.friendInvites {
            focusedUserFriendInvites.append(user.id)
            data["friendInvites"] = focusedUserFriendInvites
            // Don't need to update locally
        } else {
            data["friendInvites"] = [user.id]
        }
        
        try await Firestore.firestore().collection("users").document(focusedUser.id).updateData(data)
        
        // Update the user object just in case
        let _ = try await AuthService.shared.loadUserData()
    }
    
    func hasSentFriendInvite(to focusedUser: User) -> Bool {
        // Check if the user's pendingFriends list contains the focused user's ID
        if let userFriendsPending = user.pendingFriends, userFriendsPending.contains(focusedUser.id) {
            return true // Invite has already been sent
        }
        return false // Invite has not been sent
    }
    
    func confirmFriendInvite(focusedUser: User) async throws {
        var data = [String: Any]()

        // Remove pending invite from focused user
        if let pendingFriends = focusedUser.pendingFriends, let friendInvites = user.friendInvites {
            data["pendingFriends"] = pendingFriends.filter { $0 != user.id }
            if var friends = focusedUser.friends {
                friends.append(user.id)
                data["friends"] = friends // Add current user id to focused user friend list and the opposite
            } else {
                data["friends"] = [user.id]
            }
            try await Firestore.firestore().collection("users").document(focusedUser.id).updateData(data)
            
            data.removeAll()
            
            // Remove friend invite from current user
            let tmpFriendInvites = friendInvites.filter { $0 != focusedUser.id }
            data["friendInvites"] = tmpFriendInvites
            user.friendInvites = tmpFriendInvites
            Task { try await fetchInvites() }
            
            if var friends = user.friends {
                friends.append(focusedUser.id)
                user.friends = friends
                data["friends"] = friends // Add current user id to focused user friend list and the opposite
            } else {
                user.friends = [focusedUser.id]
                data["friends"] = [focusedUser.id]
            }
            
            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        }
        
        let _ = try await AuthService.shared.loadUserData()
    }
    
    func declineFriendInvite(inviteId: String) async throws {
        guard var invites = user.friendInvites else { return }

        // Remove the invite from the current user's friendInvites
        invites.removeAll { $0 == inviteId }
        user.friendInvites = invites

        // Update the current user's friendInvites in Firestore
        try await Firestore.firestore().collection("users").document(user.id).updateData(["friendInvites": invites])

        // Fetch the user who sent the invite to update their pendingFriends
        let focusedUser = try await UserService.fetchUser(withUID: inviteId)
        if var focusedUserPendingFriends = focusedUser.pendingFriends {
            focusedUserPendingFriends.removeAll { $0 == user.id }
            
            // Update the focused user's pendingFriends in Firestore
            try await Firestore.firestore().collection("users").document(focusedUser.id).updateData(["pendingFriends": focusedUserPendingFriends])
        }
        
        // Refresh the invites list
        Task { try await fetchInvites() }
    }
    
    func cancelFriendInvite(focusedUser: User) async throws {
        // Check if there is a pending friend invite to cancel
        guard var userPendingFriends = user.pendingFriends else {
            // No pending friend invite, nothing to cancel
            return
        }
        
        let focusedUserId = focusedUser.id

        // Remove the focused user's ID from the current user's pendingFriends array
        userPendingFriends.removeAll { $0 == focusedUserId }
        
        // Update the current user's pendingFriends in Firestore
        try await Firestore.firestore().collection("users").document(user.id).updateData(["pendingFriends": userPendingFriends])
        
        // Remove the current user's ID from the focused user's friendInvites array
        if var focusedUserFriendInvites = focusedUser.friendInvites {
            focusedUserFriendInvites.removeAll { $0 == user.id }
            
            // Update the focused user's friendInvites in Firestore
            try await Firestore.firestore().collection("users").document(focusedUserId).updateData(["friendInvites": focusedUserFriendInvites])
        }
        
        // Refresh the pendingFriends list for the current user
        user.pendingFriends = userPendingFriends
    }
    
    func removeFriend(focusedUser: User) async throws {
        // Check if the current user has any friends
        guard var userFriends = user.friends else {
            // Current user has no friends, nothing to remove
            return
        }
        
        let focusedUserId = focusedUser.id

        // Remove the focused user's ID from the current user's friends array
        userFriends.removeAll { $0 == focusedUserId }
        
        // Update the current user's friends in Firestore
        try await Firestore.firestore().collection("users").document(user.id).updateData(["friends": userFriends])
        
        // Remove the current user's ID from the focused user's friends array
        if var focusedUserFriends = focusedUser.friends {
            focusedUserFriends.removeAll { $0 == user.id }
            
            // Update the focused user's friends in Firestore
            try await Firestore.firestore().collection("users").document(focusedUserId).updateData(["friends": focusedUserFriends])
        }
        
        // Refresh the friends list for the current user
        user.friends = userFriends
    }
    
    func fetchFriends() async throws {
        if let friends = user.friends {
            var friendArr = [User]()
            for friend in friends {
                var friendUser = try await UserService.fetchUser(withUID: friend)
                friendArr.append(friendUser)
            }
            self.friends = friendArr
        }
    }
    
    func fetchFriendsCount() async throws -> Int {
        var friendArr = [User]()
        if let friends = user.friends {
            for friend in friends {
                let friendUser = try await UserService.fetchUser(withUID: friend)
                friendArr.append(friendUser)
            }
        }
        return friendArr.count
    }
    
    func likePost(uid: String) async throws {
        var data = [String: Any]()
        
        if let index = self.posts.firstIndex(where: { $0.id == uid }) {
            self.posts[index].likes += 1
            Task { try await PostService.addLike(toPost: uid) }
            
            if var likedPosts = user.likedPosts {
                likedPosts.append(uid)
                user.likedPosts = likedPosts
                data["likedPosts"]  = likedPosts
            } else {
                user.likedPosts = [uid]
                data["likedPosts"] = [uid]
            }
                        
            try await Firestore.firestore().collection("users").document(user.id).updateData(data)
        }
    }
    
    func unLikePost(uid: String) async throws {
        // TODO: Need to update firebase
        var data = [String: Any]()
        
        if let index = self.posts.firstIndex(where: { $0.id == uid }) {
            self.posts[index].likes -= 1
            Task { try await PostService.removeLike(toPost: uid) }
            
            if let likedPosts = user.likedPosts {
                user.likedPosts = likedPosts.filter{ $0 != uid }
                data["likedPosts"] = user.likedPosts
                try await Firestore.firestore().collection("users").document(user.id).updateData(data)
            }
        }
    }
    
    // Check if the current user is following another user
    func isFollowing(friend: User) -> Bool {
        let friendId = friend.id
        return user.friends?.contains(friendId) ?? false
    }
}
