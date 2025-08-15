//
//  AdminProfileScreen.swift
//  RandevuJet
//
//  Created by sude on 31.07.2025.
//

import Foundation
import SwiftUI
import Kingfisher

struct AdminProfileScreen: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @State private var isEditingProfile = false
    @State private var showingComments = false
    @State private var showingLogoutAlert = false
    @State private var isDarkMode = false

    @State private var profileName = "Salon Güzellik"
    @State private var profileDescription = "25 yıllık deneyimle, saç kesimi, boyama ve bakım hizmetleri sunuyoruz."
    @State private var profilePhone = "+90 555 123 4567"
    @State private var profileAddress = "İstanbul, Şişli"
    @State private var profileImage = "person.circle.fill"
    
    // Örnek yorumlar
    @State private var reviews = [
        Review(id: 1, customerName: "Ayşe Yılmaz", rating: 5, comment: "Harika bir deneyimdi! Saçlarım çok güzel oldu.", date: "2 gün önce"),
        Review(id: 2, customerName: "Mehmet Demir", rating: 4, comment: "Personel çok ilgili, fiyatlar uygun.", date: "1 hafta önce"),
        Review(id: 3, customerName: "Fatma Özkan", rating: 5, comment: "Uzun zamandır gittiğim en iyi kuaför.", date: "2 hafta önce"),
        Review(id: 4, customerName: "Ali Kaya", rating: 3, comment: "İyi ama randevu almak biraz zor.", date: "3 hafta önce"),
        Review(id: 5, customerName: "Zeynep Ak", rating: 5, comment: "Saç boyamada gerçekten uzmanlar!", date: "1 ay önce")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let user = adminViewModel.hairdressercurrentUser {
                    VStack(spacing: 20) {
                        // Profil Header
                        profileHeaderView(user: user)
                        
                        // İstatistikler
                        statsView
                        
                        // Ana Butonlar
                        actionButtonsView
                        
                        // Son Yorumlar Önizleme
                        recentReviewsPreview
                        
                        // Logout Button
                        logoutButtonView
                    }
                    .padding()
                }else if let error = adminViewModel.errorMessage {
                    Text("Hata: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    ProgressView()
                        .onAppear {
                            Task {
                                try await adminViewModel.loadInitialData()
                            }
                        }
                }
            }
            .onAppear {
                // Kaydedilmiş tema ayarını yükle
                isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
            }
        }
        .sheet(isPresented: $isEditingProfile) {
            ProfileEditView(
                profileName: $profileName,
                profileDescription: $profileDescription,
                profilePhone: $profilePhone,
                profileAddress: $profileAddress,
                isPresented: $isEditingProfile
            )
        }
        .sheet(isPresented: $showingComments) {
            AllReviewsView(reviews: adminViewModel.reviews, isPresented: $showingComments)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)

        .alert("Çıkış Yap", isPresented: $showingLogoutAlert) {
            Button("İptal", role: .cancel) { }
            Button("Çıkış Yap", role: .destructive) {
                Task {
                    await try authViewModel.signOut()
                }
            }
        } message: {
            Text("Hesabınızdan çıkış yapmak istediğinizden emin misiniz?")
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Profile Header
    // MARK: - Profile Header
    private func profileHeaderView(user: HairDresser) -> some View {
        VStack(spacing: 20) {
            // Profil Fotoğrafı
            KFImage(URL(string: user.photo ?? ""))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 140, height: 140)
                .clipped()
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            
            // Salon Bilgileri
                   VStack(spacing: 12) {
                       Text(user.salonName ?? "Salon İsmi Yok")
                           .font(.title2)
                           .fontWeight(.bold)
                           .multilineTextAlignment(.center)
                           .foregroundColor(.primary)

                       Text(user.address ?? "Adres yok")
                           .font(.subheadline)
                           .foregroundColor(.secondary)
                           .multilineTextAlignment(.center)
                           .lineLimit(3)

                       HStack(spacing: 8) {
                           Image(systemName: "phone.fill")
                               .foregroundColor(.blue)
                           Text(user.phone ?? "Telefon yok")
                               .fontWeight(.medium)
                       }
                       .font(.subheadline)
                       .foregroundColor(.primary)
                       .padding(.horizontal, 16)
                       .padding(.vertical, 8)
                       .background(
                           Capsule()
                               .fill(Color.blue.opacity(0.1))
                       )
                   }
                   
                   // Açıklama
                   if let text = user.text, !text.isEmpty {
                       Text(text)
                           .font(.subheadline)
                           .multilineTextAlignment(.center)
                           .padding(.horizontal, 20)
                           .foregroundColor(.secondary)
                           .lineLimit(4)
                           .fixedSize(horizontal: false, vertical: true)
                   }
        }
        .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 16)
    }
    
    // MARK: - Stats View
    private var statsView: some View {
        HStack(spacing: 20) {
            StatCard(title: "Toplam Yorum", value: "\(adminViewModel.reviews.count)", icon: "message.fill", color: .blue)
            StatCard(title: "Ortalama Puan", value: String(format: "%.1f", averageRating), icon: "star.fill", color: .orange)
            StatCard(title: "Bu Ay", value: "\(adminViewModel.appointments.count)", icon: "calendar", color: .green)
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            // Profil Düzenle Butonu
            Button(action: {
                isEditingProfile = true
            }) {
                HStack {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                    Text("Profili Düzenle")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                .foregroundColor(.blue)
            }
            
            // Tema Toggle Butonu
            HStack {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.title2)
                Text(isDarkMode ? "Koyu Tema" : "Açık Tema")
                    .fontWeight(.medium)
                Spacer()
                
                Toggle("", isOn: $isDarkMode)
                    .labelsHidden()
                    .onChange(of: isDarkMode) { value in
                        // Tema değişikliğini kaydet
                        UserDefaults.standard.set(value, forKey: "isDarkMode")
                        themeViewModel.toggleTheme()
                    }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.pink.opacity(0.1))
            )
            .foregroundColor(.pink)
            
            // Müşteri Listesi Butonu
            NavigationLink(destination: AdminCustomerListScreen().environmentObject(adminViewModel).environmentObject(authViewModel)) {
                HStack {
                    Image(systemName: "person.3.fill")
                        .font(.title2)
                    Text("Müşteri Listesi")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                )
                .foregroundColor(.purple)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Tüm Yorumları Gör Butonu
            Button(action: {
                showingComments = true
            }) {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.title2)
                    Text("Tüm Yorumları Gör")
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
                .foregroundColor(.orange)
            }
        }
    }
    
    // MARK: - Logout Button
    private var logoutButtonView: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack {
                Image(systemName: "arrow.right.square.fill")
                    .font(.title2)
                Text("Çıkış Yap")
                    .fontWeight(.medium)
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
            )
            .foregroundColor(.red)
        }
    }
    
    // MARK: - Recent Reviews Preview
    private var recentReviewsPreview: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Son Yorumlar")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Button("Tümünü Gör") {
                    showingComments = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            ForEach(Array(reviews.prefix(3))) { review in
                ReviewRowView(review: review)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private var averageRating: Double {
        guard !reviews.isEmpty else { return 0.0 }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
}

struct ReviewRowView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.customerName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= review.rating ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(star <= review.rating ? .orange : .gray)
                    }
                }
            }
            
            Text(review.comment)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(review.date)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct ProfileEditView: View {
    @Binding var profileName: String
    @Binding var profileDescription: String
    @Binding var profilePhone: String
    @Binding var profileAddress: String
    @Binding var isPresented: Bool
    
    // Örnek olarak view model ekledim
    @EnvironmentObject var adminViewModel: AdminViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section("Salon Bilgileri") {
                    TextField("Salon Adı", text: $profileName)
                    TextField("Telefon", text: $profilePhone)
                    TextField("Adres", text: $profileAddress)
                }
                
                Section("Açıklama") {
                    TextEditor(text: $profileDescription)
                        .frame(minHeight: 100)
                }
                
                Section("Resim") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("Profil Resmi")
                                .font(.headline)
                            Text("Resim değiştirmek için dokunun")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    // Buraya resim seçme işlemi de eklenebilir
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("İptal") {
                    isPresented = false
                },
                trailing: Button("Kaydet") {
                    // Kaydetme işlemi burada yapılabilir
                    Task {
                        await adminViewModel.updateHairdresserDataProfile(address: profileAddress, phone: profilePhone, text: profileDescription )
                        isPresented = false
                    }
                }
                .fontWeight(.semibold)
            )
        }
    }
}

