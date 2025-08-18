//
//  HairdresserViewModel.swift
//  RandevuJet
//
//  Created by sude on 21.07.2025.
//

import Foundation
import FirebaseAnalytics

@MainActor
class HairdresserViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var hairdressers: [HairDresser] = []
    @Published var appointments: [Appointment] = []
    @Published var appointmentsWithStatus: [Appointment] = []
    
    private let repository = HairdresserRepository()
    
    init() {
        Task {
            await fetchHairdressers()
            await fetchAppointments()
        }
    }
    
    func fetchHairdressers() async {
            do {
                let result = try await repository.getAllHairdressers()
                self.hairdressers = result
                
             
                Analytics.logEvent("hairdressers_fetch", parameters: [
                    "count": result.count as NSObject
                ])
            } catch {
                print("Debug Failed to fetch hairdressers: \(error.localizedDescription)")
                self.errorMessage = "Kuaförler yüklenemedi. Lütfen tekrar deneyin."
                
            
                Analytics.logEvent("hairdressers_fetch_error", parameters: [
                    "error": error.localizedDescription as NSObject
                ])
            }
        }
    
    func fetchAppoinmentWithStatus() async {
            do {
                let result = try await repository.fetchAppointmentsByStatus("pending")
                DispatchQueue.main.async {
                    self.appointmentsWithStatus = result
                }
                Analytics.logEvent("appointments_fetch_status", parameters: [
                    "status": "pending" as NSObject,
                    "count": result.count as NSObject
                ])
            } catch {
                print("Debug Failed to fetch appointment: \(error.localizedDescription)")
                self.errorMessage = "Randevular yüklenemedi. Lütfen tekrar deneyin."
                Analytics.logEvent("appointments_fetch_status_error", parameters: [
                    "status": "pending" as NSObject,
                    "error": error.localizedDescription as NSObject
                ])
            }
        }
    
    func createAppointment(appointment: Appointment) async throws {
        do {
            let message = try await repository.createAppointment(appointment)
            print("Randevu başarılı: \(message)")
            Analytics.logEvent("appointment_create", parameters: [
                "appointment_id": appointment.id as NSObject,
            ])
            
        } catch {
            self.errorMessage = "Randevu oluşturulamadı: \(error.localizedDescription)"
            
            Analytics.logEvent("appointment_create_error", parameters: [
                "appointment_id": appointment.id as NSObject,
                "error": error.localizedDescription as NSObject
            ])
            
            throw error
        }
    }

    
    func fetchAppointments() async {
            do {
                let result = try await repository.getAllAppointments()
                self.appointments = result
                

                Analytics.logEvent("appointments_fetch", parameters: [
                    "count": result.count as NSObject
                ])
            } catch {
                print("Debug Failed to fetch appointments: \(error.localizedDescription)")
                self.errorMessage = "Randevular yüklenemedi. Lütfen tekrar deneyin."
                
    
                Analytics.logEvent("appointments_fetch_error", parameters: [
                    "error": error.localizedDescription as NSObject
                ])
            }
        }
}

