//
//  HomeScreen.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation

import SwiftUI

struct HomeScreen: View {

    @State private var showAll = false

    let sampleHairdressers = [
        HairDresser(
            id: UUID().uuidString,
            salonName: "Ayşe Yılmaz",
            email: "ayse@example.com",
            role: "Kuaför",
            address: "İstanbul",
            phone: "05551234567",
            photo: "logo",
            employeesNumber: 3,
            text: "Güzellik Merkezi"
        ),
        HairDresser(
            id: UUID().uuidString,
            salonName: "Mehmet Demir",
            email: "mehmet@example.com",
            role: "Kuaför",
            address: "Ankara",
            phone: "05559876543",
            photo: "logo",
            employeesNumber: 5,
            text: "Kuaför Dükkanı"
        ),
        HairDresser(
            id: UUID().uuidString,
            salonName: "Elif Kaya",
            email: "elif@example.com",
            role: "Kuaför",
            address: "İzmir",
            phone: "05553456789",
            photo: "logo",
            employeesNumber: 2,
            text: "Saç Stüdyosu"
        )
    ]



    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    Header()

                    HorizontalList(hairdressers: sampleHairdressers) {
                        showAll = true
                    }

                    // Diğer içerikler
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $showAll) {
                //AllHairdressersView(hairdressers: sampleHairdressers)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }
}



#Preview {
    HomeScreen()
}

