import SwiftUI

// MARK: - Footer

struct FooterView: View {
    let sysInfo: SysInfo
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        HStack {
            Text("mini pulse")
                .font(PixelFont.eightBit(size: 13.2, weight: Font.Weight.semibold, design: .monospaced))                .foregroundColor(theme.muted)

            Spacer()

            Text(sysInfo.hostname)
                .font(PixelFont.eightBit(size: 13.2, design: .monospaced))                .foregroundColor(theme.muted)

            Spacer()

            Text("3s refresh")
                .font(PixelFont.eightBit(size: 12, weight: Font.Weight.medium))                .foregroundColor(theme.muted)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(theme.surface)
    }
}