# Ocean 主题完整色彩规格（2026-05-01）

> 记录当前编译版本中 Ocean 主题每个 UI 元素的实际颜色值，一个都不能差。

---

## 一、AppTheme.swift — Ocean 色值总表

### 基础色（background / surface / card / border）
| Token | 深色 (dark) | 浅色 (light) | 用途 |
|-------|------------|-------------|------|
| `oceanBg` | `#080c14` | `#e4eaf2` | 页面背景 |
| `oceanSurface` | `#0d1525` | `#f0f4f8` | 备用背景（同 oceanBg） |
| `oceanCard` | `#111c32` | `#ffffff` | 卡片容器背景 |
| `oceanCardHover` | `#1a2845` | `#e8eef5` | 悬停状态 |
| `oceanBorder` | `#1e3054` | `#c8d4e3` | 分隔线 / 进度条背景（Ocean） |
| `oceanBorderHi` | `#2a4070` | `#b0bdd0` | 高亮边框 |
| `oceanText` | `#e2e8f0` | `#1e293b` | 主文字 |
| `oceanMuted` | `#64748b` | `#5a6a7e` | 次要文字 / 占位符 |

### 进度条填充渐变色
| Token | 深色 | 浅色 | 用途 |
|-------|------|------|------|
| `oceanCpuGrad2` | `#0099ff` | `#70C0FF` | CPU 进度条填充右端 |
| `oceanMemGrad2` | `#7c3aed` | `#B080F0` | Memory 进度条填充右端 |
| `oceanSwapGrad1` | `#f87171` | `#FF9070` | Swap 进度条左端 |
| `oceanSwapGrad2` | `#ff1744` | `#FF5070` | Swap 进度条右端 |
| `oceanDiskGrad1` | `#34d399` | `#70E0A8` | Disk 进度条左端（绿色） |
| `oceanDiskGrad2` | `#16a34a` | `#50C080` | Disk 进度条右端 |
| `oceanDiskRed` | `#ff1744` | `#FF5070` | Disk >90% 红色 |
| `oceanCpuRed` | `#ff1744` | `#FF5070` | CPU Core >80% 红色阈值 |

### 卡片 accent 色（Ocean 用于图标、进度条填充、文字高亮）
| Token | 深色 | 浅色 | 卡片 |
|-------|------|------|------|
| `oceanCpuAccent` | `#00d4ff` | `#0077b6` | CPU |
| `oceanMemAccent` | `#a78bfa` | `#6d28d9` | Memory |
| `oceanGpuAccent` | `#fb923c` | `#c2410c` | GPU |
| `oceanNetAccent` | `#22d3ee` | `#0891b2` | Network |
| `oceanDiskAccent` | `#34d399` | `#16a34a` | Disk |
| `oceanBatteryAccent` | `#fbbf24` | `#ca8a04` | Battery |
| `oceanPowerAccent` | `#f87171` | `#dc2626` | Power（桌面） |
| `oceanBluetoothAccent` | `#818cf8` | `#4338ca` | Bluetooth |
| `oceanUsbAccent` | `#f472b6` | `#be185d` | USB |
| `oceanMachineAccent` | `#94a3b8` | `#475569` | MachineInfo |
| `oceanTopAccent` | `#7dd3fc` | `#0369a1` | TopCPU / TopMem |

### Status 色（通用负载状态）
| Token | 深色 | 浅色 | 含义 |
|-------|------|------|------|
| `oceanGreen` | `#34d399` | `#16a34a` | 低 / 正常 |
| `oceanYellow` | `#fbbf24` | `#ca8a04` | 中等 |
| `oceanRed` | `#f87171` | `#dc2626` | 高 / 危险 |
| `oceanOrange` | `#fb923c` | `#c2410c` | 中高 |
| `oceanCyan` | `#22d3ee` | `#0891b2` | 备用青 |
| `oceanAccent` | `#00d4ff` | `#0077b6` | 主 accent（同 cpuAccent） |
| `oceanAccent2` | `#00e5cc` | `#00838f` | 辅 accent |
| `oceanAccent3` | `#7dd3fc` | `#0369a1` | 第三 accent |

