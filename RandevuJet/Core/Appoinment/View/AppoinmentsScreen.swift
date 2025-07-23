//
//  AppoinmentsScreen.swift
//  RandevuJet
//
//  Created by sude on 23.07.2025.
//

import Foundation

import SwiftUI
import Kingfisher

struct AppoinmentsScreen: View {
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    var body: some View {
        ScrollView {
            if hairdresserViewModel.appointments.isEmpty {
                EmptyList.appointments()
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(hairdresserViewModel.appointments) { appoinment in
                        NavigationLink(destination: AppoinmentDetailScreen(appoinment: appoinment)  ) {
                            AppoinmentCard(appoinment: appoinment)
                        }
                        .buttonStyle(PlainButtonStyle()) // underline veya mavi highlight olmasın diye
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await hairdresserViewModel.fetchHairdressers()
        }
    }
    
}


struct AppoinmentCard: View {
    let appoinment: Appointment
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 6) {
                Text(appoinment.salonName ?? "")
                    .font(.headline)
                
                Text(appoinment.appointmentDate ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(appoinment.appointmentTime ?? "")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}


#Preview {
    AppoinmentsScreen()
        .environmentObject(HairdresserViewModel())
}

