//
//  hairdresserRegisterScreen.swift
//  RandevuJet
//
//  Created by sude on 18.07.2025.
//

import Foundation
import SwiftUI

struct hairdresserRegisterScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var salonName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isSecureField = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showLoginScreen = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                // Başlık
                VStack(spacing: 4) {
                    Image("logo")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("Yeni Üyelik Oluştur")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }

                // Kayıt Formu
                VStack(spacing: 16) {
                    TextField("İşletme Adı", text: $salonName)
                        .textFieldStyle(.plain)
                        .keyboardType(.default)
                        .autocapitalization(.words)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    // E-posta
                    TextField("E-posta", text: $email)
                        .textFieldStyle(.plain)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    // Şifre
                    HStack {
                        ZStack {
                            TextField("Şifre", text: $password)
                                .opacity(isSecureField ? 0 : 1)
                            SecureField("Şifre", text: $password)
                                .opacity(isSecureField ? 1 : 0)
                        }
                        .textFieldStyle(.plain)

                        Button(action: {
                            isSecureField.toggle()
                        }) {
                            Image(systemName: isSecureField ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 32)

                // Kayıt Butonu
                Button(action: {
                    handleRegister()
                    Task{
                        try await authViewModel.createHairDresser(withEmail: email, password: password, salonName: salonName, role: "hairdresser")
                    }
                }) {
                    Text("Kayıt Ol")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 32)
                .disabled(salonName.isEmpty || email.isEmpty || password.isEmpty)
                .opacity(salonName.isEmpty || email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                
                // Social Login Options
                VStack(spacing: 15) {
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 1)
                        
                        Text("veya")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 32)
                    
                    HStack(spacing: 20) {
                        // Google Login
                        Button(action: {
                            // Google login implementation
                        }) {
                            Image(systemName: "globe")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(25)
                        }
                        
                        // Apple Login
                        Button(action: {
                            // Apple login implementation
                        }) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(25)
                        }
                        
                        // Facebook Login
                        Button(action: {
                            // Facebook login implementation
                        }) {
                            Image(systemName: "f.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(25)
                        }
                    }
                }

                Spacer()

                // Login Sayfasına Git
                HStack {
                    Text("Zaten bir hesabın var mı?")
                        .foregroundColor(.black)
                    
                    Button("Giriş Yap") {
                        showLoginScreen = true
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                }
                .padding(.bottom, 16)
            }
            .padding(.top)
            .background(Color.white)
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showLoginScreen) {
            loginScreen(userType: .hairdresser)
        }
        .alert("Uyarı", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleRegister() {
        // Ad Soyad kontrolü
        if salonName.isEmpty {
            alertMessage = "Lütfen ad ve soyadınızı girin"
            showAlert = true
            return
        }
        
        // E-posta kontrolü
        if email.isEmpty {
            alertMessage = "Lütfen e-posta adresinizi girin"
            showAlert = true
            return
        }
        
        if !isValidEmail(email) {
            alertMessage = "Geçerli bir e-posta adresi girin"
            showAlert = true
            return
        }
        
        // Şifre kontrolü
        if password.isEmpty {
            alertMessage = "Lütfen şifrenizi girin"
            showAlert = true
            return
        }
        
        if password.count < 6 {
            alertMessage = "Şifre en az 6 karakter olmalıdır"
            showAlert = true
            return
        }
        
        // Kayıt işlemi
        alertMessage = "Kayıt başarılı! Giriş yapabilirsiniz."
        showAlert = true
        
        // Kayıt başarılı olduğunda login sayfasına yönlendir
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showLoginScreen = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Preview
struct hairdresserRegisterScreenPreview: PreviewProvider {
    static var previews: some View {
        registerScreen()
    }
}
