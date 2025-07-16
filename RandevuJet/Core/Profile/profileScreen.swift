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
                                .padding(.top, 4)
                            Text(user.email)
                                .font(.footnote)
                                .accentColor(.gray)
                        }
                    }
                }
                // Version
                Section(header: Text("Version")) {
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
                    .padding(.top, 4)
                }
                
                // logout
                Section {
                    Button(action: {
                        Task {
                            do {
                                try await authViewModel.signOut()
                            } catch {
                                print("Çıkış yaparken hata oluştu: \(error)")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.black)
                            Text("Çıkış Yap")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            
        }else{
            Text("Yükleniyor...")
                .onAppear {
                    Task {
                        do {
                            try await authViewModel.fetchUserData()
                        } catch {
                            print("Hata: \(error)")
                        }
                    }
                }        }
        
    }
}

#Preview {
    profileScreen()
}
