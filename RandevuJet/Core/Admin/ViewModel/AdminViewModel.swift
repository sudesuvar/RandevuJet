//
//  AdminViewModel.swift
//  RandevuJet
//
//  Created by sude on 30.07.2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseAnalytics

@MainActor
class AdminViewModel: ObservableObject {
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var hairdressercurrentUser: HairDresser?
    @Published var services: [Service] = []
    @Published var appointments: [Appointment] = []
    @Published var customers: [Customer] = []
    @Published var reviews: [String] = []
    
    
    
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
            try await fetchServices()
            try await fetchHairdresserData()
            print("Fetch hairdresser end, currentUser: \(String(describing: hairdressercurrentUser))")
            try await fetchAllAppointmentsForAdmin()
            print("Fetch appointments end, count: \(appointments.count)")
            try await fetchAllReviewsForAdmin()
            
            isLoading = false
            print(isLoading)
        } catch {
            errorMessage = error.localizedDescription
            Analytics.logEvent("admin_load_initial_data_error", parameters: [
                            "error": error.localizedDescription as NSObject
                        ])
        }
    }
    
    
    @MainActor
    func fetchServices() async throws {
        let result = try await repository.getAllServices()
        services = result
    }
    
    @MainActor
    func fetchHairdresserData() async throws {
        let user = try await repository.getHairdresserData()
        hairdressercurrentUser = user
        Analytics.logEvent("hairdresser_data_fetch", parameters: ["user_id": user.id as NSObject])
    }
    
    @MainActor
    func fetchAllAppointmentsForAdmin() async throws {
        guard let user = hairdressercurrentUser else { return }
        let result = try await repository.getAdminAllAppointments(currentUser: user)
        appointments = result
        Analytics.logEvent("appointments_fetch_admin", parameters: ["count": result.count as NSObject])
    }
    
    @MainActor
    func fetchAllReviewsForAdmin() async throws {
        guard let user = hairdressercurrentUser else { return }
        let result = try await repository.getAdminAllReviews(currentUser: user)
        reviews = result
        Analytics.logEvent("reviews_fetch_admin", parameters: ["count": result.count as NSObject])
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
            print("Hairdresser bilgileri başarıyla güncellendi.")
            try await fetchHairdresserData()
        } catch {
            errorMessage = error.localizedDescription
            print(" Hairdresser güncelleme hatası: \(error.localizedDescription)")
        }
    }
    
    func updateHairdresserDataProfile(
        address: String?,
        phone: String?,
        text: String?
    ) async {
        do {
            try await repository.updateHairdresserProfile(address: address, phone: phone, text: text)
            Analytics.logEvent("hairdresser_profile_update", parameters: ["user_id": hairdressercurrentUser?.id as NSObject? ?? "unknown"])
            try await fetchHairdresserData()
        } catch {
            errorMessage = error.localizedDescription
            Analytics.logEvent("hairdresser_profile_update_error", parameters: ["error": error.localizedDescription as NSObject])
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
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bilgileri alınamadı."])
        }
    }
    
    func updateAppointmentStatus(appointmentId: String, newStatus: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.updateAppointmentStatus(appointmentId: appointmentId, newStatus: newStatus)
            Analytics.logEvent("appointment_status_update", parameters: [
                "appointment_id": appointmentId as NSObject,
                "new_status": newStatus as NSObject
            ])
        } catch {
            errorMessage = "Durum güncellenemedi: \(error.localizedDescription)"
            Analytics.logEvent("appointment_status_update_error", parameters: [
                "appointment_id": appointmentId as NSObject,
                "error": error.localizedDescription as NSObject
            ])
        }
        isLoading = false
    }
    
    func deleteAppointment(appointmentId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            try await repository.deleteAppointment(appointmentId: appointmentId)
            Analytics.logEvent("appointment_delete", parameters: ["appointment_id": appointmentId as NSObject])
        } catch {
            errorMessage = "Randevu silinemedi: \(error.localizedDescription)"
            Analytics.logEvent("appointment_delete_error", parameters: ["appointment_id": appointmentId as NSObject, "error": error.localizedDescription as NSObject])
        }
        isLoading = false
    }
    
    
    func addCustomer(hairdresserId: String, fullName: String, phone: String, notes: String? = nil) {
            let newCustomer = Customer(
                fullName: fullName,
                phone: phone,
                notes: notes,
                createdAt: Date()
            )
            
            repository.addCustomer(hairdresserId: hairdresserId, customer: newCustomer) { error in
                if let error = error {
                    Analytics.logEvent("customer_add_error", parameters: [
                        "hairdresser_id": hairdresserId as NSObject,
                        "error": error.localizedDescription as NSObject
                    ])
                } else {
                    Analytics.logEvent("customer_add", parameters: [
                        "hairdresser_id": hairdresserId as NSObject,
                        "customer_name": fullName as NSObject
                    ])
                    self.fetchCustomers(hairdresserId: hairdresserId)
                }
            }
        }
    
    func fetchCustomers(hairdresserId: String) {
        repository.getCustomers(hairdresserId: hairdresserId) { customers, error in
            if let error = error {

                return
            }
            self.customers = customers ?? []
        }
    }
    
    func deleteCustomer(hairdresserId: String, customerId: String) async {
           do {
               try await repository.deleteCustomer(hairdresserId: hairdresserId, customerId: customerId)
               self.customers.removeAll { $0.id == customerId }
               Analytics.logEvent("customer_delete", parameters: [
                   "hairdresser_id": hairdresserId as NSObject,
                   "customer_id": customerId as NSObject
               ])
           } catch {
               print("Müşteri silme hatası: \(error)")
               Analytics.logEvent("customer_delete_error", parameters: [
                   "hairdresser_id": hairdresserId as NSObject,
                   "customer_id": customerId as NSObject,
                   "error": error.localizedDescription as NSObject
               ])
           }
       }
    
    
    
}
