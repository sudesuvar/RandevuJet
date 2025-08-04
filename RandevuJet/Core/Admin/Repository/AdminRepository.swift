//
//  AdminRepository.swift
//  RandevuJet
//
//  Created by sude on 30.07.2025.
//

import Foundation

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseFunctions



class AdminRepository: ObservableObject {
    private let db = Firestore.firestore()
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    private lazy var functions = Functions.functions()

    
    
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
    
    func getAllServices() async throws -> [Service] {
        let snapshot = try await db.collection("services").getDocuments()
        var services: [Service] = []
        
        for document in snapshot.documents {
            print(document.data())
            
            if let service = try? document.data(as: Service.self) {
                services.append(service)
            }
        }
        print(services)
        return services
    }
    
    // hairdresser information
    func hairdresserDataUpdate() async throws  {
  
    }
    
    

    
    
}

