//
//  Service.swift
//  RandevuJet
//
//  Created by sude on 22.07.2025.
//

import Foundation

struct Service:Identifiable, Codable {
    var id: String
    var serviceTitle: String
    var serviceDesc: String
    var servicePrice: String?
    var serviceDuration: String?

}
