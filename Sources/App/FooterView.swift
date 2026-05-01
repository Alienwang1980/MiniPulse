import SwiftUI

// MARK: - Footer

struct FooterView: View {
    let sysInfo: SysInfo
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        HStack {
            Text("mini pulse")
                .font(.system(size: 13.2, weight: .semibold, design: .monospaced))
                .foregroundColor(theme.muted)

            Spacer()

            Text(sysInfo.hostname)
                .font(.system(size: 13.2, design: .monospaced))
                .foregroundColor(theme.muted)

            Spacer()

            Text("3s refresh")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.muted)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(theme.surface)
    }
}