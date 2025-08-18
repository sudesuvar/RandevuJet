import Foundation
import SwiftUI

struct Header: View {
    @EnvironmentObject var themeViewModel: ThemeViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var isNotificationPressed = false

    var body: some View {
        HStack(spacing: 20) {
            // Logo Section
            /*Group {
                if themeViewModel.isDarkMode {
                    Image("darklogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 90)
                } else {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 90)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)*/
            
            // Welcome Text Section
            VStack(alignment: .leading, spacing: 4) {
                Text("Tekrar Hoşgeldin!")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
                
                Text("Güzel bir gün geçir! ✨")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .secondary)
            }

            Spacer()

            // Notification Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isNotificationPressed.toggle()
                }
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                print("Bildirim butonuna tıklandı")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isNotificationPressed = false
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    colorScheme == .dark ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1),
                                    colorScheme == .dark ? Color.purple.opacity(0.2) : Color.purple.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(
                                    colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                    
                    Image(systemName: "bell.fill")
                        .font(.title3)
                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .primary)
                    
                    // Notification badge
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(x: 12, y: -12)
                }
                .scaleEffect(isNotificationPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isNotificationPressed)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color(.systemGray6) : Color.white,
                    colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6).opacity(0.3)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorScheme == .dark ? Color.white.opacity(0.15) : Color.gray.opacity(0.3),
                            colorScheme == .dark ? Color.white.opacity(0.05) : Color.gray.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .padding(.horizontal, 16)
        .shadow(
            color: colorScheme == .dark ? .black.opacity(0.3) : .gray.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        // Glass effect for modern look
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .blur(radius: 0.5)
                .offset(x: 0, y: 1)
        )
    }
}

#Preview("Light Mode") {
    Header()
        .preferredColorScheme(.light)
        .environmentObject(ThemeViewModel())
}

#Preview("Dark Mode") {
    Header()
        .preferredColorScheme(.dark)
        .environmentObject(ThemeViewModel())
}
