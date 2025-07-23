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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Randevularım")
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
            
            if(appointments.isEmpty){
                EmptyList.appointments()
            }else{
                
                LazyVStack(spacing: 8) {
                    ForEach(appointments) { appointment in
                        NavigationLink(destination:
                                        AppoinmentDetailScreen(appoinment: appointment)
                            .environmentObject(authViewModel)
                            .environmentObject(themeViewModel)
                            .environmentObject(hairdresserViewModel)
                        ) {
                            AppoinmentCard(appoinment: appointment)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
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



