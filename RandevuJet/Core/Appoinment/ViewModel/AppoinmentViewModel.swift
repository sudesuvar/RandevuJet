//
//  AppoinmentViewModel.swift
//  RandevuJet
//
//  Created by sude on 26.07.2025.
//

import Foundation
import FirebaseAnalytics

@MainActor
class AppoinmentViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isUpdating = false
    @Published var updateError: String?
    @Published var reviewText: String = ""
        @Published var isSubmittingReview = false
        @Published var reviewError: String? = nil
        
    
    private let repository = AppoinmentsRepository()
    

    func updateAppointment(appointmentId: String, newDate: String, newTime: String) async {
        isUpdating = true
        updateError = nil
        
        do {
            try await repository.updateAppointment(appointmentId: appointmentId, newDate: newDate, newTime: newTime)
            Analytics.logEvent("appointment_update", parameters: [
                            "appointment_id": appointmentId as NSObject,
                            "new_date": newDate as NSObject,
                            "new_time": newTime as NSObject,
                            "method": "app" as NSObject
                        ])
        } catch {
            updateError = error.localizedDescription
            Analytics.logEvent("appointment_update_error", parameters: [
                           "appointment_id": appointmentId as NSObject,
                           "error": error.localizedDescription as NSObject
                       ])
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
            Analytics.logEvent("review_submit", parameters: [
                            "appointment_id": appointmentId as NSObject,
                            "review_length": review.count as NSObject
                        ])
        } catch {
            print("❌ Yorum gönderilirken hata oluştu:", error.localizedDescription)
            reviewError = error.localizedDescription
            Analytics.logEvent("review_submit_error", parameters: [
                            "appointment_id": appointmentId as NSObject,
                            "error": error.localizedDescription as NSObject
                        ])
        }
        
        isSubmittingReview = false
    }


    
}


