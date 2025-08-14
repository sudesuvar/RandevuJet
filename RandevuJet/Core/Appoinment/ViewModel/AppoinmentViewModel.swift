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
    
    func submitReview(appointmentId: String, review: String) async {
        guard !review.trimmingCharacters(in: .whitespaces).isEmpty else {
            reviewError = "Yorum boş olamaz."
            print("⚠️ Yorum boş. İşlem iptal edildi.")
            return
        }
        
        isSubmittingReview = true
        reviewError = nil
        
        do {
            try await repository.submitReview(appointmentId: appointmentId, review: review)
            print("✅ Yorum başarıyla gönderildi: \(review)")
        } catch {
            print("❌ Yorum gönderilirken hata oluştu:", error.localizedDescription)
            reviewError = error.localizedDescription
        }
        
        isSubmittingReview = false
    }


    
}


