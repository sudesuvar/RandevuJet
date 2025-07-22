//
//  HomeScreen.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation

import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
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
        NavigationStack {
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
                .padding(.top) // opsiyonel
            }
            .background(Color(.systemGroupedBackground))
            .navigationDestination(isPresented: $showAll) {
                HairdressersScreen()
                    .environmentObject(authViewModel)
                    .environmentObject(themeViewModel)
                    .environmentObject(hairdresserViewModel)
            }
            .navigationBarHidden(true)
        }
    }
    
}




#Preview {
    HomeScreen()
        .environmentObject(HairdresserViewModel())
        .environmentObject(ThemeViewModel())
        .environmentObject(AuthViewModel())
}

