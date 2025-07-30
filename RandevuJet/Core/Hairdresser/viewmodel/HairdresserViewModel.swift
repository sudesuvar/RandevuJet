//
//  HairdresserViewModel.swift
//  RandevuJet
//
//  Created by sude on 21.07.2025.
//

import Foundation

class HairdresserViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var hairdressers: [HairDresser] = []
    @Published var appointments: [Appointment] = []
    @Published var appointmentsWithStatus: [Appointment] = []
    
    private let repository = HairHairdresserRepository()
    
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
        } catch {
            print("Debug Failed to fetch hairdressers: \(error.localizedDescription)")
            self.errorMessage = "Kuaförler yüklenemedi. Lütfen tekrar deneyin."
        }
    }
    
    func fetchAppoinmentWithStatus() async {
        do {
            let result = try await repository.fetchAppointmentsByStatus("pending")
            DispatchQueue.main.async {
                self.appointmentsWithStatus = result
                    }
        } catch {
            print("Debug Failed to fetch appointment: \(error.localizedDescription)")
            self.errorMessage = "Randevular yüklenemedi. Lütfen tekrar deneyin."
        }
    }
    
    func createAppointment(appointment: Appointment) async throws {
        do {
            let message = try await repository.createAppointment(appointment)
            print("Randevu başarılı: \(message)")
        } catch {
            self.errorMessage = "Randevu oluşturulamadı: \(error.localizedDescription)"
            throw error
        }
    }

    
    func fetchAppointments() async{
        do {
            let result = try await repository.getAllAppointments()
            self.appointments = result
        } catch {
            print("Debug Failed to fetch appointments: \(error.localizedDescription)")
            self.errorMessage = "Randevular yüklenemedi. Lütfen tekrar deneyin."
        }
    }
}

