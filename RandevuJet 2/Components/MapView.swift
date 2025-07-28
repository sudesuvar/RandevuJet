//
//  MapView.swift
//  RandevuJet
//
//  Created by sude on 23.07.2025.
//

import Foundation

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    var address: String // Dışarıdan gelen adres
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9208, longitude: 32.8541),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var marker: Landmark? = nil
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $region, annotationItems: marker != nil ? [marker!] : []) { item in
                MapMarker(coordinate: item.coordinate, tint: .red)
            }
            .onAppear {
                getCoordinateFrom(address: address) { coordinate in
                    if let coordinate = coordinate {
                        self.region.center = coordinate
                        self.marker = Landmark(coordinate: coordinate)
                    }
                }
            }
        }
    }
}

struct Landmark: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// Geocoding fonksiyonu
func getCoordinateFrom(address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { placemarks, error in
        if let location = placemarks?.first?.location {
            completion(location.coordinate)
        } else {
            completion(nil)
        }
    }
}

#Preview {
    MapView(address: "Ereğli Mah Barbaros Hayrettin Paşa Sk Emiroğlu 2 apt., Kocaeli") // Buraya istediğin adresi verebilirsin
}
