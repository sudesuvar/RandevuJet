//
//  Customer.swift
//  RandevuJet
//
//  Created by sude on 12.08.2025.
//

import Foundation
import FirebaseFirestore


struct Customer: Identifiable, Codable {
    @DocumentID var id: String?
    var fullName: String
    var phone: String
    var notes: String?
    var createdAt: Date
}

