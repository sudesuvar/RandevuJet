//
//  splashScreen.swift
//  RandevuJet
//
//  Created by sude on 16.07.2025.
//

import Foundation
import SwiftUI



struct splashScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var hairdresserViewModel: HairdresserViewModel
    @State private var animateImage = false
    @State private var animateText = false
    @State private var animateButtons = false
    
    var body: some View {
        if authViewModel.userSession != nil {
            MainTabView()
        } else {
            VStack(spacing: 20) {
                Image("splashImage")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .clipped()
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.top, 64)
                    .offset(y: animateImage ? 0 : -50)
                    .opacity(animateImage ? 1 : 0)
                    .animation(.easeOut(duration: 0.8), value: animateImage)
                
                Text("Yeni Stil, Yeni Sen !")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : -20)
                    .animation(.easeInOut(duration: 0.6).delay(0.4), value: animateText)
                
                Text("En iyi kuaförleri keşfet ve kolayca randevu al.")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(animateText ? 1 : 0)
                    .offset(y: animateText ? 0 : -20)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: animateText)
                
                VStack(spacing: 12) {
                    // Kayıt Ol NavigationLink
                    NavigationLink(destination: loginScreen(userType: .customer)
                        .environmentObject(authViewModel)
                        .environmentObject(themeViewModel)       // <-- burada veriyorsun
                        .environmentObject(hairdresserViewModel)
                    ) {
                        Text("Kullanıcı Girişi")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.yellow)
                            .cornerRadius(999)
                    }
                    .navigationBarBackButtonHidden(true)
                    
                    NavigationLink(destination: loginScreen(userType: .hairdresser)
                        .environmentObject(authViewModel)
                        .environmentObject(themeViewModel)       // <-- burada veriyorsun
                        .environmentObject(hairdresserViewModel)
                    ) {
                        Text("Kuaför Girişi")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(999)
                    }
                    
                    .navigationBarBackButtonHidden(true)
                    
                }
                .padding(.horizontal)
                .opacity(animateButtons ? 1 : 0)
                .offset(y: animateButtons ? 0 : 30)
                .animation(.easeOut(duration: 0.6).delay(1.0), value: animateButtons)
                
                Spacer(minLength: 20)
            }
            .background(Color(.systemGray6))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                animateImage = true
                animateText = true
                animateButtons = true
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .preferredColorScheme(themeViewModel.isDarkMode ? .dark : .light)
        }
    }
}




#Preview {
    splashScreen()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeViewModel())
}
