//
//  AppoinmentViewModel.swift
//  RandevuJet
//
//  Created by sude on 26.07.2025.
//

import Foundation

class AppoinmentViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isUpdating = false
    @Published var updateError: String?
    
    private let repository = AppoinmentsRepository()
    
    init() {
        Task {
            
        }
    }

    func updateAppointment(appointmentId: String, newDate: String, newTime: String) async {
        isUpdating = true
        updateError = nil
        
        do {
            try await repository.updateAppointment(appointmentId: appointmentId, newDate: newDate, newTime: newTime)
        } catch {
            updateError = error.localizedDescription
        }
        
        isUpdating = false
    }
    
    
}


