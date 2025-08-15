//
//  AdminRepository.swift
//  RandevuJet
//
//  Created by sude on 30.07.2025.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class AdminRepository {
    private let db = Firestore.firestore()
    
    // Tüm servisleri getir
    func getAllServices() async throws -> [Service] {
        let snapshot = try await db.collection("services").getDocuments()
        var services: [Service] = []
        for document in snapshot.documents {
            var service = try document.data(as: Service.self)
            service.id = document.documentID
            services.append(service)
        }
        return services
    }
    
    // ID'lere göre servisleri getir (UI'de detay lazımsa)
    func fetchServicesByIds(_ ids: [String]) async throws -> [Service] {
        var fetchedServices: [Service] = []
        for id in ids {
            let doc = try await db.collection("services").document(id).getDocument()
            if var service = try? doc.data(as: Service.self) {
                service.id = doc.documentID
                fetchedServices.append(service)
            }
        }
        return fetchedServices
    }
    
    func getHairdresserData() async throws -> HairDresser {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı giriş yapmamış."])
        }
        
        let snapshot = try await db.collection("hairdressers").document(uid).getDocument()
        guard let data = snapshot.data() else {
            throw NSError(domain: "DataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı verisi bulunamadı."])
        }
        
        let id = snapshot.documentID
        let salonName = data["salonName"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let role = data["role"] as? String ?? ""
        let address = data["address"] as? String
        let phone = data["phone"] as? String
        let photo = data["photo"] as? String
        let employeesNumber = data["employeesNumber"] as? Int
        let text = data["text"] as? String
        let status = data["status"] as? String
        let workingHours = data["workingHours"] as? [String]
        let services = data["services"] as? [String] // sadece ID listesi
        
        print("Hairdresser data fetched successfully.")
        
        return HairDresser(
            id: id,
            salonName: salonName,
            email: email,
            role: role,
            address: address,
            phone: phone,
            photo: photo,
            employeesNumber: employeesNumber,
            text: text,
            status: status,
            services: services,
            workingHours: workingHours
        )
    }
    
    
    func updateHairdresserData(
        address: String?,
        phone: String?,
        photo: String?,
        employeesNumber: Int?,
        text: String?,
        services: [String]?,
        workingStartTime: String?,
        workingEndTime: String?,
        status: String?
    ) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı giriş yapmamış."])
        }
        
        var data: [String: Any] = [:]
        
        if let address = address { data["address"] = address }
        if let phone = phone { data["phone"] = phone }
        if let photo = photo { data["photo"] = photo }
        if let employeesNumber = employeesNumber { data["employeesNumber"] = employeesNumber }
        if let text = text { data["text"] = text }
        if let services = services {
            data["services"] = services // sadece ID'ler
        }
        
        var workingHours: [String] = []
        if let start = workingStartTime { workingHours.append(start) }
        if let end = workingEndTime { workingHours.append(end) }
        if !workingHours.isEmpty {
            data["workingHours"] = workingHours
        }
        if let status = status { data["status"] = status }
        
        try await db.collection("hairdressers").document(uid).setData(data, merge: true)
    }
    
    
    func updateHairdresserProfile(
        address: String?,
        phone: String?,
        text: String?
    ) async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı giriş yapmamış."])
        }
        
        var data: [String: Any] = [:]
        if let address = address { data["address"] = address }
        if let phone = phone { data["phone"] = phone }
        if let text = text { data["text"] = text }
        
        try await db.collection("hairdressers").document(uid).setData(data, merge: true)
    }
    
    
    func getAdminAllAppointments(currentUser: HairDresser) async throws -> [Appointment] {
        let salonName = currentUser.salonName
        print(salonName)
        
        let snapshot = try await db.collection("appointments")
            .whereField("salonName", isEqualTo: salonName)
            .getDocuments()
        
        let appointments: [Appointment] = snapshot.documents.compactMap { doc in
            let data = doc.data()
            guard
                let customerName = data["customerName"] as? String,
                let customerTel = data["customerTel"] as? String,
                let salonName = data["salonName"] as? String,
                let serviceName = data["serviceName"] as? String,
                let appointmentDate = data["appointmentDate"] as? String,
                let appointmentTime = data["appointmentTime"] as? String,
                let status = data["status"] as? String
            else { return nil }
            
            return Appointment(id: doc.documentID, customerName: customerName, customerTel: customerTel, salonName: salonName, serviceName: serviceName, appointmentDate: appointmentDate, appointmentTime: appointmentTime, status: status)
        }
        
        
        print("appointments: \(appointments)")
        return appointments
    }
    
    func getAdminAllReviews(currentUser: HairDresser) async throws -> [String] {
        let salonName = currentUser.salonName
        print("📌 Aranan salon adı: \(salonName)")
        
        let snapshot = try await db.collection("appointments")
            .whereField("salonName", isEqualTo: salonName)
            .getDocuments()
        
        // Sadece review alanlarını alıyoruz
        let reviews: [String] = snapshot.documents.compactMap { doc in
            let data = doc.data()
            return data["review"] as? String
        }
        
        print("✅ Toplam \(reviews.count) yorum bulundu.")
        return reviews
    }
    
    
    /// Randevu durumunu güncelle
    func updateAppointmentStatus(appointmentId: String, newStatus: String) async throws {
        try await db.collection("appointments")
            .document(appointmentId)
            .updateData([
                "status": newStatus,
            ])
    }
    
    /// Randevuyu sil
    func deleteAppointment(appointmentId: String) async throws {
        try await db.collection("appointments")
            .document(appointmentId)
            .delete()
    }
    
    
    
    // Customer List
    func addCustomer(hairdresserId: String, customer: Customer, completion: @escaping (Error?) -> Void) {
        do {
            _ = try db.collection("hairdressers")
                .document(hairdresserId)
                .collection("customers")
                .addDocument(from: customer, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    func getCustomers(hairdresserId: String, completion: @escaping ([Customer]?, Error?) -> Void) {
        db.collection("hairdressers")
            .document(hairdresserId)
            .collection("customers")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                let customers = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Customer.self)
                }
                completion(customers, nil)
            }
    }
    
    // MARK: - Müşteri Silme
    func deleteCustomer(hairdresserId: String, customerId: String) async throws {
        try await db.collection("hairdressers")
            .document(hairdresserId)
            .collection("customers")
            .document(customerId)
            .delete()
    }
    
    
    
    
    
    
    
}
