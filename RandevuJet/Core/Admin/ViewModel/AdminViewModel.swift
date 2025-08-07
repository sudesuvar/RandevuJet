//
//  AdminViewModel.swift
//  RandevuJet
//
//  Created by sude on 30.07.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth  // <- Bu satırı ekle




import Foundation
import FirebaseAuth

@MainActor
class AdminViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var hairdressercurrentUser: HairDresser?
    @Published var services: [Service] = []
    @Published var appointments: [Appointment] = []

    
    private let repository = AdminRepository()
    
    init() {
        Task {
            await loadInitialData()
        }
    }
    
    @MainActor
    func loadInitialData() async {
        isLoading = true
        do {
            print("Fetch services start")
            try await fetchServices()
            print("Fetch services end")
            
            print("Fetch hairdresser start")
            try await fetchHairdresserData()
            print("Fetch hairdresser end, currentUser: \(String(describing: hairdressercurrentUser))")
            
            print("Fetch appointments start")
            try await fetchAllAppointmentsForAdmin()
            print("Fetch appointments end, count: \(appointments.count)")
            isLoading = false
            print(isLoading)
        } catch {
            errorMessage = error.localizedDescription
            print("Init data load error: \(error.localizedDescription)")
        }
    }


    @MainActor
    func fetchServices() async throws {
        let result = try await repository.getAllServices()
        print(services)
        services = result
    }
    
    @MainActor
    func fetchHairdresserData() async throws {
        let user = try await repository.getHairdresserData()
        hairdressercurrentUser = user
    }
    
    @MainActor
    func fetchAllAppointmentsForAdmin() async throws {
        guard let user = hairdressercurrentUser else {
            errorMessage = "Kuaför bilgisi yok."
            return
        }
        
        let result = try await repository.getAdminAllAppointments(currentUser: user)
        self.appointments = result
    }


    func hairdresserDataUpdate(
        address: String?,
        phone: String?,
        photo: String?,
        employeesNumber: Int?,
        text: String?,
        services: [String]?,
        workingStartTime: String?,
        workingEndTime: String?,
        status: String?
    ) async {
        do {
            try await repository.updateHairdresserData(
                address: address,
                phone: phone,
                photo: photo,
                employeesNumber: employeesNumber,
                text: text,
                services: services,
                workingStartTime: workingStartTime,
                workingEndTime: workingEndTime,
                status: status
            )
            print("💾 Hairdresser bilgileri başarıyla güncellendi.")
            try await fetchHairdresserData()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Hairdresser güncelleme hatası: \(error.localizedDescription)")
        }
    }
    
    func updateHairdresserDataProfile(
        address: String?,
        phone: String?,
        text: String?
    ) async {
        do {
            try await repository.updateHairdresserProfile(
                address: address,
                phone: phone,
                text: text
            )
            print("💾 Hairdresser profil bilgileri başarıyla güncellendi.")
            try await fetchHairdresserData()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Hairdresser profil güncelleme hatası: \(error.localizedDescription)")
        }
    }
    
    func loadCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı giriş yapmamış."])
        }
        let doc = try await Firestore.firestore().collection("hairdressers").document(uid).getDocument()
        
        if let data = doc.data() {
            print("Firestore'dan gelen ham veri: \(data)")
        } else {
            print("Firestore dokümanı boş")
        }
        
        if let hairdresser = try? doc.data(as: HairDresser.self) {
            hairdressercurrentUser = hairdresser
        } else {
            print("Model decode edilemedi")
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bilgileri alınamadı."])
        }
    }
    

}
