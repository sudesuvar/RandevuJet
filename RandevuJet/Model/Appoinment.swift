//
//  Appoinment.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation
import FirebaseFirestore

struct Appointment: Identifiable, Codable {
    var id: String
    let customerName: String
    let customerTel: String
    let salonName: String
    let serviceName: String
    let appointmentDate: String   
    let appointmentTime: String
    let status: String
    
}

