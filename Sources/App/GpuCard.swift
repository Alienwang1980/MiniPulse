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
                    .font(PixelFont.eightBit(size: 16.8))                    .foregroundColor(theme.gpuAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.gpuAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("GPU")
                        .font(PixelFont.eightBit(size: 14.4, weight: Font.Weight.semibold))                        .foregroundColor(theme.text)
                    Text(gpu.name.isEmpty ? "Apple Silicon" : gpu.name)
                        .font(PixelFont.eightBit(size: 12))                        .foregroundColor(theme.muted)
                }
                Spacer()
            }

            // Big stat
            ZStack(alignment: .leading) {
                if theme.isEightBit {
                    HeroPatternBackground(pattern: CardHeroPattern.gpu, color: theme.gpuAccent, opacity: 0.12)
                }
                HStack(alignment: .lastTextBaseline, spacing: 2.4) {
                    Text("\(gpuDisplay)")
                        .font(PixelFont.eightBit(size: 70, weight: Font.Weight.bold, design: .rounded))
                        .foregroundColor(theme.gpuAccent)
                        .contentTransition(.numericText())
                    Text("%")
                        .font(PixelFont.eightBit(size: 28.8, weight: Font.Weight.medium))
                        .foregroundColor(theme.muted)
                    Spacer()
                    Text("GPU 占用")
                        .font(PixelFont.eightBit(size: 13.2))                        .foregroundColor(theme.muted)
                }
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