### 快捷别名
| Token | 等于 | 说明 |
|-------|------|------|
| `cpuBright` | `oceanCpuAccent` | CPU 亮色 |
| `green` | `oceanGreen` | 绿 |
| `yellow` | `oceanYellow` | 黄 |
| `red` | `oceanRed` | 红 |
| `orange` | `oceanOrange` | 橙 |
| `cyan` | `oceanCyan` | 青 |
| `cpuLow` | `oceanGreen` | CPU 低负载色（Ocean 用绿，不用 accent） |
| `cpuRed` | `oceanCpuRed` | CPU 高阈值 |
| `cpuGrad2` | `oceanCpuGrad2` | CPU 渐变右端 |
| `memGrad2` | `oceanMemGrad2` | Memory 渐变右端 |
| `swapGrad1/2` | `oceanSwapGrad1/2` | Swap 渐变 |
| `diskGrad1/2` | `oceanDiskGrad1/2` | Disk 渐变 |
| `diskRed` | `oceanDiskRed` | Disk 红色 |
| `accent` | `oceanCpuAccent` | 主 accent（Ocean 退化为 CPU accent） |
| `accent2` | `oceanMemAccent` | 辅 accent（Ocean 退化为 Mem accent） |
| `accent3` | `oceanGpuAccent` | 第三 accent（Ocean 退化为 GPU accent） |

---

## 二、通用设计规范

### 圆角
- 卡片容器：`14.4pt`
- 图标背景：`9.6pt`
- 进度条：`3pt`（CPU/Memory/Disk），`6pt`（Battery）
- Sparkline：`4pt`

### 间距
- 卡片内边距：`19.2pt`
- 卡片内元素间距：`12pt`
- 行内子元素间距：`4.8pt`（标签与数值）
- Section 标签上边距：`4.8pt`

### 字体
- 卡片标题：`14.4pt`，`.semibold`
- 大数字（利用率）：`57.6pt`，`.bold`，`.rounded`
- 百分比符号：`28.8pt`，`.medium`
- 小标签文字：`12pt`
- 单位 / 单位数值：`12pt`，`.medium`，`.monospaced`
- 大数值（如 CPU 57.6）：`57.6pt`，`.bold`，`.rounded`
- 大数值（26.4 如 Disk 读取速度）：`26.4pt`，`.bold`，`.monospaced`
- 温度大数字：`26pt`，`.bold`，`.rounded`
- Section 标签：`10.8pt`，`.semibold`，`uppercase`
- DetailRow 标签：`13.2pt`，`.medium`
- DetailRow 数值：`13.2pt`，`.bold`，`.monospaced`
- InfoCell 标签：`12pt`，`.medium`
- InfoCell 数值：`14.4pt`，`.bold`（accent）或 `.medium`（普通）

### 图标
- 卡片图标：SF Symbol，`16.8pt`
- 温度计图标：`19.2pt`
- 图标容器：`40.3 × 40.3pt`，圆角 `9.6pt`
- 图标背景色：`xxxAccent.opacity(0.20)`
- 图标前景色：`xxxAccent`

---

## 三、每张卡片详细规格

---

### CpuCard

**容器**
- `.background(theme.card)` → `oceanCard`（深色 `#111c32` / 浅色 `#ffffff`）
- `.cornerRadius(14.4)`
- `.padding(19.2)`

