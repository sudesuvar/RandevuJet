import SwiftUI
import Kingfisher

struct HairdressersScreen: View {
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                if hairdresserViewModel.hairdressers.isEmpty {
                    EmptyList.hairdressers()
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(hairdresserViewModel.hairdressers) { hairdresser in
                            NavigationLink(destination: HairdresserDetailsScreen(hairdresser: hairdresser)) {
                                HairdresserCard(hairdresser: hairdresser)
                            }
                            .buttonStyle(PlainButtonStyle()) // underline veya mavi highlight olmasın diye
                        }
                    }
                }
            }
        }
        .task {
            await hairdresserViewModel.fetchHairdressers()
        }
    }
}

struct HairdresserCard: View {
    let hairdresser: HairDresser
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let urlString = hairdresser.photo,
               let url = URL(string: urlString) {
                KFImage(url)
                    .placeholder {
                        Color.gray.opacity(0.3)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(hairdresser.salonName)
                    .font(.headline)
                
                Text(hairdresser.address ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(hairdresser.phone ?? "")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}


#Preview {
    HairdressersScreen()
        .environmentObject(HairdresserViewModel())
}
