//
//  ReviewCard.swift
//  RandevuJet
//
//  Created by sude on 22.07.2025.
//

import Foundation
import SwiftUI

struct ReviewCard: View {
    var name: String
    var rating: Int
    var comment: String
    var date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.headline)
                Spacer()
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            HStack(spacing: 4) {
                ForEach(0..<rating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                ForEach(0..<(5 - rating), id: \.self) { _ in
                    Image(systemName: "star")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }

            Text(comment)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
