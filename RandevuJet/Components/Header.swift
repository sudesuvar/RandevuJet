//
//  Header.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation
import SwiftUI


struct Header: View {
    var body: some View {
        HStack(spacing: 16) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 90)

            Text("Tekrar Hoşgeldin!")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            Spacer()

            Button(action: {
                print("Bildirim butonuna tıklandı")
            }) {
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
        .shadow(color: .gray.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}


#Preview {
    Header()
}
