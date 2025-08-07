//
//  HairdresserDetailsScreen.swift
//  RandevuJet
//
//  Created by sude on 22.07.2025.
//

import Foundation
import SwiftUI
import Kingfisher

struct HairdresserDetailsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    @State private var selectedService: String? = nil
    @State private var showBookingSheet = false
    @State private var loadedServices: [Service] = []
    
    let hairdresser: HairDresser
    private let repository = HairdresserRepository()
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    
                    // ... [Profil bilgileri aynen kalabilir]
                    HStack(alignment: .top, spacing: 16) {
                                     if let urlString = hairdresser.photo,
                                        let url = URL(string: urlString) {
                                         KFImage(url)
                                             .resizable()
                                             .aspectRatio(contentMode: .fill)
                                             .frame(width: 120, height: 120)
                                             .background(
                                                 LinearGradient(
                                                     colors: [.purple.opacity(0.3), .pink.opacity(0.3)],
                                                     startPoint: .topLeading,
                                                     endPoint: .bottomTrailing
                                                 )
                                             )
                                             .cornerRadius(12)
                                             .clipped()
                                         
                                     }else {
                                         Color.gray.opacity(0.3)
                                             .frame(width: 100, height: 100)
                                             .cornerRadius(10)
                                     }
                                     
                                     VStack(alignment: .leading, spacing: 8) {
                                         Text(hairdresser.salonName)
                                             .font(.title2)
                                             .fontWeight(.bold)
                                         
                                         HStack {
                                             Image(systemName: "star.fill")
                                                 .foregroundColor(.yellow)
                                             Text("4.8")
                                                 .fontWeight(.medium)
                                             Text("(247 değerlendirme)")
                                                 .foregroundColor(.secondary)
                                                 .font(.caption)
                                         }
                                         NavigationLink(destination: MapView(address: hairdresser.address ?? "TeknoPark, Kocaeli")) {
                                             HStack {
                                                 Image(systemName: "location.fill")
                                                     .foregroundColor(.blue)
                                                 Text(hairdresser.address ?? "Adres Bilgisi Yok")
                                                     .font(.subheadline)
                                             }
                                             
                                         }
                                         
                                         
                                         if let workingHours = hairdresser.workingHours {
                                             HStack() {
                                                 ForEach(workingHours, id: \.self) { hour in
                                                     HStack {
                                                         Image(systemName: "clock.fill")
                                                             .foregroundColor(.green)
                                                         Text(hour)
                                                             .font(.subheadline)
                                                     }
                                                 }
                                             }
                                         } else {
                                             Text("Çalışma saatleri mevcut değil.")
                                         }


                                         

                                         
                                         HStack {
                                             Image(systemName: "phone.fill")
                                                 .foregroundColor(.orange)
                                             Text(hairdresser.phone ?? "Telefon Numarası Yok")
                                                 .font(.subheadline)
                                         }
                                     }
                                     Spacer()
                                 }
                                 .padding(.horizontal)

                    // Sekme Seçimi
                    HStack {
                        Button(action: { selectedTab = 0 }) {
                            Text("Hizmetler")
                                .fontWeight(.medium)
                                .foregroundColor(Color.yellow)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedTab == 0 ? Color.yellow.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                        }
                        Button(action: { selectedTab = 1 }) {
                            Text("Yorumlar")
                                .foregroundColor(Color.yellow)
                                .fontWeight(.medium)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedTab == 1 ? Color.yellow.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sekme İçeriği
                    if selectedTab == 0 {
                        ServicesTabView(
                            selectedServiceId: $selectedService,
                            services: loadedServices
                        )
                    } else {
                        ReviewsTabView()
                    }
                }
            }

            // Randevu Butonu
            Button(action: {
                if selectedService != nil {
                    showBookingSheet = true
                }
            }) {
                Text("Randevu Al")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedService != nil ? Color.yellow : Color.gray)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(selectedService == nil)
            .padding(.bottom)
        }
        .onAppear {
            Task {
                await loadServices()
            }
        }
        .sheet(isPresented: $showBookingSheet) {
            if let selectedId = selectedService,
               let service = loadedServices.first(where: { $0.id == selectedId }) {
                BookingSheet(hairdresser: hairdresser, selectedService: service)
                    .environmentObject(HairdresserViewModel())
            }
        }
    }

    // 🔁 Firestore'dan servisleri getir
    private func loadServices() async {
        guard let serviceIds = hairdresser.services else { return }
        do {
            let services = try await repository.fetchServicesByIds(serviceIds)
            DispatchQueue.main.async {
                self.loadedServices = services
            }
        } catch {
            print("❌ Servisler yüklenemedi: \(error.localizedDescription)")
        }
    }
}




struct ReviewsTabView: View {
    var body: some View {
        LazyVStack(spacing: 12) {
            ReviewCard(name: "Ayşe K.", rating: 5, comment: "Gerçekten mükemmel bir hizmet, çok memnun kaldım!", date: "2 gün önce")
            ReviewCard(name: "Zeynep M.", rating: 5, comment: "Her şey harikaydı, saçımı çok beğendim.", date: "1 hafta önce")
            ReviewCard(name: "Fatma S.", rating: 4, comment: "İyi hizmet ama bekleme süresi biraz uzundu.", date: "2 hafta önce")
            ReviewCard(name: "Merve A.", rating: 5, comment: "Sürekli tercih ettiğim bir yer, güvenilir.", date: "3 hafta önce")
        }
        .padding(.horizontal)
        .transition(.slide)
    }
}

struct ServicesTabView: View {
    @Binding var selectedServiceId: String?
    let services: [Service]  // Dinamik servis listesi

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach(services) { service in
                ServiceCard(
                    title: service.serviceTitle,
                    description: service.serviceDesc,
                    price: service.servicePrice ?? "Fiyat yok",
                    duration: service.serviceDuration ?? "Süre yok",
                    isSelected: selectedServiceId == service.id
                ) {
                    selectedServiceId = service.id
                }
            }
        }
        .padding(.horizontal)
        .transition(.slide)
    }
}

#Preview {
    //HairdresserDetailsScreen(hairdresser: )
}
