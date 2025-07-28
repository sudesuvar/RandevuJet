import SwiftUI
import Kingfisher

struct HairdressersScreen: View {
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    @State private var searchText = ""
    @State private var isSearchActive = false
    
    var filteredHairdressers: [HairDresser] {
        if searchText.isEmpty {
            return hairdresserViewModel.hairdressers
        } else {
            return hairdresserViewModel.hairdressers.filter { hairdresser in
                hairdresser.salonName.lowercased().contains(searchText.lowercased()) ||
                (hairdresser.address?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (hairdresser.phone?.contains(searchText) ?? false)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar Section
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 18))
                    
                    TextField("Salon ara...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onTapGesture {
                            isSearchActive = true
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            isSearchActive = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                /*if isSearchActive || !searchText.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: "Yakınımdaki", isSelected: false) {
                                // Filter by location logic
                            }
                            FilterChip(title: "Yüksek Puanlı", isSelected: false) {
                                // Filter by rating logic
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }*/
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            .padding(.top, 8)
            .background(Color(.systemBackground))
            
            // Divider
            Divider()
                .opacity(isSearchActive || !searchText.isEmpty ? 1 : 0.3)
            
            // Results Section
            ScrollView {
                if filteredHairdressers.isEmpty && !searchText.isEmpty {
                    // No Results View
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.top, 60)
                        
                        Text("Sonuç Bulunamadı")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("'\(searchText)' için arama sonucu bulunamadı.\nFarklı anahtar kelimeler deneyin.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Aramayı Temizle") {
                            searchText = ""
                            isSearchActive = false
                        }
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    
                } else if filteredHairdressers.isEmpty && searchText.isEmpty {
                    EmptyList.hairdressers()
                } else {
                    LazyVStack(spacing: 16) {
                        // Search Results Header
                        if !searchText.isEmpty {
                            HStack {
                                Text("\(filteredHairdressers.count) salon bulundu")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                        }
                        
                        ForEach(filteredHairdressers) { hairdresser in
                            NavigationLink(destination: HairdresserDetailsScreen(hairdresser: hairdresser)) {
                                HairdresserCard(hairdresser: hairdresser, searchText: searchText)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            // Dismiss keyboard when tapping outside
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            isSearchActive = false
        }
        .task {
            await hairdresserViewModel.fetchHairdressers()
        }
    }
}


struct HairdresserCard: View {
    let hairdresser: HairDresser
    let searchText: String
    
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
                // Highlighted salon name
                HighlightedText(
                    text: hairdresser.salonName,
                    searchText: searchText
                )
                .font(.headline)
                
                if let address = hairdresser.address {
                    HighlightedText(
                        text: address,
                        searchText: searchText
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                if let phone = hairdresser.phone {
                    HighlightedText(
                        text: phone,
                        searchText: searchText
                    )
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                
                // Rating and distance (if available)
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("4.5")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("1.2 km")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 4)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}

// Filter Chip Component
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

// Highlighted Text Component for Search Results
struct HighlightedText: View {
    let text: String
    let searchText: String
    
    var body: some View {
        if searchText.isEmpty {
            Text(text)
        } else {
            let parts = text.components(separatedBy: searchText)
            let searchParts = text.components(separatedBy: CharacterSet.alphanumerics.inverted)
            
            HStack(spacing: 0) {
                ForEach(0..<parts.count, id: \.self) { index in
                    Text(parts[index])
                    
                    if index < parts.count - 1 {
                        Text(searchText)
                            .background(Color.yellow.opacity(0.3))
                            .cornerRadius(2)
                    }
                }
            }
        }
    }
}

#Preview {
    HairdressersScreen()
        .environmentObject(HairdresserViewModel())
}