// MARK: - Customer List View
struct CustomerListView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var adminViewModel: AdminViewModel
    @State private var searchText = ""
    
    // Örnek müşteri verisi - gerçek uygulamada AdminViewModel'den gelecek
    @State private var customers = [
        CustomerReview(id: "1", name: "Ayşe Yılmaz", phone: "+90 555 123 4567", lastVisit: "2 gün önce"),
        CustomerReview(id: "2", name: "Mehmet Demir", phone: "+90 555 234 5678", lastVisit: "1 hafta önce"),
        CustomerReview(id: "3", name: "Fatma Özkan", phone: "+90 555 345 6789", lastVisit: "2 hafta önce"),
        CustomerReview(id: "4", name: "Ali Kaya", phone: "+90 555 456 7890", lastVisit: "3 hafta önce"),
        CustomerReview(id: "5", name: "Zeynep Ak", phone: "+90 555 567 8901", lastVisit: "1 ay önce")
    ]
    
    var filteredCustomers: [CustomerReview] {
        if searchText.isEmpty {
            return customers
        } else {
            return customers.filter { customer in
                customer.name.localizedCaseInsensitiveContains(searchText) ||
                customer.phone.contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Arama Çubuğu
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                if filteredCustomers.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.3.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text(searchText.isEmpty ? "Henüz müşteri eklenmemiş" : "Arama sonucu bulunamadı")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        if searchText.isEmpty {
                            Text("Randevu detaylarından müşteri ekleyebilirsiniz")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredCustomers) { customer in
                        CustomerRowView(customer: customer)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Müşteri Listesi")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Kapat") { isPresented = false })
        }
        .onAppear {
            // Gerçek uygulamada müşteri verilerini yükle
            // Task { await adminViewModel.loadCustomers() }
        }
    }
}

