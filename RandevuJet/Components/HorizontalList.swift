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
        VStack(alignment: .leading) {
            HStack {
                Text("Kuaförler")
                    .font(.title2)
                    .fontWeight(.bold)

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
        VStack {
            Image(hairdresser.photo ?? "placeholder_image") // varsayılan resim adı
                .resizable()
                .frame(width: 120, height: 120)
                .cornerRadius(12)
                .shadow(radius: 3)
            
            Text(hairdresser.salonName ?? "Bilinmeyen Salon")
                .font(.headline)
            
            Text(hairdresser.text ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 140)
        .padding(.vertical)
    }
}



