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
    @EnvironmentObject var appoinmentViewModel: AppoinmentViewModel
    @State private var searchText: String = ""
    @State private var isSearchActive: Bool = false
    @State private var selectedFilter: String = "Tümü"


    
    
    var filteredAppointments: [Appointment] {
        hairdresserViewModel.appointments.filter { app in
            let matchesSearch = searchText.isEmpty || app.salonName.lowercased().contains(searchText.lowercased())  //(app.address?.lowercased().contains(searchText.lowercased()) ?? false)
            let matchesFilter = selectedFilter == "Tümü" || app.status.lowercased().contains(selectedFilter.lowercased())
            return matchesSearch && matchesFilter
        }
    }
    
    let filters = ["Tümü", "Onaylandı", "Beklemede", "İptal", "Tamamlandı"]
    
    
    
    var body: some View {
            VStack(spacing: 8) {
                // 🔍 Custom SearchBar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 18))
                    
                    TextField("Salon ara...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onTapGesture {
                            isSearchActive = true
                        }

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            isSearchActive = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)

                // 🔹 Filtre Chip’leri
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { filter in
                            FilterChip(title: filter, isSelected: selectedFilter == filter) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // 🔹 Randevu Listesi
                ScrollView {
                    if filteredAppointments.isEmpty {
                        EmptyList.appointments()
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredAppointments) { appoinment in
                                NavigationLink(destination: AppoinmentDetailScreen(appoinment: appoinment)
                                    .environmentObject(hairdresserViewModel)
                                    .environmentObject(appoinmentViewModel)
                                ) {
                                    AppoinmentListCard(appoinment: appoinment)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .navigationTitle("Randevular")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await hairdresserViewModel.fetchHairdressers()
            }
        }
    
}


struct AppoinmentListCard: View {
    let appoinment: Appointment
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Left Side - Status Indicator & Icon
            VStack(spacing: 8) {
                // Status Circle
                Circle()
                    .fill(getStatusColor())
                    .frame(width: 12, height: 12)
                
                // Calendar Icon
                /*ZStack {
                 RoundedRectangle(cornerRadius: 8)
                 .fill(getStatusColor().opacity(0.1))
                 .frame(width: 50, height: 50)
                 
                 Image(systemName: "calendar")
                 .foregroundColor(getStatusColor())
                 .font(.system(size: 20, weight: .medium))
                 }*/
            }
            
            // Main Content
            VStack(alignment: .leading, spacing: 8) {
                // Header Row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(appoinment.salonName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(appoinment.serviceName)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                }
                
                // Date & Time Row
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(appoinment.appointmentDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(appoinment.appointmentTime)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Customer Info Row
                HStack(spacing: 6) {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(appoinment.customerName)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(getStatusColor().opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 12)
    }
    
    // Helper functions for status
    private func getStatusColor() -> Color {
        switch appoinment.status.lowercased() {
        case "onaylandı", "confirmed", "onay":
            return .green
        case "beklemede", "pending", "bekliyor":
            return .orange
        case "iptal", "cancelled", "canceled":
            return .red
        case "tamamlandı", "completed", "bitti":
            return .blue
        default:
            return .gray
        }
    }
    
}

#Preview {
    AppoinmentsScreen()
        .environmentObject(HairdresserViewModel())
        .environmentObject(AppoinmentViewModel())
}