**Header**
- 图标：`cpu` SF Symbol，`16.8pt`，前景 `theme.cpuAccent`（深 `#00d4ff` / 浅 `#0077b6`），背景 `theme.cpuAccent.opacity(0.20)`，容器 `40.3×40.3` 圆角 `9.6`
- 标题"CPU"：`14.4pt .semibold`，前景 `theme.text`（深 `#e2e8f0` / 浅 `#1e293b`）
- 副标题"X 核 / X 线程"：`12pt`，前景 `theme.muted`（深 `#64748b` / 浅 `#5a6a7e`）
- 温度（右侧）：图标 `thermometer.medium`，`19.2pt`，前景 `theme.cpuAccent`；文字 `26pt .bold .rounded`，前景 `theme.cpuAccent`

**大利用率数字**
- 数值：`57.6pt .bold .rounded`，前景 `theme.cpuAccent`
- 百分号：`28.8pt .medium`，前景 `theme.muted`

**进度条**（高 `6pt`，圆角 `3`）
- 背景：`.fill(theme.cpuCardBg)` → `oceanBorder`（深 `#1e3054` / 浅 `#c8d4e3`）
- 填充：LinearGradient `leading→trailing`，`theme.cpuAccent → theme.cpuGrad2`（`#00d4ff → #0099ff`，浅色 `#0077b6 → #70C0FF`）

**Per-Core 网格**
- 网格背景：`theme.cpuCardBg`（`oceanBorder` 深 `#1e3054` / 浅 `#c8d4e3`）
- 网格间距：`4.8pt`
- 每格高度：`33.6pt`，圆角 `3`
- 填充颜色（barColor）：
  - `percent > 80`：`theme.red → theme.cpuRed`（`#f87171 → #ff1744`，浅色 `#dc2626 → #FF5070`）
  - `percent > 50`：`theme.yellow → theme.orange`（`#fbbf24 → #fb923c`，浅色 `#ca8a04 → #c2410c`）
  - `percent ≤ 50`：`theme.cpuAccent → theme.cpuLow`（`#00d4ff → #34d399`，浅色 `#0077b6 → #16a34a`）
- Core 编号：`9.6pt .bold`，前景 `theme.muted`

**时间分解区块**
- 标签"时间分解"：`10.8pt .semibold uppercase`，前景 `theme.muted`，上边距 `4.8pt`

左列：
- "User" 标签：`12pt .medium`，前景 `theme.muted`
- User 数值：`12pt .bold .monospaced`，前景 `theme.accent`（=`oceanCpuAccent`，`#00d4ff`）
- "System" 标签：`12pt .medium`，前景 `theme.muted`
- System 数值：`12pt .bold .monospaced`，前景 `theme.orange`（`#fb923c`）

右列：
- "频率" 标签：`12pt .medium`，前景 `theme.muted`
- 频率数值：`12pt .bold .monospaced`，前景 `theme.accent2`（=`oceanMemAccent`，`#a78bfa`）
- "空闲" 标签：`12pt .medium`，前景 `theme.muted`
- 空闲数值：`12pt .bold .monospaced`，前景 `theme.green`（`#34d399`）

---

### MemoryCard

**容器**
- `.background(theme.card)` → `oceanCard`
- `.cornerRadius(14.4)`
- `.padding(19.2)`

**Header**
- 图标：`memorychip`，`16.8pt`，前景 `theme.memAccent`（深 `#a78bfa` / 浅 `#6d28d9`），背景 `theme.memAccent.opacity(0.20)`
- 标题"内存 (RAM)"：`14.4pt .semibold`，前景 `theme.text`
- 副标题"X.X GB"：`12pt`，前景 `theme.muted`

**大利用率数字**
- 数值：`57.6pt .bold .rounded`，前景 `theme.memAccent`（`#a78bfa`）
- 百分号：`28.8pt .medium`，前景 `theme.muted`

**已用/总量文字**
- "X.X / X.X GB"：`12pt .medium .monospaced`，前景 `theme.muted`

**进度条**（高 `6pt`）
- 背景：`.fill(theme.memCardBg)` → `oceanBorder`（`#1e3054` / `#c8d4e3`）
- 填充：LinearGradient `theme.memAccent → theme.memGrad2`（`#a78bfa → #7c3aed`，浅色 `#6d28d9 → #B080F0`）

