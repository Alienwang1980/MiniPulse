# 8-bit 主题正确状态记录（2026-05-01）

## 主题特征

8-bit 主题的核心特征：
1. **灰底 + 像素点**：深色 #1E1E1E，浅色 #F0F0F0
2. **每张卡片有独立的 accent 颜色**（品牌色），用于：
   - 进度条填充
   - 图标背景
   - 卡片背景（**目前还没实现**）
3. **进度条背景**：使用 border 颜色（深色 #3A302A，浅色 #F0E0D0）
4. **通用文字**：深色 #FFF5EB（暖白），浅色 #2D3436（深灰）

---

## 8-bit Accent 6 色相（per-card）

| 卡片 | 色相 | 深色 hex | 浅色 hex |
|------|------|----------|----------|
| CPU | Coral | #E8A598 | #BA7A6E |
| Memory | Mint | #8ED8BE | #5A9A82 |
| GPU | Peach | #F5D5A0 | #C4A870 |
| Network | Sky | #9DD3E8 | #6A9AB8 |
| Disk | Lavender | #C4B0E8 | #9870B8 |
| Battery | Olive | #C8C87A | #9A9A50 |
| Power | Coral | #E8A598 | #BA7A6E |
| Bluetooth | Sky | #9DD3E8 | #6A9AB8 |
| USB | Lavender | #C4B0E8 | #9870B8 |
| Machine | Peach | #F5D5A0 | #C4A870 |
| Top | Mint | #8ED8BE | #5A9A82 |

---

## AppTheme.swift — 8-bit 颜色 tokens

### 基础颜色
```
eightBitBg:        dark=#1E1E1E  light=#F0F0F0
eightBitSurface:   dark=#1E1E1E  light=#F0F0F0
eightBitCard:      dark=#2E2620  light=#FFFFFF
eightBitCardHover: dark=#3A302A  light=#FDF2E9
eightBitBorder:    dark=#3A302A  light=#F0E0D0
eightBitBorderHi:  dark=#5A4E48  light=#E8D5C4
eightBitText:      dark=#FFF5EB  light=#2D3436
eightBitMuted:     dark=#A09080  light=#636E72
```

### *CardBg（per-card accent + 20% opacity）
```
eightBitCpuCardBg:       dark=#E8A598@20%  light=#BA7A6E@20%
eightBitMemCardBg:       dark=#8ED8BE@20%  light=#5A9A82@20%
eightBitGpuCardBg:       dark=#F5D5A0@20%  light=#C4A870@20%
eightBitNetCardBg:       dark=#9DD3E8@20%  light=#6A9AB8@20%
eightBitDiskCardBg:      dark=#C4B0E8@20%  light=#9870B8@20%
eightBitBatteryCardBg:    dark=#C8C87A@20%  light=#9A9A50@20%
eightBitPowerCardBg:     dark=#E8A598@20%  light=#BA7A6E@20%
eightBitBluetoothCardBg: dark=#9DD3E8@20%  light=#6A9AB8@20%
eightBitUsbCardBg:       dark=#C4B0E8@20%  light=#9870B8@20%
eightBitMachineCardBg:   dark=#F5D5A0@20%  light=#C4A870@20%
eightBitTopCardBg:       dark=#8ED8BE@20%  light=#5A9A82@20%
```

---

## 各卡片颜色使用方式（8-bit — 目标状态）

### CpuCard
- **卡片背景**：`.background(theme.cpuCardBg)` → per-card accent opacity 0.20
- **进度条背景**：`.fill(theme.cpuCardBg)` → per-card accent opacity 0.20
- **进度条填充**：LinearGradient `cpuAccent → cpuGrad2`（Coral 渐变）
- **CPU 网格背景**：`.fill(theme.cpuCardBg)` → per-card accent opacity 0.20
- **图标背景**：`cpuAccent.opacity(0.20)`

### MemoryCard
- **卡片背景**：`.background(theme.memCardBg)` → Mint opacity 0.20
- **进度条背景**：`.fill(theme.memCardBg)` → Mint opacity 0.20
- **Swap 进度条背景**：`.fill(theme.memCardBg)` → Mint opacity 0.20

