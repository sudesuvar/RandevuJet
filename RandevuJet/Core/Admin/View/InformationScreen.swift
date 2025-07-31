//
//  InformationScreen.swift
//  RandevuJet
//
//  Created by sude on 30.07.2025.
//



import SwiftUI
import Foundation

// Önceden tanımlı hizmetler
struct PredefinedService {
    static let allServices = [
        "Saç Kesimi",
        "Saç Boyama",
        "Röfle",
        "Fön",
        "Makyaj",
        "Kaş Alma",
        "Kaş Boyama",
        "Kirpik Lifting",
        "Manikür",
        "Pedikür",
        "Jelatin",
        "Protez Tırnak",
        "Cilt Bakımı",
        "Yüz Temizliği",
        "Epilasyon",
        "Masaj",
        "Saç Bakımı",
        "Keratin",
        "Ombre",
        "Balayaj",
        "Perma"
    ]
}

// Ana kayıt sayfası
struct InformationScreen: View {
    @State private var salonName: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var phone: String = ""
    @State private var photo: String = ""
    @State private var employeesNumber: String = ""
    @State private var text: String = ""
    @State private var services: [Service] = []
    @State private var workingStartTime: String = ""
    @State private var workingEndTime: String = ""
    
    @State private var showingImagePicker = false
    @State private var showingServiceSheet = false
    
    private let daysOfWeek = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
    
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
                        
                        if services.isEmpty {
                            Text("Henüz hizmet eklenmedi")
                                .foregroundColor(.gray)
                                .italic()
                        } else {
                            ForEach(services, id: \.id) { service in
                                ServiceRow(service: service) {
                                    services.removeAll { $0.id == service.id }
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
                        
                        // Bilgi notu
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
            AddServiceSheet(services: $services) {
                // Sheet kapandıktan sonra yapılacak işlemler
            }
        }
    }
    
    private func saveSalon() {
        let employeesCount = Int(employeesNumber) ?? 0
        
        print("Salon Bilgileri:")
        print("Ad: \(salonName)")
        print("E-posta: \(email)")
        print("Adres: \(address)")
        print("Telefon: \(phone)")
        print("Çalışan Sayısı: \(employeesCount)")
        print("Açıklama: \(text)")
        print("Hizmetler: \(services.count) adet")
        
   
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

// Bölüm başlığı
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
}

// Hizmet satırı
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
                
                HStack {
                    if let price = service.servicePrice, !price.isEmpty {
                        Text("₺\(price)")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    
                    if let duration = service.serviceDuration, !duration.isEmpty {
                        if service.servicePrice != nil && !service.servicePrice!.isEmpty {
                            Text("•")
                                .foregroundColor(.gray)
                        }
                        Text("\(duration) dk")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
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

// Hizmet ekleme sheet'i
struct AddServiceSheet: View {
    @Binding var services: [Service]
    let onDismiss: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedServices: Set<String> = []
    @State private var serviceDetails: [String: ServiceDetails] = [:]
    @State private var searchText = ""
    
    struct ServiceDetails {
        var duration: String = "30"
        var price: String = ""
        var description: String = ""
    }
    
    private var filteredServices: [String] {
        if searchText.isEmpty {
            return PredefinedService.allServices
        } else {
            return PredefinedService.allServices.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Başlık
                VStack(spacing: 10) {
                    Text("Hizmet Seçimi")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Birden fazla hizmet seçebilirsiniz")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                
                // Arama çubuğu
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                // Seçilen hizmetler sayısı
                if !selectedServices.isEmpty {
                    HStack {
                        Text("\(selectedServices.count) hizmet seçildi")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                }
                
                // Hizmet listesi
                List {
                    ForEach(filteredServices, id: \.self) { serviceName in
                        ServiceSelectionRow(
                            serviceName: serviceName,
                            isSelected: selectedServices.contains(serviceName),
                            serviceDetails: serviceDetails[serviceName] ?? ServiceDetails()
                        ) { isSelected, details in
                            if isSelected {
                                selectedServices.insert(serviceName)
                                serviceDetails[serviceName] = details
                            } else {
                                selectedServices.remove(serviceName)
                                serviceDetails.removeValue(forKey: serviceName)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                // Alt butonlar
                HStack(spacing: 15) {
                    Button("İptal") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    Button("Ekle (\(selectedServices.count))") {
                        addSelectedServices()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(selectedServices.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(selectedServices.isEmpty)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func addSelectedServices() {
        for serviceName in selectedServices {
            let details = serviceDetails[serviceName] ?? ServiceDetails()
            let newService = Service(
                serviceTitle: serviceName,
                serviceDesc: details.description.isEmpty ? "Açıklama eklenmedi" : details.description,
                servicePrice: details.price.isEmpty ? nil : details.price,
                serviceDuration: details.duration.isEmpty ? nil : details.duration
            )
            
            // Aynı hizmeti tekrar eklememek için kontrol
            if !services.contains(where: { $0.serviceTitle == serviceName }) {
                services.append(newService)
            }
        }
        onDismiss()
    }
}

// Arama çubuğu komponenti
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Hizmet ara...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// Hizmet seçim satırı
struct ServiceSelectionRow: View {
    let serviceName: String
    let isSelected: Bool
    let serviceDetails: AddServiceSheet.ServiceDetails
    let onSelectionChange: (Bool, AddServiceSheet.ServiceDetails) -> Void
    
    @State private var localDetails: AddServiceSheet.ServiceDetails
    @State private var isExpanded: Bool = false
    
    init(serviceName: String, isSelected: Bool, serviceDetails: AddServiceSheet.ServiceDetails, onSelectionChange: @escaping (Bool, AddServiceSheet.ServiceDetails) -> Void) {
        self.serviceName = serviceName
        self.isSelected = isSelected
        self.serviceDetails = serviceDetails
        self.onSelectionChange = onSelectionChange
        self._localDetails = State(initialValue: serviceDetails)
        self._isExpanded = State(initialValue: isSelected)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Checkbox
                Button(action: {
                    let newSelection = !isSelected
                    isExpanded = newSelection
                    onSelectionChange(newSelection, localDetails)
                }) {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title2)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Hizmet adı
                Text(serviceName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isSelected {
                    isExpanded.toggle()
                } else {
                    isExpanded = true
                    onSelectionChange(true, localDetails)
                }
            }
            
            // Detay alanları (sadece seçili ve genişletilmişse görünür)
            if isSelected && isExpanded {
                VStack(spacing: 12) {
                    // Süre
                    HStack {
                        Text("Süre (dk):")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: 80, alignment: .leading)
                        
                        TextField("30", text: $localDetails.duration)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: localDetails.duration) { _ in
                                onSelectionChange(isSelected, localDetails)
                            }
                    }
                    
                    // Fiyat
                    HStack {
                        Text("Fiyat (₺):")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(width: 80, alignment: .leading)
                        
                        TextField("Fiyat", text: $localDetails.price)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: localDetails.price) { _ in
                                onSelectionChange(isSelected, localDetails)
                            }
                    }
                    
                    // Açıklama
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Açıklama:")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        TextField("Hizmet açıklaması...", text: $localDetails.description, axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: localDetails.description) { _ in
                                onSelectionChange(isSelected, localDetails)
                            }
                    }
                }
                .padding(.leading, 30)
                .transition(.opacity)
            }
        }
        .padding(.vertical, 4)
        .onChange(of: isSelected) { newValue in
            isExpanded = newValue
        }
    }
}

// Preview
struct InformationScreen_Previews: PreviewProvider {
    static var previews: some View {
        InformationScreen()
    }
}
