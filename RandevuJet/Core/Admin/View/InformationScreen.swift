//
//  InformationScreen.swift
//  RandevuJet
//
//  Created by sude on 30.07.2025.
//

import SwiftUI
import Foundation

// Ana kayıt sayfası
struct InformationScreen: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var address: String = ""
    @State private var phone: String = ""
    @State private var photo: String = ""
    @State private var employeesNumber: String = ""
    @State private var text: String = ""
    @State private var workingStartTime: String = ""
    @State private var workingEndTime: String = ""
    @State private var showingImagePicker = false
    @State private var showingServiceSheet = false
    @State private var selectedServices: [String] = [] // sadece ID’ler

    @State private var navigateToAdminTabView = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Başlık
                    VStack {
                        Image(systemName: "scissors")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        Text("Salon Kaydı")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Salonunuzun bilgilerini girin")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)

                    // Temel Bilgiler
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Temel Bilgiler")

                        CustomTextField(title: "Adres", text: $address, icon: "location")
                        CustomTextField(title: "Telefon", text: $phone, icon: "phone")

                        // Çalışan Sayısı
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Çalışan Sayısı", systemImage: "person.2")
                                .font(.headline)
                            TextField("Çalışan sayısını girin", text: $employeesNumber)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.horizontal)

                    // Salon Fotoğrafı
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Salon Fotoğrafı")

                        Button(action: {
                            showingImagePicker = true
                        }) {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.blue)
                                Text("Fotoğraf Ekle")
                                    .font(.headline)
                                if !photo.isEmpty {
                                    Text("Fotoğraf seçildi")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                }
                            }
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    // Salon Açıklaması
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Salon Hakkında")

                        VStack(alignment: .leading, spacing: 8) {
                            Label("Açıklama", systemImage: "text.alignleft")
                                .font(.headline)
                            TextEditor(text: $text)
                                .frame(height: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)

                    // Hizmetler
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            SectionHeader(title: "Hizmetler")
                            Spacer()
                            Button(action: {
                                showingServiceSheet = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }

                        if selectedServices.isEmpty {
                            Text("Henüz hizmet eklenmedi")
                                .foregroundColor(.gray)
                                .italic()
                        } else {
                            ForEach(adminViewModel.services.filter { service in
                                if let id = service.id {
                                    return selectedServices.contains(id)
                                }
                                return false
                            }) { service in
                                ServiceRow(service: service) {
                                    if let id = service.id {
                                        selectedServices.removeAll { $0 == id }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Çalışma Saatleri
                    VStack(alignment: .leading, spacing: 15) {
                        SectionHeader(title: "Çalışma Saatleri")

                        HStack(spacing: 15) {
                            // Başlangıç saati
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Açılış Saati")
                                    .font(.headline)
                                TextField("Örn: 09:00", text: $workingStartTime)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            // Bitiş saati
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Kapanış Saati")
                                    .font(.headline)
                                TextField("Örn: 18:00", text: $workingEndTime)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }

                        Text("Tüm günler için geçerli çalışma saatleri")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .italic()
                    }
                    .padding(.horizontal)

                    // Kaydet Butonu
                    Button(action: saveSalon) {
                        Text("Salon Kaydını Tamamla")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.yellow)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 60)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingServiceSheet) {
            AddServiceSheet(
                allServices: adminViewModel.services,
                selectedServiceIDs: $selectedServices
            )
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: AdminMainTabView()
                    .environmentObject(adminViewModel)
                    .environmentObject(authViewModel),
                isActive: $navigateToAdminTabView
            ) {
                EmptyView()
            }
            .hidden()
        )
    }

    private func saveSalon() {
        Task {
            await adminViewModel.hairdresserDataUpdate(
                address: address,
                phone: phone,
                photo: photo,
                employeesNumber: Int(employeesNumber),
                text: text,
                services: selectedServices,
                workingStartTime: workingStartTime,
                workingEndTime: workingEndTime,
                status: "active"
            )
        }
        DispatchQueue.main.async {
            navigateToAdminTabView = true
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
            TextField(title, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

struct ServiceRow: View {
    let service: Service
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(service.serviceTitle)
                    .font(.headline)

                Text(service.serviceDesc)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AddServiceSheet: View {
    var allServices: [Service]
    @Binding var selectedServiceIDs: [String]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 10) {
                Text("Hizmet Seçimi")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Birden fazla hizmet seçebilirsiniz")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()

            if !selectedServiceIDs.isEmpty {
                Text("\(selectedServiceIDs.count) hizmet seçildi")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.bottom, 5)
            }

            List(allServices) { service in
                if let serviceId = service.id {
                    MultipleSelectionRow(
                        service: service,
                        isSelected: selectedServiceIDs.contains(serviceId)
                    ) {
                        if selectedServiceIDs.contains(serviceId) {
                            selectedServiceIDs.removeAll { $0 == serviceId }
                        } else {
                            selectedServiceIDs.append(serviceId)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())

            HStack(spacing: 15) {
                Button("İptal") {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                Button("Ekle (\(selectedServiceIDs.count))") {
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(selectedServiceIDs.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(selectedServiceIDs.isEmpty)
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}

struct MultipleSelectionRow: View {
    var service: Service
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            Text(service.serviceTitle)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// Preview
struct InformationScreen_Previews: PreviewProvider {
    static var previews: some View {
        InformationScreen()
            .environmentObject(AdminViewModel()) // AdminViewModel örneği ekle
            .environmentObject(AuthViewModel())  // AuthViewModel örneği ekle
    }
}