### GpuCard
- **卡片背景**：`.background(theme.gpuCardBg)` → Peach opacity 0.20
- **进度条背景**：`.fill(theme.gpuCardBg)` → Peach opacity 0.20

### NetworkCard
- **卡片背景**：`.background(theme.netCardBg)` → Sky opacity 0.20
- **Divider**：`theme.border` → `eightBitBorder`

### DiskCard
- **卡片背景**：`.background(theme.diskCardBg)` → Lavender opacity 0.20
- **进度条背景**：`.fill(theme.diskCardBg)` → Lavender opacity 0.20

### BatteryCard
- **卡片背景**：`.background(theme.batteryCardBg)` → Olive opacity 0.20
- **进度条背景**：`.fill(theme.batteryCardBg)` → Olive opacity 0.20

### PowerCard
- **卡片背景**：`.background(theme.powerCardBg)` → Coral opacity 0.20

### DevicesCard
- **卡片背景**：`theme.card`（统一色，8-bit 无独立设备 accent）

### MachineInfoCard
- **卡片背景**：`.background(theme.machineCardBg)` → Peach opacity 0.20

### TopCPUCard / TopMemCard
- **卡片背景**：`theme.card`（统一色，8-bit 无 Top accent）

---

## 当前代码的实际状态（8-bit）

### CpuCard.swift
- 行 61：`.fill(theme.cpuCardBg)` ✅ 进度条背景 = per-card accent
- 行 129：`.background(theme.card)` ❌ 卡片背景 = 统一色（应改 `theme.cpuCardBg`）
- 行 158：`.fill(theme.cpuCardBg)` ✅ 网格背景 = per-card accent

### MemoryCard.swift
- 行 48：`.fill(theme.memCardBg)` ✅ 进度条背景
- 行 88：`.fill(theme.memCardBg)` ✅ Swap 进度条背景
- 行 99：`.background(theme.card)` ❌ 卡片背景（应改 `theme.memCardBg`）

### BatteryCard.swift
- 行 161：`.fill(theme.batteryCardBg)` ✅ 进度条背景
- 卡片背景：`.background(theme.card)` ❌（应改 `theme.batteryCardBg`）

### DiskCard.swift
- 行 106：`.fill(theme.diskCardBg)` ✅ 进度条背景
- 卡片背景：`theme.card` 或无（需确认）

### NetworkCard.swift
- 卡片背景：`theme.card` ❌（应改 `theme.netCardBg`）

### PowerCard.swift
- 卡片背景：`theme.card` ❌（应改 `theme.powerCardBg`）

---

## 关键原则
1. **8-bit 每张卡片的背景色 = `theme.xxxCardBg`**（per-card accent + 20% opacity）
2. **8-bit 进度条背景色 = `theme.xxxCardBg`**（per-card accent + 20% opacity）
3. **Ocean 和 8-bit 完全隔离**：Ocean 的 `*CardBg` = `oceanBorder`，8-bit 的 `*CardBg` = accent opacity，两者互不影响
4. **`theme.card`** 在 8-bit 下 = `eightBitCard`（统一色），**不要**用 `theme.card` 作为 8-bit 卡片背景
5. **Ocean 卡片背景 = `theme.card`**（`oceanCard`），**不要**改成 `*CardBg`

---

## 修复清单

| 卡片 | 文件 | 改：卡片背景 | 改：进度条背景 |
|------|------|-------------|--------------|
| CpuCard | CpuCard.swift | `theme.card` → `theme.cpuCardBg` | ✅ 已正确 |
| MemoryCard | MemoryCard.swift | `theme.card` → `theme.memCardBg` | ✅ 已正确 |
| BatteryCard | BatteryCard.swift | `theme.card` → `theme.batteryCardBg` | ✅ 已正确 |
| DiskCard | DiskCard.swift | 待确认 | ✅ 已正确 |
| NetworkCard | NetworkCard.swift | `theme.card` → `theme.netCardBg` | `theme.border` → `theme.netCardBg` |
| PowerCard | PowerCard.swift | `theme.card` → `theme.powerCardBg` | N/A |
| MachineInfoCard | MachineInfoCard.swift | `theme.card` → `theme.machineCardBg` | N/A |
| GpuCard | GpuCard.swift | 待确认 | ✅ 已正确 |
