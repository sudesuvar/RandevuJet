//
//  HomeScreen.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    @State private var showAll = false
    
    let myAppointments = [
        Appointment(
            id: UUID().uuidString,
            customerName: "Ali Veli",
            hairdresserName: "Prenses Güzellik Merkezi",
            serviceName: "Saç Kesimi",
            date: "20 Temmuz 2025",
            time: "14:00",
            photo: "logo",
            status: "active",
            createdAt: Date()
        ),
        Appointment(
            id: UUID().uuidString,
            customerName: "Fatma Kaya",
            hairdresserName: "Elif Kaya Saç Stüdyosu",
            serviceName: "Saç Boyama",
            date: "22 Temmuz 2025",
            time: "10:30",
            photo: "logo",
            status: "active",
            createdAt: Date()
        )
    ]
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        Header()
                        
                        HorizontalList(hairdressers: hairdresserViewModel.hairdressers) {
                            showAll = true
                        }
                        
                        VerticalList(
                            appointments: myAppointments,
                            titleProvider: { $0.hairdresserName },
                            subtitleProvider: { $0.serviceName },
                            detailProvider: { "\($0.date) • \($0.time)" },
                            imageProvider: { $0.photo }
                        )
                        
                    }
                }
                .background(Color(.systemGroupedBackground))
                //.navigationDestination(isPresented: $showAll) {
                  //  HairdressersScreen()
                //}
                NavigationLink(destination: HairdressersScreen(), isActive: $showAll) {
                                    EmptyView()
                                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color(.systemGroupedBackground))
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGroupedBackground))
    }
}



#Preview {
    HomeScreen()
        .environmentObject(HairdresserViewModel())
}

