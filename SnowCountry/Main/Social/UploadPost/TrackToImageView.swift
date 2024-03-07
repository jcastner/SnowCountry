//
//  TrackToImageView.swift
//  SnowCountry
//
//  Created by Ryan Potter on 3/6/24.
//

import SwiftUI
import MapKit

enum MapStyle: String, CaseIterable {
    case normal = "Normal"
    case dark = "Dark"
    case satellite = "Satellite"
    case threeD = "3D"
}

struct TrackToImageView: View {
    var trackURL: URL
    var trackName: String // Assuming you want to display or use the track name directly
    var trackDate: String
    @State private var contourLines: Bool = false
    @State private var selectedMapStyle: MapStyle = .normal
    @State private var mapPosition: CGPoint = .zero // This would be used if you implement a draggable map
    @Environment(\.presentationMode) var presentationmode
    // Assuming you have these properties to pass to TrackHistoryViewMap
   @State private var trackHistoryViewMap: MKMapView = MKMapView()
   @State private var locations: [CLLocation] = []
    
    var backButton: some View {
        Button {
            presentationmode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "arrow.left")
                .foregroundColor(.cyan)
                .imageScale(.large)
                .padding(.trailing, 8)
        }
    }
    
    var nextButton: some View {
        Button {
            Task {
            }
        } label: {
            Text("Next")
                .foregroundColor(.cyan)
                .padding(.trailing, 8)
        }
    }

    var body: some View {
        VStack {
            
            Text(trackName)
                .padding()

            // This would be your map view, possibly using MapKit
            // Placeholder for the map
            TrackHistoryViewMap(trackHistoryViewMap: $trackHistoryViewMap, locations: locations)
                .frame(height: 300)
                .cornerRadius(15)
                .padding()
            
            Toggle(isOn: $contourLines) {
                Text("Contour Lines")
            }
            
            // Map style selection view
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(MapStyle.allCases, id: \.self) { style in
                        MapStyleView(style: style, isSelected: selectedMapStyle == style)
                            .onTapGesture {
                                selectedMapStyle = style
                                // Update the map style accordingly
                            }
                    }
                }
            }

            Spacer()
        }
        .padding(10)
        .navigationTitle("Upload Post")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton,
                            trailing: nextButton)
        .onAppear {
            self.loadTrackData()
        }
    }
    private func loadTrackData() {
        // Replicate the loading logic from StatView here, adjusting as necessary
        // For example, assuming you have a method to parse GPX or JSON data:
        let fileType = trackURL.pathExtension
        if fileType == "gpx" {
            // Load and parse GPX data
            let gpxData = try? Data(contentsOf: trackURL)
            let gpxString = String(data: gpxData!, encoding: .utf8) ?? ""
            self.locations = GPXParser.parseGPX(gpxString)
        }
    }
}

struct MapStyleView: View {
    let style: MapStyle
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(isSelected ? .blue : .white)
                .opacity(isSelected ? 0.3 : 1)
                .frame(width: 100, height: 100)
                .border(Color.black, width: isSelected ? 3 : 1)
            Text(style.rawValue)
        }
    }
}

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}
