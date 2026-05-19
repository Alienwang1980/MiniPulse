import SwiftUI

// MARK: - Splash Screen

struct SplashView: View {
    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        ZStack {
            // Light mode: white background; dark mode: frosted glass
            if theme.colorScheme == .dark {
                Color.black.opacity(0.4)
                    .background(.ultraThinMaterial)
            } else {
                Color.white
            }

            VStack(spacing: 20) {
                Image(theme.colorScheme == .dark ? "logo_splash" : "logo_splash_light")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)

                Text("Shining Like a Neutron Star")
                    .font(PixelFont.eightBit(size: 18, weight: Font.Weight.bold, design: .rounded))                    .foregroundColor(theme.accent)
                    .shadow(color: theme.accent.opacity(0.4), radius: 8)
                    .padding(.horizontal, 24)
            }
        }
        .ignoresSafeArea()
    }
}
