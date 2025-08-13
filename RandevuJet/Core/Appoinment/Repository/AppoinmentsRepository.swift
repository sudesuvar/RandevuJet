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
    func updateAppointment(appointmentId: String, newDate: String, newTime: String) async throws {
        let appointmentRef = db.collection("appointments").document(appointmentId)

        do {
            try await appointmentRef.updateData([
                "appointmentDate": newDate,
                "appointmentTime": newTime
            ])
            print("Randevu başarıyla güncellendi.")
        } catch {
            print("Randevu güncelleme hatası: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    /*func addRewiew(review: Review) async throws {
        let reviewRef = db.collection("reviews").document()
        
        do {
            try await reviewRef.setData(from: review)
            print("Yorum başarıyla eklendi.")
        } catch {
            print("Yorum ekleme hatası: \(error.localizedDescription)")
            throw error
        }
    }*/
    
    func submitReview(appointmentId: String, review: String) async throws {
            try await db.collection("appointments")
                .document(appointmentId)
                .updateData([
                    "review": review
                ])
        }


    
    


}
