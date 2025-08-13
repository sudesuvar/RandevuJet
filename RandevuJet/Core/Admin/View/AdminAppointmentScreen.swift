//
//  AdminAppointmentScreen.swift
//  RandevuJet
//
//  Created by sude on 8.08.2025.
//

import Foundation
import SwiftUI

struct AdminAppointmentScreen: View {
    let appointment: Appointment
    @EnvironmentObject var adminViewModel: AdminViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingStatusChangeAlert = false
    @State private var selectedNewStatus = ""
    @State private var showingDeleteAlert = false
    @State private var showingCallSheet = false
    @State private var showingAddCustomerAlert = false
    @State private var customerAddedSuccessfully = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Üst Kısım - Durum Badge
                statusHeaderView()
                
                // Müşteri Bilgileri
                customerInfoSection()
                
                // Randevu Detayları
                appointmentDetailsSection()
                
                // Hizmet Bilgileri
                serviceInfoSection()
                
                // Aksiyonlar
                if appointment.status != "completed" {
                    actionsSection()
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
        .navigationTitle("Randevu Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .alert("Durum Değiştir", isPresented: $showingStatusChangeAlert) {
            Button("İptal", role: .cancel) { }
            Button("Değiştir") {
                updateAppointmentStatus()
            }
        } message: {
            Text("Randevu durumunu '\(getStatusDisplayName(selectedNewStatus))' olarak değiştirmek istediğinize emin misiniz?")
        }
        .alert("Randevuyu Sil", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                deleteAppointment()
            }
        } message: {
            Text("Bu randevuyu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.")
        }
        .alert("Müşteri Listesine Ekle", isPresented: $showingAddCustomerAlert) {
            Button("İptal", role: .cancel) { }
            Button("Ekle") {
                addCustomerToList()
            }
        } message: {
            Text("\(appointment.customerName) adlı müşteriyi müşteri listenize eklemek istediğinize emin misiniz?")
        }
        .alert("Başarılı!", isPresented: $customerAddedSuccessfully) {
            Button("Tamam") { }
        } message: {
            Text("Müşteri başarıyla listenize eklendi.")
        }
        .actionSheet(isPresented: $showingCallSheet) {
            ActionSheet(
                title: Text("Müşteriyi Ara"),
                message: Text(appointment.customerTel),
                buttons: [
                    .default(Text("Aramayı Başlat")) {
                        callCustomer()
                    },
                    .cancel()
                ]
            )
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func statusHeaderView() -> some View {
        HStack {
            Spacer()
            if let status = AppointmentStatusAdmin(rawValue: appointment.status) {
                StatusBadgeAdmin(status: status)
                    .scaleEffect(1.2)
            }
            Spacer()
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private func customerInfoSection() -> some View {
        VStack(spacing: 0) {
            sectionHeaderView(title: "Müşteri Bilgileri", icon: "person.fill")
            
            VStack(spacing: 16) {
                infoRowView(
                    icon: "person.circle.fill",
                    title: "Ad Soyad",
                    value: appointment.customerName,
                    color: .blue
                )
                
                HStack {
                    infoRowView(
                        icon: "phone.fill",
                        title: "Telefon",
                        value: appointment.customerTel,
                        color: .green
                    )
                    
                    Button(action: {
                        showingCallSheet = true
                    }) {
                        Image(systemName: "phone.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
                
                // Müşteri Listesine Ekle Butonu
                Button(action: {
                    showingAddCustomerAlert = true
                }) {
                    HStack {
                        Image(systemName: "person.badge.plus.fill")
                            .font(.body)
                        Text("Müşteri Listesine Ekle")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    private func appointmentDetailsSection() -> some View {
        VStack(spacing: 0) {
            sectionHeaderView(title: "Randevu Bilgileri", icon: "calendar")
            
            VStack(spacing: 16) {
                infoRowView(
                    icon: "calendar.circle.fill",
                    title: "Tarih",
                    value: formatDetailedDate(appointment.appointmentDate),
                    color: .orange
                )
                
                infoRowView(
                    icon: "clock.circle.fill",
                    title: "Saat",
                    value: appointment.appointmentTime,
                    color: .purple
                )
                
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    private func serviceInfoSection() -> some View {
        VStack(spacing: 0) {
            sectionHeaderView(title: "Hizmet Detayları", icon: "scissors")
            
            VStack(spacing: 16) {
                infoRowView(
                    icon: "scissors.circle.fill",
                    title: "Hizmet",
                    value: appointment.serviceName,
                    color: .pink
                )
                
                // Eğer fiyat bilgisi varsa eklenebilir
                 infoRowView(
                     icon: "turkishlirasign.circle.fill",
                     title: "Ücret",
                     value: "200 ₺",
                     color: .green
                 )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    private func actionsSection() -> some View {
        VStack(spacing: 12) {
  
            
            VStack(spacing: 12) {
                if appointment.status == "pending" {
                    HStack(spacing: 12) {
                        actionButton(
                            title: "Reddet",
                            icon: "xmark.circle.fill",
                            color: .red,
                            backgroundColor: .red.opacity(0.1)
                        ) {
                            selectedNewStatus = "rejected"
                            showingStatusChangeAlert = true
                        }
                        
                        actionButton(
                            title: "Onayla",
                            icon: "checkmark.circle.fill",
                            color: .white,
                            backgroundColor: .green
                        ) {
                            selectedNewStatus = "confirmed"
                            showingStatusChangeAlert = true
                        }
                    }
                }
                
                if appointment.status == "confirmed" {
                    actionButton(
                        title: "Tamamlandı Olarak İşaretle",
                        icon: "checkmark.circle.fill",
                        color: .white,
                        backgroundColor: .purple
                    ) {
                        selectedNewStatus = "completed"
                        showingStatusChangeAlert = true
                    }
                }
                
                // Sil butonu
                actionButton(
                    title: "Randevuyu Sil",
                    icon: "trash.circle.fill",
                    color: .red,
                    backgroundColor: .red.opacity(0.1)
                ) {
                    showingDeleteAlert = true
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    @ViewBuilder
    private func sectionHeaderView(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func infoRowView(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func actionButton(title: String, icon: String, color: Color, backgroundColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Functions
    
    private func formatDetailedDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let calendar = Calendar.current
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "tr_TR")
        
        if calendar.isDateInToday(date) {
            return "Bugün"
        } else if calendar.isDateInTomorrow(date) {
            return "Yarın"
        } else if calendar.isDateInYesterday(date) {
            return "Dün"
        } else {
            outputFormatter.dateFormat = "dd MMMM yyyy, EEEE"
            return outputFormatter.string(from: date)
        }
    }
    
    private func getStatusDisplayName(_ status: String) -> String {
        switch status {
        case "pending": return "Onay Bekleyen"
        case "confirmed": return "Onaylanan"
        case "completed": return "Tamamlanan"
        case "rejected": return "Reddedilen"
        default: return status
        }
    }
    
    private func updateAppointmentStatus() {
        Task {
                await adminViewModel.updateAppointmentStatus(
                    appointmentId: appointment.id,
                    newStatus: selectedNewStatus
                )
                presentationMode.wrappedValue.dismiss()
            }
    }
    
    private func deleteAppointment() {
        Task {
                await adminViewModel.deleteAppointment(appointmentId: appointment.id)
                presentationMode.wrappedValue.dismiss()
            }
    }
    
    private func addCustomerToList() {
        Task {
            // Burada AdminViewModel'e müşteri ekleme fonksiyonu çağrılacak
            guard let hairdresserId = authViewModel.currentHairdresser?.id  else {
                       print("❌ Kuaför ID bulunamadı.")
                       return
                   }
                   
                  await adminViewModel.addCustomer(
                       hairdresserId: hairdresserId,
                       fullName: appointment.customerName,
                       phone: appointment.customerTel
                   )
            
            customerAddedSuccessfully = true
        }
    }
    
    private func callCustomer() {
        let phoneNumber = appointment.customerTel.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationView {
        AdminAppointmentScreen(appointment: Appointment(
            id: "1",
            customerName: "Ayşe Yılmaz",
            customerTel: "+90 555 123 4567",
            salonName: "Salon Güzellik",
            serviceName: "Saç Kesimi + Fön",
            appointmentDate: "2025-08-08",
            appointmentTime: "10:00",
            status: "pending"
        ))
    }
}
