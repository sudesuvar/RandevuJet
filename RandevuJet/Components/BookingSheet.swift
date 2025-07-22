//
//  BookingSheet.swift
//  RandevuJet
//
//  Created by sude on 22.07.2025.
//

import Foundation
import SwiftUI

struct BookingSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Randevu Al")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                Text("Randevu alma ekranı burada olacak")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}
#Preview {
    BookingSheet()
}
