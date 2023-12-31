//
//  ProfileView.swift
//  ArcGIS-Test
//
//  Created by Ryan Potter on 10/05/23.

import SwiftUI
import MapKit

struct ProfileView: View {
    let user: User
    @State private var showEditProfile = false
    @ObservedObject var locationManager = LocationManager()
    @State private var trackViewMap = MKMapView()
    @State private var trackHistoryViewMap = MKMapView()
    @State private var tracking = false
    @State private var historyMap = false
    @State private var showAlert = false
    @State private var selectedTrackFile: String?
    @State var isDarkMode = false
    @Environment(\.colorScheme) var colorScheme
    @State var showDeleteConfirmation = false
    @State private var fileToDelete: String?
    @State private var showTrackHistoryList = false
    @Binding var isMetric: Bool
    
    init(user: User, isMetric: Binding<Bool>) {
        self.user = user
        self._isMetric = isMetric
    }
    
    var body: some View {
        VStack{
            VStack {
                Text("SnowCountry")
                    .font(Font.custom("Good Times", size:30))
                NavigationView {
                    
                    
                    List {
                        ZStack(alignment: .leading) {
                            // banner image, style is stored in components
                            BannerImage(user: user)
                            
                            // profile image, style is stored in components
                            ProfileImage(user: user, size: ProfileImageSize.large)
                                .offset(x:70, y: 70)
                            
                            // username
                            HStack() {
                                Text(user.username)
                                    .font(.system(size: 25))
                                    .fontWeight(.semibold)
                                    .offset(x:70, y: 170)
                            }
                            
                            // DARK MODE BUTTON
                            HStack(){
                                Button(action: {
                                    isDarkMode.toggle()
                                }) {
                                    Image(systemName: isDarkMode ? "moon.fill" : "moon")
                                        .resizable()
                                        .frame(width: 30, height: 30, alignment: .trailing)
                                        .foregroundColor(isDarkMode ? .blue : .blue)
                                        .clipped().buttonStyle(BorderlessButtonStyle())
                                        .fixedSize()
                                        .padding(.leading, 50)
                                }
                                .buttonStyle(ClippedButtonStyle())
                                .offset(x: 185, y: 217)
                            }
                            
                            // EDIT PROFILE BUTTON
                            VStack(alignment: .leading) {
                                Button(action: {
                                    showEditProfile.toggle()
                                }) {
                                    HStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.5))
                                            .frame(width: 150, height: 50)
                                            .cornerRadius(8)
                                            .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
                                            .overlay(
                                                Text("Edit Profile")
                                                    .font(.system(size: 15))
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color.black)
                                            )
                                    }
                                    .frame(width: 100, height: 60)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .offset(x: 80, y: 217)
                            .padding()
                        }
                        .padding(.top, -12)
                        .padding(.bottom, 150)
                        
                        Section(header: Text("Run History")) {
                            Button("View Track History") {
                                showTrackHistoryList = true
                            }
                            .padding()
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(10)
                        }
                        .sheet(isPresented: $showTrackHistoryList) {
                            TrackHistoryListView(locationManager: locationManager, isMetric: $isMetric)
                        }
                        
                        Section(header: Text("Settings")) {
                            Toggle(isOn: $isMetric) {
                                HStack {
                                    Text("Units: ")
                                    Text(isMetric ? "Metric" : "Imperial")
                                }
                            }
                            Button(action: {
                                showAlert = true
                            }) {
                                Text("Logout")
                                    .accentColor(.red)
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Log Out"),
                                    message: Text("Are you sure you want to log out?"),
                                    primaryButton: .default(Text("Cancel")),
                                    secondaryButton: .destructive(Text("Log Out"), action: {
                                        // Perform logout action here
                                        AuthService.shared.signOut()
                                    })
                                )
                            }
                        }
                        
                    }
                    
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    
                    
                    
                    
                    
                    .fullScreenCover(isPresented: $showEditProfile) {
                        EditProfileView(user: user)
                    }
                }
                
                
                .padding(.leading, -20)
                .padding(.trailing, -20)
                .onAppear {
                    self.isDarkMode = self.colorScheme == .dark
                }
            }
        }
        .background(Color("Background").opacity(0.5))
    }
}

// added this function so the buttons can only be pressed within their shape
struct ClippedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
    }
}

extension LocationManager {
    func deleteTrackFile(named fileName: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Deleted file:", fileName)
        } catch {
            print("Could not delete file: \(error)")
        }
    }
}

extension Color {
    static let systemBackground = Color("Background")
}
