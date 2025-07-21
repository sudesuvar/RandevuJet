//
//  HairDresser.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation

struct HairDresser:Identifiable, Codable {
    var id: String
    var salonName: String
    var email: String
    var role: String?
    var address: String?
    var phone: String?
    var photo: String?
    var employeesNumber: Int?
    var text: String?
    var createdAt: Date?
    var status: String?
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: salonName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}
