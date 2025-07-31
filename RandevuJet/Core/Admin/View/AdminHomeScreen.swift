//
//  AdminHomeScreen.swift
//  RandevuJet
//
//  Created by sude on 31.07.2025.
//

//
//  AdminHomeScreen.swift
//  RandevuJet
//
//  Created by sude on 31.07.2025.
//

import Foundation
import SwiftUI


struct AdminHomeScreen: View {
    @State private var selectedFilter: AppointmentStatusAdmin = .all
    @State private var searchText = ""

    @State private var appointments = [
        Appointment(id: "1", customerName: "Ayşe Yılmaz", customerTel: "+90 555 123 4567", salonName: "Salon Güzellik", serviceName: "Saç Kesimi + Fön", appointmentDate: "2025-07-31", appointmentTime: "10:00", status: "pending"),
        Appointment(id: "2", customerName: "Mehmet Demir", customerTel: "+90 555 987 6543", salonName: "Salon Güzellik", serviceName: "Saç Boyama", appointmentDate: "2025-07-31", appointmentTime: "14:30", status: "confirmed"),
        Appointment(id: "3", customerName: "Fatma Özkan", customerTel: "+90 555 456 7890", salonName: "Salon Güzellik", serviceName: "Keratin Bakım", appointmentDate: "2025-08-01", appointmentTime: "11:00", status: "confirmed"),
        Appointment(id: "4", customerName: "Ali Kaya", customerTel: "+90 555 321 6547", salonName: "Salon Güzellik", serviceName: "Saç Kesimi", appointmentDate: "2025-07-30", appointmentTime: "16:00", status: "completed"),
        Appointment(id: "5", customerName: "Zeynep Ak", customerTel: "+90 555 789 1234", salonName: "Salon Güzellik", serviceName: "Ombre Boyama", appointmentDate: "2025-07-29", appointmentTime: "13:00", status: "completed"),
        Appointment(id: "6", customerName: "Can Öztürk", customerTel: "+90 555 654 3210", salonName: "Salon Güzellik", serviceName: "Saç + Sakal", appointmentDate: "2025-07-31", appointmentTime: "18:00", status: "pending")
    ]

    var filteredAppointments: [Appointment] {
        let statusFiltered = appointments.filter { appointment in
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
                //statsCardsView
                searchBarView
                filterChipsViewAdmin
                appointmentListView
            }
        
    }

    private var statsCardsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                StatsCard(title: "Bugün", count: appointments.filter { isTodayAppointment($0.appointmentDate) }.count, icon: "calendar.circle.fill", color: .blue)
                StatsCard(title: "Onay Bekleyen", count: appointments.filter { $0.status == "pending" }.count, icon: "clock.circle.fill", color: .orange)
                StatsCard(title: "Onaylanan", count: appointments.filter { $0.status == "confirmed" }.count, icon: "checkmark.circle.fill", color: .green)
                StatsCard(title: "Tamamlanan", count: appointments.filter { $0.status == "completed" }.count, icon: "star.circle.fill", color: .purple)
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }

    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Müşteri adı veya hizmet ara...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .padding(.horizontal)
        .padding(.bottom)
    }

    private var filterChipsViewAdmin: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AppointmentStatusAdmin.allCases, id: \.self) { status in
                    FilterChipAdmin(
                        title: status.displayName,
                        isSelected: selectedFilter == status,
                        count: status == .all ? appointments.count : appointments.filter { $0.status == status.rawValue }.count
                    ) {
                        selectedFilter = status
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.bottom)
    }

    private var appointmentListView: some View {
        List {
            if filteredAppointments.isEmpty {
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
                .listRowSeparator(.hidden)
            } else {
                ForEach(filteredAppointments) { appointment in
                    AppointmentRowView(appointment: appointment) { updatedAppointment in
                        if let index = appointments.firstIndex(where: { $0.id == updatedAppointment.id }) {
                            appointments[index] = updatedAppointment
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct AppointmentRowView: View {
    var appointment: Appointment
    var onStatusUpdate: (Appointment) -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.customerName).font(.headline).fontWeight(.semibold)
                    Text(appointment.serviceName).font(.subheadline).foregroundColor(.secondary)
                    HStack(spacing: 12) {
                        Label(formatDate(appointment.appointmentDate), systemImage: "calendar")
                        Label(appointment.appointmentTime, systemImage: "clock")
                    }.font(.caption).foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "phone")
                        Text(appointment.customerTel)
                    }.font(.caption2).foregroundColor(.secondary)
                }
                Spacer()
                if let status = AppointmentStatusAdmin(rawValue: appointment.status) {
                    StatusBadgeAdmin(status: status)
                }
            }

            if appointment.status == "pending" {
                HStack(spacing: 12) {
                    Button("Reddet") {
                        // İşlevsel olarak güncelleme yapılabilir
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.1)))

                    Button("Onayla") {
                        var updated = appointment
                        updated = Appointment(id: updated.id, customerName: updated.customerName, customerTel: updated.customerTel, salonName: updated.salonName, serviceName: updated.serviceName, appointmentDate: updated.appointmentDate, appointmentTime: updated.appointmentTime, status: "confirmed")
                        onStatusUpdate(updated)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.green))
                }
            }

            if appointment.status == "confirmed" {
                Button("Tamamlandı Olarak İşaretle") {
                    var updated = appointment
                    updated = Appointment(id: updated.id, customerName: updated.customerName, customerTel: updated.customerTel, salonName: updated.salonName, serviceName: updated.serviceName, appointmentDate: updated.appointmentDate, appointmentTime: updated.appointmentTime, status: "completed")
                    onStatusUpdate(updated)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.purple))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1))
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
