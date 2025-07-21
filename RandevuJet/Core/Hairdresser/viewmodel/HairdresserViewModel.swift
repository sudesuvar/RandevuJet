//
//  HairdresserViewModel.swift
//  RandevuJet
//
//  Created by sude on 21.07.2025.
//

import Foundation

class HairdresserViewModel: ObservableObject {
    @Published var hairdressers: [HairDresser] = []
    @Published var errorMessage: String?

    private let repository = HairHairdresserRepository()
    
    init() {
           Task {
               await fetchHairdressers()
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
}

