//
//  HairdresserRepository.swift
//  RandevuJet
//
//  Created by sude on 21.07.2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth



class HairHairdresserRepository: ObservableObject {
    private let db = Firestore.firestore()
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    
    /*func getAllHairdressers() async throws -> [HairDresser] {
     let snapshot = try await db.collection("hairdressers").getDocuments()
     var hairdressers: [HairDresser] = []
     
     for document in snapshot.documents {
     print(document.data())
     
     if let hairdresser = try? document.data(as: HairDresser.self) {
     hairdressers.append(hairdresser)
     }
     }
     print("aaaaaaaaaaaa")
     print(hairdressers)
     return hairdressers
     }*/
    
    func getAllAppointments() async throws -> [Appointment] {
        
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
    }

    
    func getAllHairdressers() async throws -> [HairDresser] {
        let snapshot = try await db.collection("hairdressers").getDocuments()
        var hairdressers: [HairDresser] = []
        
        for document in snapshot.documents {
            let data = document.data()
            print(document.data())
            
            guard
                let salonName = data["salonName"] as? String,
                let phone = data["phone"] as? String,
                let photo = data["photo"] as? String,
                let timestamp = data["createdAt"] as? Timestamp,
                let address = data["address"] as? String,
                let employeesNumber = data["employeesNumber"] as? Int,
                let text = data["text"] as? String,
                let role = data["role"] as? String,
                let status = data["status"] as? String,
                let email = data["email"] as? String,
                let serviceIDs = data["services"] as? [String]
            else {
                continue
            }
            let services = try await fetchServicesByIds(serviceIDs)
            
            let hairdresser = HairDresser(
                id: document.documentID,
                salonName: salonName,
                email: email,
                role: role,
                address: address,
                phone: phone,
                photo: photo,
                employeesNumber: employeesNumber,
                text: text,
                createdAt: timestamp.dateValue(),
                status: status,
                services: services
            )
            
            
            hairdressers.append(hairdresser)
        }
        
        print("Kuaförler: \(hairdressers)")
        return hairdressers
    }
    
    private func fetchServicesByIds(_ ids: [String]) async throws -> [Service] {
        var services: [Service] = []
        
        for id in ids {
            let docRef = db.collection("services").document(id)
            let document = try await docRef.getDocument()
            
            if let data = document.data() {
                let service = Service(
                    id: document.documentID,
                    serviceTitle: data["serviceTitle"] as? String ?? "",
                    serviceDesc: data["serviceDesc"] as? String ?? "",
                    servicePrice: data["servicePrice"] as? String,
                    serviceDuration: data["serviceDuration"] as? String
                )
                services.append(service)
            }
        }
        return services
    }
    
    func createAppointment(_ appointment: Appointment) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu yok"])
        }
        
        let docRef = db.collection("appointments").document()
        try await docRef.setData([
            "customerUid": uid,
            "salonName": appointment.salonName,
            "customerName": appointment.customerName,
            "customerTel": appointment.customerTel,
            "serviceName": appointment.serviceName,
            "status": appointment.status,
            "appointmentDate": appointment.appointmentDate,
            "appointmentTime": appointment.appointmentTime,
            "createdAt": FieldValue.serverTimestamp(),
        ])
    }


}
