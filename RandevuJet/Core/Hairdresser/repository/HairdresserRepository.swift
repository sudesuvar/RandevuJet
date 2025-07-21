//
//  HairdresserRepository.swift
//  RandevuJet
//
//  Created by sude on 21.07.2025.
//

import Foundation
import Firebase
import FirebaseFirestore


class HairHairdresserRepository: ObservableObject {
    private let db = Firestore.firestore()
    
    
    /*func getAllHairdressers() async throws -> [HairDresser] {
        let snapshot = try await db.collection("hairdressers").getDocuments()
        var hairdressers: [HairDresser] = []
        
        for document in snapshot.documents {
            print(document.data())

            if let hairdresser = try? document.data(as: HairDresser.self) {
                hairdressers.append(hairdresser)
            }
        }
        print("aaaaaaaaaaaa")
        print(hairdressers)
        return hairdressers
    }*/
    
    func getAllHairdressers() async throws -> [HairDresser] {
        let snapshot = try await db.collection("hairdressers").getDocuments()
        var hairdressers: [HairDresser] = []
        
        for document in snapshot.documents {
            let data = document.data()
            print(document.data())
            
            guard
                let salonName = data["salonName"] as? String,
                let phone = data["phone"] as? String,
                let photo = data["photo"] as? String,
                let timestamp = data["createdAt"] as? Timestamp,
                let address = data["address"] as? String,
                let employeesNumber = data["employeesNumber"] as? Int,
                let text = data["text"] as? String,
                let role = data["role"] as? String,
                let status = data["status"] as? String,
                let email = data["email"] as? String
            else {
                continue
            }
            
            let hairdresser = HairDresser(
                id: document.documentID,
                salonName: salonName,
                email: email,
                role: role,
                address: address,
                phone: phone,
                photo: photo,
                employeesNumber: employeesNumber,
                text: text,
                createdAt: timestamp.dateValue(),
                status: status
            )

            
            hairdressers.append(hairdresser)
        }
        
        print("Kuaförler: \(hairdressers)")
        return hairdressers
    }


    
    
}
