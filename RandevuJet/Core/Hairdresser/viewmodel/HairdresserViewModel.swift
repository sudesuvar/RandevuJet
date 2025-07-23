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
    
    func createAppointment(appointment: Appointment) async throws {
        do {
            try await repository.createAppointment(appointment)
        } catch {
            self.errorMessage = "Randevu oluşturulamadı: \(error.localizedDescription)"
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

