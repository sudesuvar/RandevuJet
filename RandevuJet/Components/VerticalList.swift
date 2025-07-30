import Foundation
import SwiftUI

struct VerticalList: View {
    let appointments: [Appointment]
    @State private var isLoading = false
    var onShowAllTapped: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    @EnvironmentObject var appoinmentViewModel: AppoinmentViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Randevular")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                Button(action: {
                    onShowAllTapped()
                }) {
                    Text("Hepsini Göster")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .cyan : .blue)
                }
            }
            .padding(.horizontal)
            
            if hairdresserViewModel.appointmentsWithStatus.isEmpty {
                EmptyList.appointments()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(hairdresserViewModel.appointmentsWithStatus) { appointment in
                        NavigationLink(destination:
                                        AppoinmentDetailScreen(appoinment: appointment)
                            .environmentObject(authViewModel)
                            .environmentObject(themeViewModel)
                            .environmentObject(hairdresserViewModel)
                            .environmentObject(appoinmentViewModel)
                        ) {
                            AppoinmentCard(appoinment: appointment)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            Task{
                await hairdresserViewModel.fetchAppoinmentWithStatus()
            }
            
        }
    }
}

struct AppoinmentsRow: View {
    let appointment: Appointment
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.salonName)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .lineLimit(1)
                
                Text(appointment.serviceName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text("\(appointment.appointmentDate) • \(appointment.appointmentTime)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(12)
        .shadow(color: colorScheme == .dark ? .black.opacity(0.2) : .gray.opacity(0.1), radius: 4, x: 0, y: 2)
        
        
        
    }
    
}
struct AppoinmentCard: View {
    let appoinment: Appointment
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 6) {
                Text(appoinment.salonName )
                    .font(.headline)
                
                Text(appoinment.appointmentDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(appoinment.appointmentTime )
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                StatusBadge(status: appoinment.status)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

struct StatusBadge: View {
    let status: String
    @Environment(\.colorScheme) var colorScheme
    
    var statusColor: Color {
        switch status.lowercased() {
        case "confirmed", "onaylandi", "onaylandı":
            return .green
        case "pending", "bekliyor":
            return .orange
        case "cancelled", "canceled", "iptal":
            return .red
        case "completed", "tamamlandi", "tamamlandı":
            return .blue
        default:
            return .gray
        }
    }
    
    var statusText: String {
        switch status.lowercased() {
        case "confirmed", "onaylandi", "onaylandı":
            return "Onaylandı"
        case "pending", "bekliyor":
            return "Bekliyor"
        case "cancelled", "canceled", "iptal":
            return "İptal"
        case "completed", "tamamlandi", "tamamlandı":
            return "Tamamlandı"
        default:
            return status.capitalized
        }
    }
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(6)
    }
}

// Appointment status enum (optional - you can use this if you want to refactor your data model)
enum AppointmentStatus: String, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case completed = "completed"
}





