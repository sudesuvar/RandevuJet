import SwiftUI

struct registerScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    @State private var nameSurname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var role = ""
    @State private var isSecureField = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showLoginScreen = false
    
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
                Text("Yeni Üyelik Oluştur")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            
            // Kayıt Formu
            VStack(spacing: 16) {
                TextField("Ad Soyad", text: $nameSurname)
                    .textFieldStyle(.plain)
                    .keyboardType(.default)
                    .autocapitalization(.words)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("E-posta", text: $email)
                    .textFieldStyle(.plain)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
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
            
            // Kayıt Ol Butonu
            Button(action: {
                handleRegister()
                Task {
                    try await authViewModel.createUser(withEmail: email, password: password, fullName: nameSurname, role: "customer")
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
            .disabled(nameSurname.isEmpty || email.isEmpty || password.isEmpty)
            .opacity(nameSurname.isEmpty || email.isEmpty || password.isEmpty ? 0.6 : 1)
            
            // Sosyal Giriş
            VStack(spacing: 15) {
                HStack {
                    Rectangle().fill(Color.gray.opacity(0.5)).frame(height: 1)
                    Text("veya").foregroundColor(.black).font(.system(size: 14))
                    Rectangle().fill(Color.gray.opacity(0.5)).frame(height: 1)
                }
                .padding(.horizontal, 32)
                
                HStack(spacing: 20) {
                    ForEach(["globe", "apple.logo", "f.circle.fill"], id: \.self) { icon in
                        Button(action: {}) {
                            Image(systemName: icon)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(icon == "globe" ? .red : icon == "apple.logo" ? .black : .blue)
                                .cornerRadius(25)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Giriş ekranına geçiş
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
        .fullScreenCover(isPresented: $showLoginScreen) {
            loginScreen(userType: .customer)
                .environmentObject(authViewModel)
                .environmentObject(themeViewModel)
                .environmentObject(hairdresserViewModel)
        }
        
        .alert("Uyarı", isPresented: $showAlert) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleRegister() {
        if nameSurname.isEmpty {
            alertMessage = "Lütfen ad ve soyadınızı girin"
            showAlert = true
            return
        }
        
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
        
        alertMessage = "Kayıt başarılı! Giriş yapabilirsiniz."
        showAlert = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showLoginScreen = true
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}

// Preview
struct registerScreen_Previews: PreviewProvider {
    static var previews: some View {
        registerScreen()
    }
}
