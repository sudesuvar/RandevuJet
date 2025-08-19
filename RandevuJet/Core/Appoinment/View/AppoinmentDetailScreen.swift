//
//  AppoinmentDetailScreen.swift
//  RandevuJet
//
//  Created by sude on 23.07.2025.
//

import Foundation
import SwiftUI
import Kingfisher

struct AppoinmentDetailScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var AppoinmentViewModel: AppoinmentViewModel
    let appoinment: Appointment
    @State private var commentText = ""
    @State private var showCancelAlert = false
    @State private var showEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // Main Content
                VStack(spacing: 20) {
                    // Appointment Info Card
                    VStack(alignment: .leading, spacing: 16) {
                        // Customer Info Section
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(LocalizedStringKey("customer_info"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(appoinment.customerName)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                
                                Text(appoinment.customerTel)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Date & Time Section
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Tarih & Saat")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(appoinment.appointmentDate)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                
                                Text(appoinment.appointmentTime)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Salon Section
                        HStack {
                            Image(systemName: "building.2.fill")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Salon")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(appoinment.salonName)
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Service Section
                        HStack {
                            Image(systemName: "scissors")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(LocalizedStringKey("service"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(appoinment.serviceName)
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Status Section
                        HStack {
                            Image(systemName: getStatusIcon())
                                .foregroundColor(getStatusColor())
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(LocalizedStringKey("status"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(getStatusText())
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundColor(getStatusColor())
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                    )
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        // Edit Button
                        Button(action: {
                            showEditSheet = true
                            
                        }) {
                            HStack {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text(LocalizedStringKey("update_appointment"))
                                
                                
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [Color.yellow, Color.yellow.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(appoinment.status.lowercased() == "iptal" || appoinment.status.lowercased() == "cancelled")
                        
                        // Cancel Button
                        Button(action: {
                            showCancelAlert = true
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text(LocalizedStringKey("cancel_appointment"))
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(appoinment.status.lowercased() == "iptal" || appoinment.status.lowercased() == "cancelled" ? .gray : .red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(appoinment.status.lowercased() == "iptal" || appoinment.status.lowercased() == "cancelled" ? Color.gray : Color.red, lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill((appoinment.status.lowercased() == "iptal" || appoinment.status.lowercased() == "cancelled" ? Color.gray : Color.red).opacity(0.05))
                                    )
                            )
                        }
                        .disabled(appoinment.status.lowercased() == "iptal" || appoinment.status.lowercased() == "cancelled")
                        
                        // Call Customer Button
                        Button(action: {
                            if let url = URL(string: "tel://\(appoinment.customerTel)"),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else {
                                print("Telefon araması desteklenmiyor.")
                            }
                            
                        }) {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text(LocalizedStringKey("call_hairdresser"))
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green, lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green.opacity(0.05))
                                    )
                            )
                        }
                    }
                    .padding(.top, 10)
                    
                    // Yorum Yapma Alanı (Sadece tamamlanmışsa)
                    if appoinment.status.lowercased() == "tamamlandı" || appoinment.status.lowercased() == "completed" || appoinment.status.lowercased() == "bitti" {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedStringKey("write_review"))
                                .font(.headline)
                            TextEditor(text: $commentText)
                                .frame(height: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            Button(action: {
                                Task {
                                    await AppoinmentViewModel.submitReview(appointmentId: appoinment.id ?? "", review: commentText )
                                    commentText = ""
                                }
                            }) {
                                Text(LocalizedStringKey("send"))
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(commentText.trimmingCharacters(in: .whitespaces).isEmpty)
                            
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                        )
                        .padding(.top, 20)
                    }
                    
                    
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(LocalizedStringKey("cancel_appointment"), isPresented: $showCancelAlert) {
            Button(LocalizedStringKey("cancel"), role: .cancel) { }
            Button(LocalizedStringKey("confirm_cancel"), role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(LocalizedStringKey("cancel_appointment_message"))
        }
        .sheet(isPresented: $showEditSheet) {
            NavigationView {
                EditAppointmentView(appointment: appoinment, appointmentViewModel: AppoinmentViewModel)
                    .navigationTitle("Randevu Düzenle")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("İptal") {
                                showEditSheet = false
                            }
                        }
                    }
            }
        }
    }
    
    // Helper functions for status
    private func getStatusIcon() -> String {
        switch appoinment.status.lowercased() {
        case "onaylandı", "confirmed", "onay":
            return "checkmark.circle.fill"
        case "beklemede", "pending", "bekliyor":
            return "clock.fill"
        case "iptal", "cancelled", "canceled":
            return "xmark.circle.fill"
        case "tamamlandı", "completed", "bitti":
            return "checkmark.seal.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
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
    
    private func getStatusText() -> String {
        switch appoinment.status.lowercased() {
        case "onaylandı", "confirmed", "onay":
            return "Onaylandı"
        case "beklemede", "pending", "bekliyor":
            return "Beklemede"
        case "iptal", "cancelled", "canceled":
            return "İptal Edildi"
        case "tamamlandı", "completed", "bitti":
            return "Tamamlandı"
        default:
            return appoinment.status
        }
    }
}

// Helper view for info rows
struct InfoRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct EditAppointmentView: View {
    let appointment: Appointment
    let appointmentViewModel: AppoinmentViewModel  // Parametre olarak geç
    @Environment(\.presentationMode) var presentationMode
    
    let availableTimes = ["09:00", "10:00", "11:00", "13:00", "14:00", "15:00", "16:00"]
    
    // Düzenlenebilir state değişkenleri
    @State private var selectedDate: Date
    @State private var selectedTime: String
    
    // Initializer
    init(appointment: Appointment, appointmentViewModel: AppoinmentViewModel) {
        self.appointment = appointment
        self.appointmentViewModel = appointmentViewModel
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let initialDate = dateFormatter.date(from: appointment.appointmentDate) ?? Date()
        
        _selectedDate = State(initialValue: initialDate)
        _selectedTime = State(initialValue: appointment.appointmentTime)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Sabit bilgiler
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(LocalizedStringKey("Customer"))
                        .fontWeight(.medium)
                    Spacer()
                    Text(appointment.customerName)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(LocalizedStringKey("service"))
                        .fontWeight(.medium)
                    Spacer()
                    Text(appointment.serviceName)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Düzenlenebilir alanlar
            VStack(spacing: 16) {
                // Tarih seçici
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey("appointment_date"))
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    DatePicker("Tarih Seçin",
                               selection: $selectedDate,
                               in: Date()...,
                               displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                }
                
                Divider()
                
                // Saat seçici
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey("appointment_time"))
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(availableTimes, id: \.self) { time in
                                timeButton(for: time)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            Spacer()
            
            // Kaydet butonu
            Button("Kaydet") {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy"
                let formattedDate = formatter.string(from: selectedDate)
                
                Task {
                    await appointmentViewModel.updateAppointment(
                        appointmentId: appointment.id ?? "",
                        newDate: formattedDate,
                        newTime: selectedTime
                    )
                    
                    // Hata yoksa sheet'i kapat
                    if appointmentViewModel.updateError == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(appointmentViewModel.isUpdating)
            .padding()
        }
        .padding()
    }
    
    private func timeButton(for time: String) -> some View {
        Button(action: {
            selectedTime = time
        }) {
            Text(time)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedTime == time ? Color.yellow : Color.gray.opacity(0.2))
                .foregroundColor(.black)
                .cornerRadius(8)
        }
    }
}

#Preview {
    NavigationView {
        AppoinmentDetailScreen(appoinment: Appointment(
            id: "1",
            customerName: "Ahmet Yılmaz",
            customerTel: "05551234567",
            salonName: "Güzellik Salonu",
            serviceName: "Saç Kesimi",
            appointmentDate: "23.07.2025",
            appointmentTime: "14:30",
            status: "onaylandı"
        ))
        .environmentObject(AppoinmentViewModel())
    }
}
