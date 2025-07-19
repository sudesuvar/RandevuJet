//
//  profileScreen.swift
//  RandevuJet
//
//  Created by sude on 16.07.2025.
//

import Foundation
import SwiftUI

struct profileScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    var body: some View {
        
        if let user = authViewModel.currentUser {
            List {
                Section() {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.gray)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4){
                            Text(user.nameSurname)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 2)
                            Text(user.email)
                                .font(.footnote)
                                .accentColor(.gray)
                        }
                    }
                }
                //theme
                Section() {
                    HStack {
                        Image(systemName: themeViewModel.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(.gray)
                        
                        Text("Tema")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Toggle("", isOn: $themeViewModel.isDarkMode)
                            .labelsHidden()
                        //
                    }
                }
                
                // language
                Section {
                    HStack {
                        Text("🌐")
                            .font(.title2)
                        
                        // DEĞİŞECEK
                        Text("Uygulama Dili")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        // Toggle
                        Toggle(isOn: .constant(false)) {
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .black))
                    }
                    
                }
                
                
                // Version
                Section() {
                    HStack(alignment: .center, spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                        
                        Text("Version")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                
                
                // logout
                Section {
                    HStack(alignment: .center, spacing: 8) {
                        Button(action: {
                            Task {
                                do {
                                    try await authViewModel.signOut()
                                } catch {
                                    print("Debug Failed logout: \(error)")
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.gray)
                                Text("Çıkış Yap")
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                // delete user
                Section {
                    Button(action: {
                        Task {
                            do {
                                try await authViewModel.deleteUser()
                            } catch {
                                print("Debug Failed delete user: \(error)")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.gray)
                            Text("Hesabını Sil")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .listSectionSpacing(16)
            //.listRowInsets(EdgeInsets(top: 0, leading: 5, bottom: 8, trailing: 8))
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color(.systemGroupedBackground))
        }
        else{
            ProgressView()
                .onAppear {
                    Task {
                        do {
                            try await authViewModel.fetchUserData()
                        } catch {
                            print("Error fetching user data: \(error)")
                        }
                    }
                }
        }
        
        
    }
}

#Preview {
    profileScreen()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeViewModel())
}
