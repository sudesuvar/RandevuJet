import Foundation
import SwiftUI

struct profileScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var languageViewModel: LanguageViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isFeedbackSheetPresented = false
    @State private var feedbackText = ""
    @State private var isFeedbackSent = false




    var body: some View {
        if let user = authViewModel.currentUser {
            ScrollView {
                VStack(spacing: 16) {
                    // PROFİL
                    HStack(spacing: 16) {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.gray)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.nameSurname)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // TEMA
                    HStack {
                        Image(systemName: themeViewModel.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(.gray)
                        Text("theme".localized(using: languageViewModel))
                            .font(.subheadline)
                        Spacer()
                        Toggle("", isOn: $themeViewModel.isDarkMode)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // DİL
                    HStack {
                        Text("🌐")
                            .font(.title2)
                        Text(String(localized: "welcome"))
                        Text("Dil")
                            .font(.subheadline)
                        Spacer()
                        Picker("", selection: $languageViewModel.selectedLanguage) {
                            ForEach(Language.allCases) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Test için bir button
                                Button("Test Değişiklik") {
                                    print("Seçili Dil:", languageViewModel.selectedLanguage.rawValue)
                                }


                    // VERSION
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        Text("Version")
                            .font(.subheadline)
                        Spacer()
                        Text("1.0.0")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // ÇIKIŞ YAP
                    Button(action: {
                        Task {
                            do {
                                try await authViewModel.signOut()
                            } catch {
                                print("Logout error: \(error)")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.gray)
                            Text("Çıkış Yap")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // HESABI SİL
                    Button(action: {
                        Task {
                            do {
                                try await authViewModel.deleteUser()
                            } catch {
                                print("Delete error: \(error)")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.gray)
                            Text("Hesabını Sil")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Geri Bildirim Butonu
                    Button(action: {
                        isFeedbackSheetPresented = true
                    }) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .foregroundColor(.gray)
                            Text("Geri Bildirim")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $isFeedbackSheetPresented) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Geri Bildirim")
                                .font(.title2)
                                .bold()

                            TextEditor(text: $feedbackText)
                                .frame(height: 150)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            Button(action: {
                                Task{
                                    try await authViewModel.sendFeedback(feedback: feedbackText)
                                }
                                isFeedbackSent = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isFeedbackSheetPresented = false
                                    isFeedbackSent = false
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Gönder")
                                        .fontWeight(.semibold)
                                        .padding()
                                    Spacer()
                                }
                                .background(Color.yellow)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }

                            if isFeedbackSent {
                                Text("Teşekkürler! Geri bildiriminiz gönderildi.")
                                    .foregroundColor(.green)
                            }

                            Spacer()
                        }
                        .padding()
                    }

                    
                

                }
          
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        } else {
            ProgressView()
                .onAppear {
                    Task {
                            do {
                                try await authViewModel.fetchUserData()
                                if authViewModel.currentUser == nil {
                                    print("Firestore’da kullanıcı yok, çıkış yapılıyor...")
                                    try await authViewModel.signOut()
                                }
                            } catch {
                                print("Kullanıcı verisi alınamadı: \(error)")
                                do {
                                    try await authViewModel.signOut()
                                } catch {
                                    print("Sign out hatası: \(error)")
                                }
                            }
                        }
                }
        }
    }
}
