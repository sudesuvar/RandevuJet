//
//  AdminHomeScreen.swift
//  RandevuJet
//
//  Created by sude on 31.07.2025.
//

import Foundation
import SwiftUI

struct AdminHomeScreen: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedFilter: AppointmentStatusAdmin = .all
    @State private var searchText = ""
    
   
    
    // Filtrelenmiş randevular
    var filteredAppointments: [Appointment] {
        let statusFiltered = adminViewModel.appointments.filter { appointment in
            selectedFilter == .all || appointment.status == selectedFilter.rawValue
        }
        
        if searchText.isEmpty {
            return statusFiltered
        } else {
            return statusFiltered.filter { appointment in
                appointment.customerName.localizedCaseInsensitiveContains(searchText) ||
                appointment.serviceName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if adminViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                searchBarView()
                filterChipsViewAdmin()
                
                if adminViewModel.appointments.isEmpty {
                    emptyListView()
                } else {
                    appointmentListView()
                }
            }
        }
        .onAppear {
            Task {
                await adminViewModel.loadInitialData()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Alt Görünümler Fonksiyonları
    
    @ViewBuilder
    private func searchBarView() -> some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Müşteri adı veya hizmet ara...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .disableAutocorrection(true)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, 0)
    }
    
    @ViewBuilder
    private func filterChipsViewAdmin() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AppointmentStatusAdmin.allCases, id: \.self) { status in
                    FilterChipAdmin(
                        title: status.displayName,
                        isSelected: selectedFilter == status,
                        count: status == .all ? adminViewModel.appointments.count : adminViewModel.appointments.filter { $0.status == status.rawValue }.count
                    ) {
                        selectedFilter = status
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }
    
    @ViewBuilder
        private func appointmentListView() -> some View {
            List {
                if filteredAppointments.isEmpty {
                    emptyListView()
                        .listRowSeparator(.hidden)
                } else {
                    ForEach(filteredAppointments) { appointment in
                        ZStack {
                            NavigationLink(destination: AdminAppointmentScreen(appointment: appointment).environmentObject(AdminViewModel())
                                .environmentObject(AuthViewModel())) {
                                EmptyView()
                            }
                            .opacity(0)
                            
                            AppointmentRowView(appointment: appointment) { updatedAppointment in
                                if let index = adminViewModel.appointments.firstIndex(where: { $0.id == updatedAppointment.id }) {
                                    adminViewModel.appointments[index] = updatedAppointment
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                }
            }
            .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .padding(.top, 0)
        }
    
    @ViewBuilder
    private func emptyListView() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("Randevu bulunamadı")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Seçilen filtre için randevu bulunmamaktadır.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
}


struct AppointmentRowView: View {
    var appointment: Appointment
    var onStatusUpdate: (Appointment) -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.customerName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(appointment.serviceName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack(spacing: 12) {
                        Label(formatDate(appointment.appointmentDate), systemImage: "calendar")
                        Label(appointment.appointmentTime, systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "phone")
                        Text(appointment.customerTel)
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    if let status = AppointmentStatusAdmin(rawValue: appointment.status) {
                        StatusBadgeAdmin(status: status)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1))
        .contentShape(Rectangle()) // NavigationLink için tıklanabilir alan
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Bugün" }
        else if calendar.isDateInTomorrow(date) { return "Yarın" }
        else if calendar.isDateInYesterday(date) { return "Dün" }
        else {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy"
            return outputFormatter.string(from: date)
        }
    }
}

struct StatusBadgeAdmin: View {
    let status: AppointmentStatusAdmin
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(status.color.opacity(0.2)))
            .foregroundColor(status.color)
    }
}

struct FilterChipAdmin: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title).font(.subheadline).fontWeight(.medium)
                Text("\(count)").font(.caption).fontWeight(.semibold).padding(.horizontal, 6).padding(.vertical, 2).background(Capsule().fill(isSelected ? Color.white.opacity(0.3) : Color.secondary.opacity(0.2)))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(isSelected ? Color.blue : Color(.secondarySystemBackground)))
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

enum AppointmentStatusAdmin: String, CaseIterable {
    case all = "all"
    case pending = "pending"
    case confirmed = "confirmed"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .all: return "Tümü"
        case .pending: return "Onay Bekleyen"
        case .confirmed: return "Onaylanan"
        case .completed: return "Tamamlanan"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .blue
        case .pending: return .orange
        case .confirmed: return .green
        case .completed: return .purple
        }
    }
}

func isTodayAppointment(_ dateString: String) -> Bool {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let appointmentDate = formatter.date(from: dateString) else { return false }
    return Calendar.current.isDateInToday(appointmentDate)
}

struct StatsCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .padding()
                .background(color)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(count)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    AdminHomeScreen()
}