**Detail Row（已用/可用）**
- "已用"标签：`13.2pt .medium`，前景 `theme.accent3`（=`oceanGpuAccent`，`#fb923c`）
- "已用"数值：`13.2pt .bold .monospaced`，前景 `theme.accent3`（`#fb923c`）
- "可用"标签：`13.2pt .medium`，前景 `theme.green`（`#34d399`）
- "可用"数值：`13.2pt .bold .monospaced`，前景 `theme.green`

**Swap 区块**
- 标签"Swap"：`10.8pt .semibold uppercase`，前景 `theme.muted`，上边距 `4.8pt`
- Swap 使用量：`12pt .bold .monospaced`，前景 `theme.orange`（`#fb923c`）
- "/"分隔符：前景 `theme.muted`
- Swap 总量：`12pt .monospaced`，前景 `theme.muted`
- Swap 百分比：`12pt .bold`，前景 `theme.orange`

**Swap 进度条**（高 `4.8pt`）
- 背景：`.fill(theme.memCardBg)` → `oceanBorder`
- 填充：LinearGradient `theme.swapGrad1 → theme.swapGrad2`（`#f87171 → #ff1744`，浅色 `#FF9070 → #FF5070`）

---

### GpuCard

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：`rectangle.3.group`，前景 `theme.gpuAccent`（深 `#fb923c` / 浅 `#c2410c`），背景 `theme.gpuAccent.opacity(0.20)`
- 标题"GPU"：`14.4pt .semibold`，前景 `theme.text`
- 副标题（GPU 名称）：`12pt`，前景 `theme.muted`

**大利用率数字**
- 数值：`57.6pt .bold .rounded`，前景 `theme.gpuAccent`（`#fb923c`）
- 百分号：`28.8pt .medium`，前景 `theme.muted`
- 标签"GPU 占用"：`13.2pt`，前景 `theme.muted`

**Sparkline**
- 背景：`theme.gpuCardBg`（=`oceanBorder`，`#1e3054` / `#c8d4e3`）
- 填充：`theme.accent2`（=`oceanAccent2`，`#00e5cc`）opacity 0.45→0.02 的渐变
- 线条：`theme.accent2`（`#00e5cc`）两次：blur `2` + 清晰 `1.5pt`
- 高度：`48pt`
- 圆角：`4pt`

**Detail Row**
- "名称"：`13.2pt .medium`，前景 `theme.accent2`（`#00e5cc`）
- "VRAM"：`13.2pt .bold .monospaced`，前景 `theme.accent3`（=`oceanGpuAccent`，`#fb923c`）
- "核心"：`13.2pt .medium`，前景 `theme.muted`

---

### NetworkCard

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：`network`，前景 `theme.netAccent`（深 `#22d3ee` / 浅 `#0891b2`），背景 `theme.netAccent.opacity(0.20)`
- 标题"网络 I/O"：`14.4pt .semibold`，前景 `theme.text`
- 副标题"实时速度"：`12pt`，前景 `theme.muted`

**实时速度区**
- "↓ 接收"标签：`10.8pt`，前景 `theme.muted`
- 接收数值：`26.4pt .bold .monospaced`，前景 `theme.green`（`#34d399`）
- 接收单位"MB/s"：`12pt`，前景 `theme.muted`
- "↑ 发送"标签：`10.8pt`，前景 `theme.muted`
- 发送数值：`26.4pt .bold .monospaced`，前景 `theme.accent`（=`oceanCpuAccent`，`#00d4ff`）
- 发送单位"MB/s"：`12pt`，前景 `theme.muted`

**Divider**
- `Divider().background(theme.border)` → `oceanBorder`（`#1e3054` / `#c8d4e3`）

