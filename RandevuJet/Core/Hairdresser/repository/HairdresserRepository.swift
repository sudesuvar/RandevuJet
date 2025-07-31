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
import FirebaseFunctions



class HairHairdresserRepository: ObservableObject {
    private let db = Firestore.firestore()
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    private lazy var functions = Functions.functions()
    
    
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
            let data = document.data()
            
            let appointment = Appointment(
                id: document.documentID,
                customerName: data["customerName"] as? String ?? "",
                customerTel: data["customerTel"] as? String ?? "",
                salonName: data["salonName"] as? String ?? "",
                serviceName: data["serviceName"] as? String ?? "",
                appointmentDate: data["appointmentDate"] as? String ?? "",
                appointmentTime: data["appointmentTime"] as? String ?? "",
                status: data["status"] as? String ?? ""
            )
            
            appointments.append(appointment)
        }

        print(appointments)
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
                let serviceIDs = data["services"] as? [String],
                let workingHours = data["workingHours"] as? [String]
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
                services: services,
                workingHours: workingHours
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
    
    
    
    func fetchAppointmentsByStatus(_ status: String) async throws -> [Appointment] {
        var appointments: [Appointment] = []
        
        let querySnapshot = try await db.collection("appointments")
            .whereField("status", isEqualTo: status)
            .getDocuments()
        
        for document in querySnapshot.documents {
            let data = document.data()
            
            let appointment = Appointment(
                id: document.documentID,
                customerName: data["customerName"] as? String ?? "",
                customerTel: data["customerTel"] as? String ?? "",
                salonName: data["salonName"] as? String ?? "",
                serviceName: data["serviceName"] as? String ?? "",
                appointmentDate: data["appointmentDate"] as? String ?? "",
                appointmentTime: data["appointmentTime"] as? String ?? "",
                status: data["status"] as? String ?? ""
            )
            print("---------------------------")
            print(appointment)
            appointments.append(appointment)
        }
        
        return appointments
    }
    
    
    
    
    
    func createAppointment(_ appointment: Appointment) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("🔥 UID boş!")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu yok"])
        }
        
        print("📅 Tarih: \(appointment.appointmentDate)")
        print("🕐 Saat: \(appointment.appointmentTime)")
        print("👤 UID: \(uid)")
        
        let data: [String: Any] = [
            "appointmentDate": appointment.appointmentDate,
            "appointmentTime": appointment.appointmentTime,
            "customerUid": uid,
            "salonName": appointment.salonName,
            "otherFields": [
                "customerName": appointment.customerName,
                "customerTel": appointment.customerTel,
                "serviceName": appointment.serviceName,
                "status": appointment.status,
            ]
        ]
        
        print("------------------------")
        print("📅 appointmentDate isEmpty: \(appointment.appointmentDate.isEmpty)")
        print("🕐 appointmentTime isEmpty: \(appointment.appointmentTime.isEmpty)")
        print(data)
        
        return try await withCheckedThrowingContinuation { continuation in
            functions.httpsCallable("checkAndCreateAppointment").call(data) { result, error in
                if let error = error {
                    print("🔥 Hata:", error.localizedDescription)
                    continuation.resume(throwing: error)
                } else if let resData = result?.data as? [String: Any],
                          let message = resData["message"] as? String,
                          let success = resData["success"] as? Bool {
                    if success {
                        continuation.resume(returning: message)
                    } else {
                        continuation.resume(throwing: NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: message]))
                    }
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Beklenmeyen yanıt"]))
                }
            }
        }
    }
    
    
}
