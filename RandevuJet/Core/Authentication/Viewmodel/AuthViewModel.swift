//
//  AuthViewModel.swift
//  RandevuJet
//
//  Created by sude on 16.07.2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore


class AuthViewModel : ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    //init
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task{
            try await fetchUserData()
        }
        
    }
    
    //sign
    func signIn(withEmail email: String, password: String) async throws {
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await fetchUserData()
        }catch{
            print("debug failed sign in:\(error.localizedDescription)")
        }
        
    }
    
    func createUser(withEmail email: String, password: String, fullName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let encoderUser = User(id: result.user.uid, nameSurname: fullName, email: email)
            try Firestore.firestore().collection("users").document(result.user.uid).setData(from: encoderUser)
            print("User saved to Firestore: \(encoderUser)")
            try await fetchUserData()
        } catch {
            print("debug failed: \(error.localizedDescription)")
        }
    }

    
    func signOut() async throws {
        do{
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            print("sign out success")
        }catch {
            print("debug failed sign out:\(error.localizedDescription)")
        }
    }
    
    func deleteUser() async throws {
        do{
            try await Auth.auth().currentUser?.delete()
            self.userSession = nil
            self.currentUser = nil
            print("delete user success")
        }catch{
            print("debug failed delete user: \(error.localizedDescription)")
        }
        
    }
    
    // Reset password
    func sendPasswordResetEmail(toEmail email: String) async throws {
        
    }
    
    @MainActor
    func fetchUserData() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument()else {return}
        do{
            self.currentUser = try snapshot.data(as: User.self)
            print("successfully fetched user data: \(String(describing: currentUser))")
        }catch {
            print("debud failed: \(error.localizedDescription)")
        }
  
        
    }
    
    
}
