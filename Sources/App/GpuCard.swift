import SwiftUI

// MARK: - GPU Card

struct GpuCard: View {
    let gpu: GpuInfo
    @State private var gpuDisplay: Int = 0
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Image(systemName: "rectangle.3.group")
                    .font(.system(size: 16.8))
                    .foregroundColor(theme.gpuAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.gpuAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("GPU")
                        .font(.system(size: 14.4, weight: .semibold))
                        .foregroundColor(theme.text)
                    Text(gpu.name.isEmpty ? "Apple Silicon" : gpu.name)
                        .font(.system(size: 12))
                        .foregroundColor(theme.muted)
                }
                Spacer()
            }

            HStack(alignment: .lastTextBaseline, spacing: 2.4) {
                Text("\(gpuDisplay)")
                    .font(.system(size: 57.6, weight: .bold, design: .rounded))
                    .foregroundColor(theme.gpuAccent)
                    .contentTransition(.numericText())
                Text("%")
                    .font(.system(size: 28.8, weight: .medium))
                    .foregroundColor(theme.muted)
                Spacer()
                Text("GPU 占用")
                    .font(.system(size: 13.2))
                    .foregroundColor(theme.muted)
            }

            // Sparkline
            SparklineView(history: gpu.utilizationHistory, backgroundColor: theme.gpuCardBg)
                .frame(height: 48)

            // Details
            VStack(spacing: 4.8) {
                DetailRow(label: "名称", value: gpu.name, color: theme.accent2)
                if gpu.vramMB > 0 {
                    let vramGB = Double(gpu.vramMB) / 1024.0
                    DetailRow(label: "VRAM", value: String(format: "%.1f GB", vramGB), color: theme.accent3)
                }
                let chipDisplay = gpu.chip ?? gpu.name
                DetailRow(label: "核心", value: chipDisplay, color: theme.muted)
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.gpuCardBg : theme.card)
        .cornerRadius(14.4)
        .onAppear {
            gpuDisplay = gpu.utilization ?? 0
        }
        .onChange(of: gpu) { _, newGpu in
            withAnimation(.spring(response: 1.8, dampingFraction: 0.85, blendDuration: 0)) { gpuDisplay = newGpu.utilization ?? 0 }
        }
    }
}