import Foundation
import SwiftUI
import Kingfisher


struct HorizontalList: View {
    let hairdressers: [HairDresser]
    var onShowAllTapped: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Kuaförler")
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
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(hairdressers) { hairdresser in
                        NavigationLink(destination:
                                        HairdresserDetailsScreen(hairdresser: hairdresser)
                            .environmentObject(authViewModel)
                            .environmentObject(themeViewModel)
                            .environmentObject(hairdresserViewModel)
                        ) {
                            HairdresserRow(hairdresser: hairdresser)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct HairdresserRow: View {
    let hairdresser: HairDresser
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            KFImage(URL(string: hairdresser.photo ?? ""))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            
            VStack(spacing: 4) {
                Text(hairdresser.salonName ?? "Bilinmeyen Salon")
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text(hairdresser.text ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(14)
        .shadow(color: colorScheme == .dark ? .black.opacity(0.2) : .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
