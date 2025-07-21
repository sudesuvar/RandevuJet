import Foundation
import SwiftUI

struct VerticalList: View {
    let appointments: [Appointment]
    let titleProvider: (Appointment) -> String
    let subtitleProvider: (Appointment) -> String
    let detailProvider: (Appointment) -> String
    let imageProvider: (Appointment) -> String?
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Randevularım")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
                
                Button(action: {
                    // Hepsini göster action
                }) {
                    Text("Hepsini Göster")
                        .font(.subheadline)
                        .foregroundColor(colorScheme == .dark ? .cyan : .blue)
                }
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(appointments) { appointment in
                    HStack(spacing: 16) {
                        Image(imageProvider(appointment) ?? "placeholder")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(titleProvider(appointment))
                                .font(.headline)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .lineLimit(1)
                            
                            Text(subtitleProvider(appointment))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Text(detailProvider(appointment))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(colorScheme == .dark ? Color(.systemGray5) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .shadow(color: colorScheme == .dark ? .black.opacity(0.2) : .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal)
        }
    }
}
