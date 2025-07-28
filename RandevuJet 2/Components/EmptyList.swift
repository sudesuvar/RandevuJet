//
//  EmptyList.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation
import SwiftUI

struct EmptyList: View {
    let title: String
    let message: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        message: String,
        systemImage: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

// MARK: - Convenience initializers for different empty states
extension EmptyList {
    static func appointments(action: (() -> Void)? = nil) -> EmptyList {
        EmptyList(
            title: "Henüz randevunuz yok",
            message: "İlk randevunuzu oluşturmak için bir kuaför seçin",
            systemImage: "calendar.badge.plus",
            actionTitle: action != nil ? "Randevu Al" : nil,
            action: action
        )
    }
    
    static func hairdressers(action: (() -> Void)? = nil) -> EmptyList {
        EmptyList(
            title: "Kuaför bulunamadı",
            message: "Aradığınız kriterlere uygun kuaför bulunmuyor",
            systemImage: "scissors",
            actionTitle: action != nil ? "Filtreleri Temizle" : nil,
            action: action
        )
    }
    
    static func favorites(action: (() -> Void)? = nil) -> EmptyList {
        EmptyList(
            title: "Favori listeniz boş",
            message: "Beğendiğiniz kuaförleri favorilere ekleyebilirsiniz",
            systemImage: "heart",
            actionTitle: action != nil ? "Kuaförleri Keşfet" : nil,
            action: action
        )
    }
}


struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            EmptyList.appointments {
                print("Randevu al tapped")
            }
            
            Divider()
            
            EmptyList.hairdressers()
            
            Divider()
            
            EmptyList.favorites()
        }
    }
}
