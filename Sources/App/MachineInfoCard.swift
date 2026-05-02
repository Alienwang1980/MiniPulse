import SwiftUI

// MARK: - Machine Info Card

struct MachineInfoCard: View {
    let sysInfo: SysInfo
    let gpu: GpuInfo
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Group {
                    if theme.isEightBit {
                        Image("machineInfo")
                            .resizable()
                            .scaledToFit().frame(width: 22, height: 22)
                    } else {
                        Image(systemName: "desktopcomputer")
                    }
                }
                    .font(PixelFont.eightBit(size: 16.8))                    .foregroundColor(theme.machineAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.machineAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("本机信息")
                        .font(PixelFont.eightBit(size: 14.4, weight: Font.Weight.semibold))                        .foregroundColor(theme.text)
                    Text("\(sysInfo.machineModelName) · 系统信息")
                        .font(PixelFont.eightBit(size: 12))                        .foregroundColor(theme.muted)
                }
                Spacer()
            }

            HStack(alignment: .top, spacing: 28.8) {
                VStack(alignment: .leading, spacing: 9.6) {
                    InfoCell(label: "型号", value: sysInfo.hwModel, accent: true)
                    InfoCell(label: "主机名", value: sysInfo.hostname, accent: true)
                    InfoCell(label: "系统版本", value: sysInfo.osVersion)
                    InfoCell(label: "运行时长", value: sysInfo.uptime)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 9.6) {
                    if !sysInfo.displayResolutions.isEmpty {
                        InfoCell(label: "显示器", value: sysInfo.displayResolutions.joined(separator: ", "))
                    }
                    InfoCell(label: "GPU", value: gpu.name)
                    if gpu.vramMB > 0 {
                        let vramGB = Double(gpu.vramMB) / 1024.0
                        InfoCell(label: "VRAM", value: String(format: "%.1f GB", vramGB), accent: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.machineCardBg : theme.card)
        .cornerRadius(14.4)
    }
}