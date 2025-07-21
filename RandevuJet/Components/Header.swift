import Foundation
import SwiftUI

struct Header: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 90)

            Text("Tekrar Hoşgeldin!")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(colorScheme == .dark ? .white : .primary)

            Spacer()

            Button(action: {
                print("Bildirim butonuna tıklandı")
            }) {
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .gray)
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
        .shadow(color: colorScheme == .dark ? .black.opacity(0.2) : .gray.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    Header()
        .preferredColorScheme(.dark) // Dark mode önizlemesi için
}
