//
//  HairdresserDetailsScreen.swift
//  RandevuJet
//
//  Created by sude on 22.07.2025.
//

import Foundation
import SwiftUI

struct HairdresserDetailsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    @State private var selectedService: String? = nil
    @State private var showBookingSheet = false
    let hairdresser: HairDresser
    
    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    // Görsel ve Bilgiler Yanyana
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: "person.crop.rectangle.fill")
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
                            
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                Text(hairdresser.address ?? "Adres Bilgisi Yok")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.green)
                                Text("09:00 - 19:00")
                                    .font(.subheadline)
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
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedTab == 0 ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                        }
                        Button(action: { selectedTab = 1 }) {
                            Text("Yorumlar")
                                .fontWeight(.medium)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(selectedTab == 1 ? Color.blue.opacity(0.2) : Color.clear)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Sekme İçeriği
                    if selectedTab == 0 {
                        ServicesTabView(selectedService: $selectedService)
                    } else {
                        ReviewsTabView()
                    }
                    
                    Spacer()
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
        .sheet(isPresented: $showBookingSheet) {
            Text("Randevu alma ekranı burada olacak.")
        }
        /*.navigationBarBackButtonHidden(true)
        .navigationTitle("") // Boş başlık
        .navigationBarTitleDisplayMode(.inline)*/
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
    @Binding var selectedService: String?
    
    var body: some View {
        LazyVStack(spacing: 12) {
            ServiceCard(
                title: "Saç Kesimi",
                description: "Profesyonel saç kesim hizmeti",
                price: "₺150",
                duration: "45 dk",
                isSelected: selectedService == "kesim"
            ) {
                selectedService = "kesim"
            }
            
            ServiceCard(
                title: "Saç Boyama",
                description: "Renk değişimi ve boyama",
                price: "₺300",
                duration: "120 dk",
                isSelected: selectedService == "boyama"
            ) {
                selectedService = "boyama"
            }
            
            ServiceCard(
                title: "Keratin Bakım",
                description: "Saç bakımı ve onarım",
                price: "₺500",
                duration: "180 dk",
                isSelected: selectedService == "keratin"
            ) {
                selectedService = "keratin"
            }
            
            ServiceCard(
                title: "Fön & Şekillendirme",
                description: "Profesyonel şekillendirme",
                price: "₺80",
                duration: "30 dk",
                isSelected: selectedService == "fon"
            ) {
                selectedService = "fon"
            }
        }
        .padding(.horizontal)
        .transition(.slide)
    }
}




#Preview {
    //HairdresserDetailsScreen(hairdresser: )
}