**Per-Interface 列表**
- 接口名称：`12pt .medium`，前景 `theme.muted`
- IP 地址：`10.8pt .bold .monospaced`，前景 `theme.accent2`（=`oceanMemAccent`，`#a78bfa`）
- 接收速度：`12pt .medium .monospaced`，前景 `theme.green`
- 发送速度：`12pt .medium .monospaced`，前景 `theme.accent`

**Total 区块**
- 标签"总发送"：`13.2pt .medium`，前景 `theme.muted`
- 总发送数值：`13.2pt .bold .monospaced`，前景 `theme.accent2`（`#a78bfa`）
- 标签"总接收"：`13.2pt .medium`，前景 `theme.muted`
- 总接收数值：`13.2pt .bold .monospaced`，前景 `theme.green`

**诊断按钮**
- "🔍 网络诊断"：`12pt`，前景 `theme.muted`

---

### DiskCard

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：`internaldrive`，前景 `theme.diskAccent`（深 `#34d399` / 浅 `#16a34a`），背景 `theme.diskAccent.opacity(0.20)`
- 标题"磁盘存储"：`14.4pt .semibold`，前景 `theme.text`
- 副标题"实时速度"：`12pt`，前景 `theme.muted`
- 温度（右侧）：`thermometer.medium`，`19.2pt`，前景 `theme.diskAccent`；文字 `26pt .bold .rounded`，前景 `theme.diskAccent`

**实时速度区**
- "↓ 读取"标签：`10.8pt`，前景 `theme.muted`
- 读取数值：`26.4pt .bold .monospaced`，前景 `theme.green`（`#34d399`）
- "↑ 写入"标签：`10.8pt`，前景 `theme.muted`
- 写入数值：`26.4pt .bold .monospaced`，前景 `theme.accent`（=`oceanCpuAccent`，`#00d4ff`）

**Divider**
- `Divider().background(theme.card)` → `oceanCard`（`#111c32`），与卡片背景融合

**单盘信息**
- 盘图标：`internaldrive.fill`，`14.4pt`，前景 `theme.diskAccent`
- 盘名称：`14.4pt .semibold`，前景 `theme.text`
- 百分比：`15.6pt .bold`，颜色：
  - `> 90%`：`theme.red`（`#f87171`）
  - `> 70%`：`theme.yellow`（`#fbbf24`）
  - `≤ 70%`：`theme.green`（`#34d399`）
- 剩余空间："X GB free"：`12pt`，前景 `theme.muted`

**磁盘进度条**（高 `6pt`）
- 背景：`.fill(theme.diskCardBg)` → `oceanBorder`
- 填充：LinearGradient
  - `> 90%`：`theme.red → theme.diskRed`（`#f87171 → #ff1744`）
  - `> 70%`：`theme.yellow → theme.orange`（`#fbbf24 → #fb923c`）
  - `≤ 70%`：`theme.diskGrad1 → theme.diskGrad2`（`#34d399 → #16a34a`）

---

### BatteryCard（仅笔记本显示）

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：动态电池图标（`battery.100.bolt` 等），`16.8pt`，前景 `theme.green`（`#34d399`），背景 `theme.green.opacity(0.20)`
- 标题"电池"：`14.4pt .semibold`，前景 `theme.text`
- 状态文字：充电="电源已接通"，使用电池="电池供电"，静止="已接通"，`12pt`，前景 `theme.muted`
- 温度（右侧）：`thermometer.medium`，`19.2pt`，前景 `theme.batteryAccent`（`#fbbf24`）；文字 `26pt .bold .rounded`，前景 `theme.batteryAccent`

**大百分比数字**
- 数值：`52.8pt .bold .rounded`，颜色 `percentColor`：
  - `> 50%`：`theme.green`（`#34d399`）
  - `> 20%`：`theme.yellow`（`#fbbf24`）
  - `≤ 20%`：`theme.red`（`#f87171`）
- 百分号：`26.4pt .medium`，前景 `theme.muted`