struct CustomerRowView: View {
    let customer: CustomerReview
    @State private var showingCallSheet = false
    
    var body: some View {
        HStack {
            // Müşteri Avatar
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(customer.name.prefix(1)))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(customer.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(customer.phone)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Son ziyaret: \(customer.lastVisit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showingCallSheet = true
            }) {
                Image(systemName: "phone.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
        .actionSheet(isPresented: $showingCallSheet) {
            ActionSheet(
                title: Text("Müşteriyi Ara"),
                message: Text(customer.phone),
                buttons: [
                    .default(Text("Aramayı Başlat")) {
                        callCustomer(phone: customer.phone)
                    },
                    .cancel()
                ]
            )
        }
    }
    
    private func callCustomer(phone: String) {
        let phoneNumber = phone.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Müşteri ara...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - All Reviews View
/*struct AllReviewsView: View {
    let reviews: [Review]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List(reviews) { review in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(review.customerName)
                                .font(.headline)
                            Text(review.date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= review.rating ? "star.fill" : "star")
                                    .font(.subheadline)
                                    .foregroundColor(star <= review.rating ? .orange : .gray)
                            }
                        }
                    }
                    
                    Text(review.comment)
                        .font(.body)
                        .padding(.top, 4)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Tüm Yorumlar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Kapat") { isPresented = false })
        }
    }
}*/

struct AllReviewsView: View {
    let reviews: [String]   // string array
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(reviews, id: \.self) { review in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(review)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                // Sabit yıldız gösterimi (örnek: 5 yıldız dolu)
                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.orange)
                                            .font(.subheadline)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
            }
            .navigationTitle("Tüm Yorumlar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Kapat") { isPresented = false })
        }
    }
}



// MARK: - Data Models
struct Review: Identifiable {
    let id: Int
    let customerName: String
    let rating: Int
    let comment: String
    let date: String
}

struct CustomerReview: Identifiable {
    let id: String
    let name: String
    let phone: String
    let lastVisit: String
}

#Preview {
    AdminProfileScreen()
}
