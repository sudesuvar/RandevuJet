//
//  loginScreen.swift
//  RandevuJet
//
//  Created by sude on 16.07.2025.
//

import Foundation
import SwiftUI

enum UserType {
    case customer
    case hairdresser
    case null
}

struct loginScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    var userType: UserType
    @State private var email = ""
    @State private var password = ""
    @State private var showForgotPassword = false
    @State private var isSecureField = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Başlık
            VStack(spacing: 4) {
                if(themeViewModel.isDarkMode){
                    Image("darklogo")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    //
                }else{
                    Image("logo")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                }
                Text("Giriş Yap")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            // Giriş Formu
            VStack(spacing: 16) {
                // E-posta
                TextField("E-posta", text: $email)
                    .textFieldStyle(.plain)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.secondarySystemBackground))
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
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                // Şifremi Unuttum
                HStack {
                    Spacer()
                    Button("Şifremi Unuttum") {
                        showForgotPassword = true
                    }
                    .font(.footnote)
                    .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 32)
            
            // Giriş Butonu
            Button(action: {
                //handleLogin()
                Task{
                    try await authViewModel.signIn(withEmail: email, password: password)
                }
                
            }) {
                Text("Giriş Yap")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.yellow)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 32)
            .disabled(email.isEmpty || password.isEmpty)
            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
            
            // Social Login Options
            VStack(spacing: 15) {
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 1)
                    
                    Text("veya")
                        .foregroundColor(.secondary)
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
                            .background(Color(.red))
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
                            .background(Color(.black))
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
                            .background(Color(.blue))
                            .background(.primary)
                            .cornerRadius(25)
                    }
                    
                }
                
                Spacer()
                
                // Kayıt Ol
                HStack {
                    Text("Hesabın yok mu ?")
                        .foregroundColor(.secondary)
                    NavigationLink(destination: {
                        if userType == .customer {
                            registerScreen()
                                .navigationBarBackButtonHidden(true)

                        } else {
                            hairdresserRegisterScreen()
                                .navigationBarBackButtonHidden(true)
                        }
                    }) {
                        Text("Kayıt Ol")
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                    }
                    
                }
                .padding(.bottom, 16)
            }
            .padding(.top)
            .background(Color(.systemBackground))
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
        .alert("Uyarı", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleLogin() {
        if email.isEmpty || password.isEmpty {
            alertMessage = "Lütfen tüm alanları doldurun"
            showAlert = true
            return
        }
        
        if !isValidEmail(email) {
            alertMessage = "Geçerli bir e-posta adresi girin"
            showAlert = true
            return
        }
        
        // Login logic here
        alertMessage = "Giriş başarılı!"
        showAlert = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var showSuccessMessage = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 15) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("Şifremi Unuttum")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Şifrenizi sıfırlamak için e-posta adresinizi girin. Size şifre sıfırlama bağlantısı göndereceğiz.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Email Input
                VStack(alignment: .leading, spacing: 10) {
                    Text("E-posta Adresi")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.black)
                            .frame(width: 20)
                        
                        TextField("E-posta adresinizi girin", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                
                // Success Message
                if showSuccessMessage {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("Şifre sıfırlama e-postası gönderildi!")
                            .font(.body)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                }
                
                // Send Button
                Button(action: {
                    Task {
                        try await authViewModel.sendPasswordResetEmail(toEmail: email)
                        handleForgotPassword()
                        //sudesuvar51@gmail.com
                    }
                }) {
                    Text("Gönder")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.yellow)
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty)
                .opacity(email.isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 30)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Uyarı", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleForgotPassword() {
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
        
        // Forgot password logic here
        showSuccessMessage = true
        
        // Auto dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismiss()
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Preview
struct loginScreenPreview: PreviewProvider {
    static var previews: some View {
        loginScreen(userType: .null)
    }
}
