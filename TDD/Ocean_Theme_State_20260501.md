# Ocean Theme 正确状态记录（2026-05-01）

## 背景
- Ocean 主题是 final version（基准主题），8-bit 是后来叠加的
- **当前编译版本 Ocean 主题颜色正确**，本文档用于记录这个正确状态

---

## AppTheme.swift — Ocean 颜色 tokens

### 基础颜色（无 themeType 保护，直接返回 ocean 值）
```
oceanBg:        dark=#080c14  light=#e4eaf2
oceanSurface:   dark=#0d1525  light=#f0f4f8
oceanCard:      dark=#111c32  light=#ffffff
oceanCardHover: dark=#1a2845  light=#e8eef5
oceanBorder:    dark=#1e3054  light=#c8d4e3
oceanBorderHi:  dark=#2a4070  light=#b0bdd0
```

### Accent 颜色
```
oceanCpuAccent: dark=#00d4ff  light=#0077b6
oceanMemAccent: dark=#a78bfa  light=#6d28d9
oceanGpuAccent: dark=#fb923c  light=#c2410c
```

### Muted/其他
```
oceanMuted:     dark=#5a7194  light=#94a8c4
oceanText:      dark=#ffffff  light=#0a0e1a
oceanSubText:   dark=#94b0cc  light=#4a5e7a
```

---

## `*CardBg` — Ocean 路径（当前正确状态）
```
cpuCardBg:       Ocean=oceanBorder   8-bit=eightBitCpuCardBg(coral)
memCardBg:       Ocean=oceanBorder   8-bit=eightBitMemCardBg(mint)
gpuCardBg:       Ocean=oceanBorder   8-bit=eightBitGpuCardBg(peach)
netCardBg:       Ocean=oceanBorder   8-bit=eightBitNetCardBg(sky)
diskCardBg:      Ocean=oceanBorder   8-bit=eightBitDiskCardBg(lavender)
batteryCardBg:   Ocean=oceanBorder   8-bit=eightBitBatteryCardBg(olive)
powerCardBg:     Ocean=oceanBorder   8-bit=eightBitPowerCardBg(coral)
bluetoothCardBg: Ocean=oceanBorder   8-bit=eightBitBluetoothCardBg(sky)
usbCardBg:       Ocean=oceanBorder   8-bit=eightBitUsbCardBg(lavender)
machineCardBg:   Ocean=oceanBorder   8-bit=eightBitMachineCardBg(peach)
topCardBg:       Ocean=oceanBorder   8-bit=eightBitTopCardBg(mint)
```

**注意**：Ocean 的 `*CardBg` = `oceanBorder`，不是 `oceanCard`。这是为了让进度条背景有对比度（oceanCard light=#ffffff 会消失在背景里）。

---

## 各卡片颜色使用方式（Ocean）

### CpuCard
- 卡片背景：`.background(theme.card)` → `oceanCard`（深蓝/白）
- 进度条背景：`.fill(theme.cpuCardBg)` → `oceanBorder`（有对比度）
- 进度条填充：LinearGradient `oceanCpuAccent → oceanCpuAccent`（cyan）
- CPU 网格背景：`.fill(theme.cpuCardBg)` → `oceanBorder`
- 网格填充：`oceanCpuAccent`（cyan）
- 图标背景：`oceanCpuAccent.opacity(0.20)`

### MemoryCard
- 卡片背景：`.background(theme.card)` → `oceanCard`
- 进度条背景：`.fill(theme.memCardBg)` → `oceanBorder`
- 进度条填充：LinearGradient `oceanMemAccent → purple`
- Swap 进度条背景：`.fill(theme.memCardBg)` → `oceanBorder`
- 图标背景：`oceanMemAccent.opacity(0.20)`

### GpuCard
- 卡片背景：`.background(theme.card)` → `oceanCard`
- 进度条背景：`theme.gpuCardBg` → `oceanBorder`
- 进度条填充：`oceanGpuAccent`（orange）
- 网格背景：`theme.gpuCardBg` → `oceanBorder`
- 图标背景：`oceanGpuAccent.opacity(0.20)`

### NetworkCard
- 卡片背景：`.background(theme.card)` → `oceanCard`
- Divider：`theme.border` → `oceanBorder`
- 图标背景：`netAccent.opacity(0.20)`（accent 来自 oceanNetAccent）

### DiskCard
- 卡片背景：`.background(theme.card)` → `oceanCard`
- Divider：`.background(theme.diskCardBg)` → `oceanBorder`
- 进度条背景：`.fill(theme.diskCardBg)` → `oceanBorder`
- 图标背景：`diskAccent.opacity(0.20)`

### BatteryCard
- 卡片背景：`.background(theme.card)` → `oceanCard`
- 进度条背景：`.fill(theme.batteryCardBg)` → `oceanBorder`

### PowerCard
- 卡片背景：`.background(theme.card)` → `oceanCard`

### DevicesCard
- 卡片背景：`.background(theme.card)` → `oceanCard`

### MachineInfoCard
- 卡片背景：`.background(theme.card)` → `oceanCard`

### TopCPUCard / TopMemCard
- 卡片背景：`.background(theme.card)` → `oceanCard`

---

## 关键原则
1. **Ocean 卡片背景统一用 `theme.card`**（`oceanCard`），不是 `*CardBg`
2. **Ocean 进度条背景统一用 `*CardBg`**（= `oceanBorder`，有对比度）
3. **Ocean 没有 per-card accent** — accent 只用于进度条填充和图标背景，不用于卡片背景
4. `border` 和 `*CardBg` 在 Ocean 下都指向 `oceanBorder`，但用途不同：
   - `border`：用于分隔线等
   - `*CardBg`：用于进度条背景（在 AppTheme 里指向 oceanBorder）

---

## 8-bit theme 的正确状态（待记录）

（待补充）
