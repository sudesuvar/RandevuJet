//
//  HorizontalList.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation
import SwiftUI

struct HorizontalList: View {
    let hairdressers: [HairDresser]
    var onShowAllTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Kuaförler")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: {
                    onShowAllTapped()
                }) {
                    Text("Hepsini Göster")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(hairdressers) { hairdresser in
                        HairdresserRow(hairdresser: hairdresser)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct HairdresserRow: View {
    let hairdresser: HairDresser

    var body: some View {
        VStack(spacing: 8) {
            Image(hairdresser.photo ?? "placeholder_image")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack(spacing: 8) {
                Text(hairdresser.salonName ?? "Bilinmeyen Salon")
                    .font(.headline)
                    .lineLimit(1)
                
                Text(hairdresser.text ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 140)
        .padding(.vertical, 4)
    }
}
