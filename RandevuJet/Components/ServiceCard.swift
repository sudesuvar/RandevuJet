//
//  ServiceCard.swift
//  RandevuJet
//
//  Created by sude on 22.07.2025.
//

import Foundation

import SwiftUI

struct ServiceCard: View {
    var title: String
    var description: String
    var price: String
    var duration: String
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    HStack {
                        Text(price)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Spacer()
                        Text(duration)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

