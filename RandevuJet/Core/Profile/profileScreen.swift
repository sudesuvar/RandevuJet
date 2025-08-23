import Foundation
import SwiftUI
import FirebaseCrashlytics
import Firebase

struct profileScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @EnvironmentObject var languageViewModel: LanguageViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isFeedbackSheetPresented = false
    @State private var feedbackText = ""
    @State private var isFeedbackSent = false
    
    // Gradient colors
    private var profileGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemBackground),
                Color(.systemGray6).opacity(0.5)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    //
    
    var body: some View {
        if let user = authViewModel.currentUser {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Profile Header with Gradient
                    VStack(spacing: 16) {
                        Text(user.initials)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 90, height: 90)
                            .background(profileGradient)
                            .clipShape(Circle())
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 8) {
                            Text(user.nameSurname)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    
                    // Settings Section
                    VStack(spacing: 16) {
                        // Theme Setting
                        SettingRow(
                            icon: themeViewModel.isDarkMode ? "moon.fill" : "sun.max.fill",
                            iconColor: themeViewModel.isDarkMode ? .indigo : .orange,
                            title: LocalizedStringKey("theme"),
                            content: {
                                Toggle("", isOn: $themeViewModel.isDarkMode)
                                    .labelsHidden()
                                    .tint(.blue)
                            }
                        )
                        
                        // Language Setting
                        SettingRow(
                            icon: "globe",
                            iconColor: .green,
                            title: LocalizedStringKey("language"),
                            content: {
                                Picker("", selection: $languageViewModel.selectedLanguage) {
                                    ForEach(Language.allCases) { lang in
                                        Text(lang.displayName).tag(lang)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .tint(.green)
                            }
                        )
                        
                        // Version Info 
                        SettingRow(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: LocalizedStringKey("version"),
                            content: {
                                Text("1.0.0")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    // Action Buttons Section
                    VStack(spacing: 16) {
                        // Feedback Button
                        ActionButton(
                            icon: "message.fill",
                            iconColor: .blue,
                            title: LocalizedStringKey("feedback"),
                            backgroundColor: Color.blue.opacity(0.1),
                            action: { isFeedbackSheetPresented = true }
                        )
                        
                        // Logout Button
                        ActionButton(
                            icon: "rectangle.portrait.and.arrow.right",
                            iconColor: .orange,
                            title: "Çıkış Yap",
                            backgroundColor: Color.orange.opacity(0.1),
                            action: {
                                Task {
                                    do {
                                        try await authViewModel.signOut()
                                    } catch {
                                        print("Logout error: \(error)")
                                    }
                                }
                            }
                        )
                        
                        // Delete Account Button
                        ActionButton(
                            icon: "trash.fill",
                            iconColor: .red,
                            title: LocalizedStringKey("delete_account"),
                            backgroundColor: Color.red.opacity(0.1),
                            action: {
                                Task {
                                    do {
                                        try await authViewModel.deleteUser()
                                    } catch {
                                        print("Delete error: \(error)")
                                    }
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .background(backgroundGradient.ignoresSafeArea())
            .sheet(isPresented: $isFeedbackSheetPresented) {
                FeedbackSheet(
                    feedbackText: $feedbackText,
                    isFeedbackSent: $isFeedbackSent,
                    onSend: {
                        Task {
                            try await authViewModel.sendFeedback(feedback: feedbackText)
                        }
                        isFeedbackSent = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isFeedbackSheetPresented = false
                            isFeedbackSent = false
                        }
                    }
                )
            }
        } else {
            ZStack {
                backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.blue)
                    
                    Text("Profil Yükleniyor...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                Task {
                    do {
                        try await authViewModel.fetchUserData()
                        if authViewModel.currentUser == nil {
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

// Custom Setting Row Component
struct SettingRow<Content: View>: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            content()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// Custom Action Button Component
struct ActionButton: View {
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    let backgroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .shadow(color: iconColor.opacity(0.2), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Enhanced Feedback Sheet
struct FeedbackSheet: View {
    @Binding var feedbackText: String
    @Binding var isFeedbackSent: Bool
    let onSend: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey("feedback"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Görüşleriniz bizim için değerli!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mesajınız")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    TextEditor(text: $feedbackText)
                        .frame(height: 150)
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Button(action: onSend) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                            .font(.body)
                        Text(LocalizedStringKey("send"))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                if isFeedbackSent {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(LocalizedStringKey("feedback_send"))
                            .foregroundColor(.green)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}
