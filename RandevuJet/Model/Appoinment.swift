//
//  Appoinment.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation

struct Appointment: Identifiable {
    let id: String
    let customerName: String
    let hairdresserName: String
    let serviceName: String
    let date: String
    let time: String
    let photo: String?
    let status: String?
    let createdAt: Date?
    
}