**状态标签**
- "⚡ 充电中"：`13.2pt .bold`，前景 `theme.green`
- "🔋 使用中"：`13.2pt .bold`，前景 `theme.yellow`
- 累计运行时长：`12pt .medium .monospaced`，前景 `theme.muted`

**电池进度条**（高 `12pt`，圆角 `6`）
- 背景：`.fill(theme.batteryCardBg)` → `oceanBorder`
- 填充：`percentColor`（`green/yellow/red`），有 `.shadow(color: percentColor.opacity(0.5), radius: 3)`

**Metric Grid（2×2）**
- 标签：`12pt`，前景 `theme.muted`
- 数值：`16.8pt .bold .rounded`，颜色由调用处指定
  - 循环次数：默认 `secondary`（系统色）
  - 健康度：`healthColor`（`≥80=green，≥50=yellow，<50=red`）
  - 当前容量：默认 `secondary`
  - 电压：默认 `secondary`

---

### PowerCard

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：`bolt.fill`，`16.8pt`，前景 `theme.batteryAccent`（`#fbbf24`），背景 `theme.batteryAccent.opacity(0.20)`
- 标题"功率"：`14.4pt .semibold`，前景 `theme.text`
- 副标题：笔记本电池供电="电池供电"，接电="电源已接通"；台式机="SOC 功耗"，`12pt`，前景 `theme.muted`

**大功率数字**
- 数值：`48pt .bold .rounded`，前景 `theme.orange`（`#fb923c`）
- 单位"W"：`24pt .medium`，前景 `theme.muted`
- 标签"总功耗"：`13.2pt`，前景 `theme.muted`

**功耗分解**
- "CPU 功耗"标签：`13.2pt .medium`，前景 `theme.muted`
- CPU 数值：`13.2pt .bold .monospaced`，前景 `theme.accent`（=`oceanCpuAccent`，`#00d4ff`）
- "GPU 功耗"标签：`13.2pt .medium`，前景 `theme.muted`
- GPU 数值：`13.2pt .bold .monospaced`，前景 `theme.accent2`（=`oceanMemAccent`，`#a78bfa`）
- "板载功耗"标签：`13.2pt .medium`，前景 `theme.muted`
- 板载数值：`13.2pt .bold .monospaced`，前景 `theme.muted`

---

### BluetoothCard

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：`dot.radiowaves.left.and.right`，`16.8pt`，前景 `theme.bluetoothAccent`（深 `#818cf8` / 浅 `#4338ca`），背景 `theme.bluetoothAccent.opacity(0.20)`
- 标题"蓝牙"：`14.4pt .semibold`，前景 `theme.text`
- 副标题"已配对设备"：`12pt`，前景 `theme.muted`

**设备列表**
- 状态圆点：已连接=`theme.green`（`#34d399`），未连接=`theme.muted`，`8.6×8.6pt`
- 设备名：`13.2pt`，前景 `theme.text`
- 设备类型：`10.8pt`，前景 `theme.muted`

---

### UsbCard

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：`cable.connector`，`16.8pt`，前景 `theme.usbAccent`（深 `#f472b6` / 浅 `#be185d`），背景 `theme.usbAccent.opacity(0.20)`
- 标题"USB"：`14.4pt .semibold`，前景 `theme.text`
- 副标题"已连接设备"：`12pt`，前景 `theme.muted`

**设备列表**
- 状态圆点：`theme.green`，`8.6×8.6pt`
- 设备名：`13.2pt`，前景 `theme.text`
- 速度：`10.8pt`，前景 `theme.muted`

---

### MachineInfoCard

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：`desktopcomputer`，`16.8pt`，前景 `theme.machineAccent`（深 `#94a3b8` / 浅 `#475569`），背景 `theme.machineAccent.opacity(0.20)`
- 标题"本机信息"：`14.4pt .semibold`，前景 `theme.text`
- 副标题"型号名 · 系统信息"：`12pt`，前景 `theme.muted`

