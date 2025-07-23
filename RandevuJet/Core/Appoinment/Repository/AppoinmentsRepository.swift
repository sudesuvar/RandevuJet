//
//  AppoinmentsRepository.swift
//  RandevuJet
//
//  Created by sude on 23.07.2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth



class AppoinmentsRepository: ObservableObject {
    private let db = Firestore.firestore()
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    

    /*func getAllAppointments() async throws -> [Appointment] {
        
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await db.collection("appointments")
            .whereField("customerUid", isEqualTo: uid)
            .getDocuments()
        
        var appointments: [Appointment] = []
        
        for document in snapshot.documents {
            if let appointment = try? document.data(as: Appointment.self) {
                appointments.append(appointment)
            }
        }

        return appointments
    }*/

    
    


}
