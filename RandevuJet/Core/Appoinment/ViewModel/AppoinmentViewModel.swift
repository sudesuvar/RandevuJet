//
//  AppoinmentViewModel.swift
//  RandevuJet
//
//  Created by sude on 26.07.2025.
//

import Foundation

@MainActor
class AppoinmentViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isUpdating = false
    @Published var updateError: String?
    @Published var reviewText: String = ""
        @Published var isSubmittingReview = false
        @Published var reviewError: String? = nil
        
    
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
    
    func submitReview(appointmentId: String) async {
            guard !reviewText.trimmingCharacters(in: .whitespaces).isEmpty else {
                reviewError = "Yorum boş olamaz."
                return
            }
            
            isSubmittingReview = true
            reviewError = nil
            
            do {
                try await repository.submitReview(appointmentId: appointmentId, review: reviewText)
                reviewText = ""
            } catch {
                reviewError = error.localizedDescription
            }
            
            isSubmittingReview = false
        }
    
    
}