**InfoCell 样式**
- 标签：`12pt .medium`，前景 `theme.muted`
- 数值（普通）：`14.4pt .medium`，前景 `theme.text`
- 数值（accent=true）：`14.4pt .bold`，前景 `theme.accent`（=`oceanCpuAccent`，`#00d4ff`）

---

### TopCPUCard

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：`chart.bar.fill`，`16.8pt`，前景 `theme.topAccent`（深 `#7dd3fc` / 浅 `#0369a1`），背景 `theme.topAccent.opacity(0.20)`，容器 `37.4×37.4`，圆角 `7.2`
- 标题"Top CPU 进程"：`15.6pt .semibold`，前景 `theme.text`

**进程列表**
- 进程名：`13.2pt`，前景 `theme.text`，宽度 `216pt`，居左，限 1 行
- PID：`10.8pt .monospaced`，前景 `theme.muted`，宽度 `43.2pt`
- CPU 百分比：`13.2pt .bold .monospaced`，前景 `theme.topAccent`（`#7dd3fc`）

---

### TopMemCard

**容器**
- `.background(theme.card)` → `oceanCard`

**Header**
- 图标：`memorychip.fill`，`16.8pt`，前景 `theme.topAccent`（`#7dd3fc`），背景 `theme.topAccent.opacity(0.20)`，容器 `37.4×37.4`，圆角 `7.2`
- 标题"Top 内存进程"：`15.6pt .semibold`，前景 `theme.text`

**进程列表**
- 进程名：`13.2pt`，前景 `theme.text`，宽度 `216pt`
- PID：`10.8pt .monospaced`，前景 `theme.muted`，宽度 `43.2pt`
- 内存MB：`13.2pt .bold .monospaced`，前景 `theme.topAccent`（`#7dd3fc`）

---

## 四、ContentView 背景层

- 底层：`Rectangle().fill(AppTheme.shared.surface)` → `oceanSurface`（深 `#0d1525` / 浅 `#f0f4f8`）
- Ocean 主题无额外渐变叠加层

---

## 五、Sparkline（SharedViews）

- 背景：`theme.sparklineBg` = `isDark ? border : border.opacity(0.4)`
  - 深色：`oceanBorder` = `#1e3054`
  - 浅色：`oceanBorder.opacity(0.4)` = `#c8d4e3` @ 40%
- 填充渐变：`theme.accent2`（=`oceanAccent2`，`#00e5cc`）opacity `0.45→0.02`，从上到下
- 线条（两次叠加）：
  - 第1次：`theme.accent2`，`4pt`，`lineCap=.round`，`lineJoin=.round`，`blur=2`（发光）
  - 第2次：`theme.accent2`，`1.5pt`，`lineCap=.round`，`lineJoin=.round`（清晰）
- 裁剪圆角：`4pt`

---

## 六、Ocean vs 8-bit 关键差异

| 属性 | Ocean | 8-bit |
|------|-------|-------|
| 页面背景 | `oceanBg` `#080c14` | `eightBitBg` `#1E1E1E` |
| 卡片背景 | `theme.card`=`oceanCard` | 目标：`theme.xxxCardBg`=accent@20% |
| 进度条背景 | `*CardBg`=`oceanBorder` | `*CardBg`=`xxxAccent@20%` |
| 进度条填充 | `xxxAccent→xxxGrad2` | `xxxAccent→xxxGrad2`（相同） |
| 图标背景 | `xxxAccent.opacity(0.20)` | `xxxAccent.opacity(0.20)`（相同） |
| 通用文字 | `oceanText`/`oceanMuted` | `eightBitText`/`eightBitMuted` |
| GPU Accent | `#fb923c` | Peach `#F5D5A0` |
| Network Accent | `#22d3ee` | Sky `#9DD3E8` |
| Disk Accent | `#34d399` | Lavender `#C4B0E8` |
| Battery Accent | `#fbbf24` | Olive `#C8C87A` |
