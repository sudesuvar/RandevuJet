//
//  AdminProfileScreen.swift
//  RandevuJet
//
//  Created by sude on 31.07.2025.
//

import Foundation
import SwiftUI

struct AdminProfileScreen: View {
    @EnvironmentObject var adminViewModel: AdminViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditingProfile = false
    @State private var showingComments = false
    @State private var showingLogoutAlert = false
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
        Review(id: 5, customerName: "Zeynep Ak", rating: 5, comment: "Saç boyamda gerçekten uzmanlar!", date: "1 ay önce")
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
            AllReviewsView(reviews: reviews, isPresented: $showingComments)
        }
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
    private func profileHeaderView(user: HairDresser) -> some View {
        VStack(spacing: 15) {
            if let photoURL = user.photo, let url = URL(string: photoURL) {
                           AsyncImage(url: url) { phase in
                               switch phase {
                               case .empty:
                                   ProgressView()
                                       .frame(width: 120, height: 120)
                               case .success(let image):
                                   image
                                       .resizable()
                                       .scaledToFill()
                                       .frame(width: 120, height: 120)
                                       .clipShape(Circle())
                               case .failure(_):
                                   Image(systemName: "person.circle.fill")
                                       .font(.system(size: 120))
                                       .foregroundColor(.blue)
                               @unknown default:
                                   EmptyView()
                               }
                           }
                       } else {
                           Image(systemName: "person.circle.fill")
                               .font(.system(size: 120))
                               .foregroundColor(.blue)
                       }
            
            // Salon Bilgileri
            VStack(spacing: 8) {
                Text(user.salonName ?? "Salon İsmi Yok")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(user.address ?? "Adres yok")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "phone.fill")
                    Text(user.phone ?? "Telefon yok")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            // Açıklama
            Text(user.text ?? "Açıklama yok...")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // MARK: - Stats View
    private var statsView: some View {
        HStack(spacing: 20) {
            StatCard(title: "Toplam Yorum", value: "\(reviews.count)", icon: "message.fill", color: .blue)
            StatCard(title: "Ortalama Puan", value: String(format: "%.1f", averageRating), icon: "star.fill", color: .orange)
            StatCard(title: "Bu Ay", value: "12", icon: "calendar", color: .green)
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


// MARK: - All Reviews View
struct AllReviewsView: View {
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
}

// MARK: - Data Model
struct Review: Identifiable {
    let id: Int
    let customerName: String
    let rating: Int
    let comment: String
    let date: String
}

#Preview {
    AdminProfileScreen()
}
