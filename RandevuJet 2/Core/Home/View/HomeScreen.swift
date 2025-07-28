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
    @State private var showAllAppointments = false
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Header()
                
                if isLoading {
                    ProgressView()
                } else {
                    HorizontalList(hairdressers: hairdresserViewModel.hairdressers) {
                        showAll = true
                    }
                    VerticalList(appointments: hairdresserViewModel.appointments){
                        showAllAppointments = true
                    }
                }
            }
            .task {
                isLoading = true
                await hairdresserViewModel.fetchHairdressers()
                await hairdresserViewModel.fetchAppointments()
                isLoading = false
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
        .navigationDestination(isPresented: $showAll) {
            HairdressersScreen()
                .environmentObject(authViewModel)
                .environmentObject(themeViewModel)
                .environmentObject(hairdresserViewModel)
        }
        .navigationDestination(isPresented: $showAllAppointments) {
            AppoinmentsScreen()
                .environmentObject(authViewModel)
                .environmentObject(themeViewModel)
                .environmentObject(hairdresserViewModel)
        }
        .navigationBarHidden(true)
    }
}






#Preview {
    HomeScreen()
        .environmentObject(HairdresserViewModel())
        .environmentObject(ThemeViewModel())
        .environmentObject(AuthViewModel())
}

