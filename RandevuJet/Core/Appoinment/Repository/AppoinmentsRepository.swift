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
    
    func updateAppointment(appointmentId: String, newDate: String, newTime: String) async throws {
        let appointmentRef = db.collection("appointments").document(appointmentId)

        do {
            try await appointmentRef.updateData([
                "appointmentDate": newDate,
                "appointmentTime": newTime
            ])
        } catch {
            print("Randevu güncelleme hatası: \(error.localizedDescription)")
            throw error
        }
    }
    
    func submitReview(appointmentId: String, review: String) async {
        do {
            try await db.collection("appointments")
                .document(appointmentId)
                .updateData([
                    "review": review
                ])
        } catch {
            print("Yorum kaydedilirken hata oluştu: \(error.localizedDescription)")
        }
    }



    
    


}
