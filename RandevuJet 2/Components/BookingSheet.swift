//
//  BookingSheet.swift
//  RandevuJet
//
//  Created by sude on 22.07.2025.
//

import Foundation
import SwiftUI

struct BookingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    
    let hairdresser: HairDresser
    let selectedService: Service
    
    @State private var selectedDate = Date()
    @State private var selectedTime = ""
    @State private var fullName = ""
    @State private var phoneNumber = ""
    
    @State private var showConfirmation = false
    
    var availableTimes: [String] {
            if let workingHours = hairdresser.workingHours, workingHours.count >= 2 {
                return generateHourlyIntervals(from: workingHours[0], to: workingHours[1]) ?? []
            }
            return []
        }
    
    var body: some View {
        Form {
            Section(header: Text("Kuaför & Hizmet")) {
                Text(hairdresser.salonName)
                Text(selectedService.serviceTitle)
            }
            
            Section(header: Text("Tarih Seçimi")) {
                DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
            }
            
            Section(header: Text("Saat Seçimi")) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(availableTimes, id: \.self) { time in
                            timeButton(for: time)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Kişisel Bilgiler")) {
                TextField("Ad Soyad", text: $fullName)
                TextField("Telefon Numarası", text: $phoneNumber)
                    .keyboardType(.phonePad)
            }
            
            Section {
                Button(action: confirmAppointment) {
                    Text("Randevuyu Onayla")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(canConfirm ? Color.green : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!canConfirm)
            }
        }
        .navigationTitle("Randevu Al")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Kapat") {
                    dismiss()
                }
            }
        }
        .alert("Randevunuz oluşturuldu!", isPresented: $showConfirmation) {
            Button("Tamam", role: .cancel) {
                dismiss()
            }
        }
    }
    
    private var canConfirm: Bool {
        !fullName.isEmpty && !phoneNumber.isEmpty && !selectedTime.isEmpty
    }
    
    private func timeButton(for time: String) -> some View {
        Button(action: {
            selectedTime = time
        }) {
            Text(time)
                .padding()
                .background(selectedTime == time ? Color.yellow : Color.gray.opacity(0.2))
                .foregroundColor(.black)
                .cornerRadius(8)
        }
    }
    
    private func confirmAppointment() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = dateFormatter.string(from: selectedDate)
        
        let appointment = Appointment(
            id: UUID().uuidString,
            customerName: fullName,
            customerTel: phoneNumber,
            salonName: hairdresser.salonName,
            serviceName: selectedService.serviceTitle,
            appointmentDate: formattedDate,
            appointmentTime: selectedTime,
            status: "pending",
            createdAt: Date()
        )
        
        Task {
            do {
                try await hairdresserViewModel.createAppointment(appointment: appointment)
                showConfirmation = true
            } catch {
                print("Randevu oluşturulurken hata: \(error.localizedDescription)")
                // İstersen burada kullanıcıya hata mesajı gösterebilirsin.
            }
        }
    }
}
