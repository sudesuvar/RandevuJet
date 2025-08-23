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
import FirebaseFunctions

@MainActor
class AuthViewModel : ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var currentHairdresser: HairDresser?
    @Published var currentRole: String? = nil
    @Published var isLoading: Bool = true
    
    
    
    //init
    init() {
        self.userSession = Auth.auth().currentUser
        Task {
            if userSession != nil {
                try await fetchUserOrHairdresserData()
            }
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    
    //sign
    func signIn(withEmail email: String, password: String) async throws {
        do {
            AppLogger.auth.info("Kullanıcı giriş yapmaya çalışıyor. Email: \(email, privacy: .public)")
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            try await fetchUserOrHairdresserData()
    
        } catch {
            print("debug failed sign in:\(error.localizedDescription)")
            AppLogger.auth.error("Giriş başarısız: \(error.localizedDescription)")
            throw error
            //
        }
        
    }
    
    func createHairDresser(withEmail email: String, password: String, salonName: String, role: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let newHairdresser = HairDresser(id: result.user.uid, salonName: salonName, email: email, role: role)
            AppLogger.auth.info("Kuaför oluşturuluyor. Email: \(newHairdresser.salonName, privacy: .public)")
            try Firestore.firestore()
                .collection("hairdressers")
                .document(result.user.uid)
                .setData(from: newHairdresser)
            try await fetchUserOrHairdresserData()
            
        } catch {
            AppLogger.auth.error("Debug Failed to create hairdresser: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    func createUser(withEmail email: String, password: String, fullName: String, role: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let encoderUser = User(id: result.user.uid, nameSurname: fullName, email: email, role: role)
            AppLogger.auth.info("Kullanıcı oluşturuluyor. Email: \(encoderUser.email , privacy: .public)")
            try Firestore.firestore().collection("users").document(result.user.uid).setData(from: encoderUser)
            try await fetchUserOrHairdresserData()
        } catch {
            AppLogger.auth.error("Debug Failed to create user: \(error.localizedDescription)")
        }
    }
    
    
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            self.currentHairdresser = nil
            self.currentRole = nil
        } catch {
            AppLogger.auth.error("Debug Failed to sign out: \(error.localizedDescription)")
            throw error
        }
    }
    
    func deleteUser() async throws {
        do{
            try await Auth.auth().currentUser?.delete()
            self.userSession = nil
            self.currentUser = nil
        }catch{
            AppLogger.auth.error("Debug Failed to delete User: \(error.localizedDescription)")
        }
        
    }
    
    // Reset password
    func sendPasswordResetEmail(toEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            AppLogger.auth.info("Debug Password reset email sent successfully")
        }catch{
            AppLogger.auth.error("debug failed send password reset email: \(error.localizedDescription)")
        }
        
    }
    
    @MainActor
    func fetchUserData() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            AppLogger.auth.error("Debug Failed to get current user uid")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            guard snapshot.exists else {
                AppLogger.auth.error("Debug Failed to get user document")
                return
            }
            let data = snapshot.data()
            
            self.currentUser = try snapshot.data(as: User.self)
            self.currentRole = self.currentUser?.role
            AppLogger.auth.info("Debug successfully fetched user data")
        } catch {
            AppLogger.auth.error("debug fetch user data: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func fetchHairdresserData() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            AppLogger.auth.error("Debug Failed to get current user uid")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore().collection("hairdressers").document(uid).getDocument()
            guard snapshot.exists else {
                AppLogger.auth.error("Debug Failed to get current user data")
                return
            }
            let data = snapshot.data()
            self.currentHairdresser = try snapshot.data(as: HairDresser.self)
            self.currentRole = self.currentHairdresser?.role
        } catch {
            AppLogger.auth.error("debug fetch hairdresser data: \(error.localizedDescription)")
        }
    }
    
    
    
    func sendFeedback(feedback: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do{
            try await Firestore.firestore().collection("feedback").addDocument(data: ["uid": uid, "feedback": feedback, "createdAt" : Timestamp(date: Date())])
            AppLogger.auth.info("send feedback success")
        }catch{
            AppLogger.auth.error("debug fetch send feedback: \(error.localizedDescription)")
            
        }
    }
    
    @MainActor
    func updateRoleAfterFetch() {
        if let user = currentUser {
            currentRole = user.role
        } else if let hairdresser = currentHairdresser {
            currentRole = hairdresser.role
        } else {
            currentRole = nil
        }
    }
    
    @MainActor
    func fetchUserOrHairdresserData() async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let uid = userSession?.uid else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu bulunamadı."])
        }
        
        let userRef = Firestore.firestore().collection("users").document(uid)
        let hairdresserRef = Firestore.firestore().collection("hairdressers").document(uid)
        
        do {
            let userDoc = try await userRef.getDocument()
            if userDoc.exists {
                if let userData = userDoc.data() {
                    //print("[fetchUserOrHairdresserData] Kullanıcı verisi Firestore'dan geldi: \(userData)")
                    AppLogger.auth.info("fetch user data")
                } else {
                    //print("[fetchUserOrHairdresserData] Kullanıcı dokümanında veri yok.")
                }
                do {
                    self.currentUser = try userDoc.data(as: User.self)
                    self.currentRole = "customer"
                    //print("[fetchUserOrHairdresserData] Kullanıcı decode edildi: \(String(describing: currentUser))")
                    return
                } catch {
               //     print("[fetchUserOrHairdresserData] Kullanıcı decode hatası: \(error)")
                    throw error
                }
            } else {
             //   print("[fetchUserOrHairdresserData] Kullanıcı dokümanı bulunamadı.")
            }
        } catch {
           // print("[fetchUserOrHairdresserData] Kullanıcı verisi alınırken hata: \(error)")
            throw error
        }
        
        do {
           // print("[fetchUserOrHairdresserData] Kuaför verisi sorgulanıyor: hairdressers/\(uid)")
            let hairdresserDoc = try await hairdresserRef.getDocument()
            
            if hairdresserDoc.exists {
                if let hairdresserData = hairdresserDoc.data() {
                    //print("[fetchUserOrHairdresserData] Kuaför verisi Firestore'dan geldi: \(hairdresserData)")
                } else {
                    //print("[fetchUserOrHairdresserData] Kuaför dokümanında veri yok.")
                }
                
                do {
                    self.currentHairdresser = try hairdresserDoc.data(as: HairDresser.self)
                    self.currentRole = "hairdresser"
                    //print("[fetchUserOrHairdresserData] Kuaför decode edildi: \(String(describing: currentHairdresser))")
                    return
                } catch {
                    //print("[fetchUserOrHairdresserData] Kuaför decode hatası: \(error)")
                    throw error
                }
            } else {
            }
        } catch {
            throw error
        }
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bilgileri alınamadı."])
    }
    
    func checkIfEmailExists(_ email: String, completion: @escaping (Bool) -> Void) {
        let function = Functions.functions().httpsCallable("checkEmailExists")
        function.call(["email": email]) { result, error in
            if let error = error {
                print("Function error: \(error)")
                completion(false)
                return
            }
            
            if let data = result?.data as? [String: Any],
               let exists = data["exists"] as? Bool {
                completion(exists)
            } else {
                completion(false)
            }
        }
    }
}
