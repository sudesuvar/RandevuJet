//
//  AdminViewModel.swift
//  RandevuJet
//
//  Created by sude on 30.07.2025.
//

import Foundation


class AdminViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var services: [Service] = []

    
    private let repository = AdminRepository()
    
    init() {
        Task {
       
        }
    }
    
    func fetchServices () async throws {
        do {
            let result = try await repository.getAllServices()
            self.services = result
        } catch {
            print("Debug Failed to fetch services: \(error.localizedDescription)")
            self.errorMessage = "Servisler yüklenemedi. Lütfen tekrar deneyin."
        }
        
    }
    
    
    

}


