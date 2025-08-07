//
//  User.swift
//  RandevuJet
//
//  Created by sude on 16.07.2025.
//

import Foundation

struct User:Identifiable, Codable {
    var id: String
    var nameSurname: String
    var email: String
    var role: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: nameSurname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}


