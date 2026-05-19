# 8-bit Theme — Complete UI Color Spec
**更新时间：2026-05-01**

---

## 一、基础色板

### 1.1 全局背景色
| 变量 | 深色模式 | 浅色模式 | 用途 |
|------|---------|---------|------|
| `bg` / `surface` | `#1E1E1E` | `#F0F0F0` | App 背景 + Header/Footer/ContentView 背景 |
| `card` | `#2E2620` | `#FFFFFF` | **未使用**（卡片不使用此颜色，统一用 `xxxCardBg`） |
| `cardHover` | `#3A302A` | `#FDF2E9` | 未使用（无悬停效果） |

### 1.2 全局文字色
| 变量 | 深色模式 | 浅色模式 | 用途 |
|------|---------|---------|------|
| `text` | `#FFF5EB`（暖白） | `#2D3436`（深灰） | 标题、卡片名称、数值 |
| `muted` | `#A09080`（暖灰） | `#636E72`（中性灰） | 副标题、标签、次要文字 |

### 1.3 全局边框/分割线
| 变量 | 深色模式 | 浅色模式 | 用途 |
|------|---------|---------|------|
| `border` | `#3A302A` | `#F0E0D0` | 未被任何卡片使用（已解耦） |
| `borderHi` | `#5A4E48` | `#E8D5C4` | 未使用 |

### 1.4 通用 Status 色（按负载级别）
| 变量 | 深色模式 | 浅色模式 | 用途 |
|------|---------|---------|------|
| `green` / `loadLow` | `#8ED8BE` | `#5A9A82` | 绿色（低负载/空闲/健康） |
| `yellow` / `loadMid` | `#F5D5A0` | `#C4A870` | 黄色（中负载/警告） |
| `red` / `loadHigh` | `#E8A598` | `#BA7A6E` | 红色（高负载/危险） |
| `orange` | `#F5D5A0` | `#C4A870` | 橙色（等同于 yellow） |
| `cyan` | `#9DD3E8` | `#6A9AB8` | 青色（网络发送/部分数值） |

### 1.5 通用 Accent 别名
| 变量 | 深色模式 | 浅色模式 | 用途 |
|------|---------|---------|------|
| `accent` | `#E8A598` | `#BA7A6E` | 珊瑚红（品牌主色，CPU accent） |
| `accent2` | `#8ED8BE` | `#5A9A82` | 薄荷绿（Memory accent） |
| `accent3` | `#F5D5A0` | `#C4A870` | 蜜桃黄（GPU accent） |

---

## 二、6 色相色板（卡片专属品牌色）

### 2.1 Accent 色（实色）
| 卡片 | 变量 | 深色 | 浅色 |
|------|------|------|------|
| CPU | `cpuAccent` | `#E8A598` 珊瑚红 | `#BA7A6E` |
| Memory | `memAccent` | `#8ED8BE` 薄荷绿 | `#5A9A82` |
| GPU | `gpuAccent` | `#F5D5A0` 蜜桃黄 | `#C4A870` |
| Network | `netAccent` | `#9DD3E8` 天蓝 | `#6A9AB8` |
| Disk | `diskAccent` | `#C4B0E8` 薰衣草紫 | `#9870B8` |
| Battery | `batteryAccent` | `#C8C87A` 橄榄绿 | `#9A9A50` |
| Power | `powerAccent` | `#E8A598` 珊瑚红 | `#BA7A6E` |
| Bluetooth | `bluetoothAccent` | `#9DD3E8` 天蓝 | `#6A9AB8` |
| USB | `usbAccent` | `#C4B0E8` 薰衣草紫 | `#9870B8` |
| MachineInfo | `machineAccent` | `#F5D5A0` 蜜桃黄 | `#C4A870` |
| TopCPU/TopMem | `topAccent` | `#8ED8BE` 薄荷绿 | `#5A9A82` |

### 2.2 CardBg 色（Accent 20% 透明度）
> **核心规则：所有卡片背景、所有进度条/Sparkline 背景、所有分割线背景，均使用对应卡片的 CardBg 色。**

| 卡片 | 变量 | 深色 | 浅色 |
|------|------|------|------|
| CPU | `cpuCardBg` | `#E8A598` @ 20% | `#BA7A6E` @ 20% |
| Memory | `memCardBg` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| GPU | `gpuCardBg` | `#F5D5A0` @ 20% | `#C4A870` @ 20% |
| Network | `netCardBg` | `#9DD3E8` @ 20% | `#6A9AB8` @ 20% |
| Disk | `diskCardBg` | `#C4B0E8` @ 20% | `#9870B8` @ 20% |
| Battery | `batteryCardBg` | `#C8C87A` @ 20% | `#9A9A50` @ 20% |
| Power | `powerCardBg` | `#E8A598` @ 20% | `#BA7A6E` @ 20% |
| Bluetooth | `bluetoothCardBg` | `#9DD3E8` @ 20% | `#6A9AB8` @ 20% |
| USB | `usbCardBg` | `#C4B0E8` @ 20% | `#9870B8` @ 20% |
| MachineInfo | `machineCardBg` | `#F5D5A0` @ 20% | `#C4A870` @ 20% |
| TopCPU/TopMem | `topCardBg` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |

---

## 三、每张卡片 — 所有 UI 元素颜色详解

---

### 🔴 CPU Card（珊瑚红 `#E8A598` / `#BA7A6E`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.cpuCardBg` | `#E8A598` @ 20% | `#BA7A6E` @ 20% |
| **图标圆圈背景** | `theme.cpuAccent.opacity(0.20)` | `#E8A598` @ 20% | `#BA7A6E` @ 20% |
| **图标 (SF Symbol)** | `theme.cpuAccent` | `#E8A598` | `#BA7A6E` |
| **温度图标** | `theme.cpuAccent` | `#E8A598` | `#BA7A6E` |
| **温度数值** | `theme.cpuAccent` | `#E8A598` | `#BA7A6E` |
| **主百分比数值** | `theme.cpuAccent` | `#E8A598` | `#BA7A6E` |
| **"%" 单位符号** | `theme.muted` | `#A09080` | `#636E72` |
| **副标题（核/线程数）** | `theme.muted` | `#A09080` | `#636E72` |
| **CPU 进度条背景** | `theme.cpuAccent.opacity(0.20)` | `#E8A598` @ 20% | `#BA7A6E` @ 20% |
| **CPU 进度条填充** | `LinearGradient` `cpuAccent → cpuGrad2` | `#E8A598 → #0099ff` | `#BA7A6E → #70C0FF` |
| **Core Bar 背景**（每个核心） | `theme.cpuAccent.opacity(0.20)` | `#E8A598` @ 20% | `#BA7A6E` @ 20% |
| **Core Bar 填充 >80%** | `LinearGradient` `red → cpuRed` | `#E8A598 → #ff1744` | `#BA7A6E → #FF5070` |
| **Core Bar 填充 50-80%** | `LinearGradient` `yellow → orange` | `#F5D5A0 → #F5D5A0` | `#C4A870 → #C4A870` |
| **Core Bar 填充 <50%** | `LinearGradient` `cpuAccent → cpuLow` | `#E8A598 → #E8A598` | `#BA7A6E → #F5D5A0` |
| **核心编号文字** | `theme.muted` | `#A09080` | `#636E72` |
| **"时间分解" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **User %** | `theme.accent` | `#E8A598` | `#BA7A6E` |
| **System %** | `theme.orange` | `#F5D5A0` | `#C4A870` |
| **频率** | `theme.accent2` | `#8ED8BE` | `#5A9A82` |
| **空闲 %** | `theme.green` | `#8ED8BE` | `#5A9A82` |

---

### 🟢 Memory Card（薄荷绿 `#8ED8BE` / `#5A9A82`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.memCardBg` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| **图标圆圈背景** | `theme.memAccent.opacity(0.20)` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| **图标 (SF Symbol)** | `theme.memAccent` | `#8ED8BE` | `#5A9A82` |
| **主百分比数值** | `theme.memAccent` | `#8ED8BE` | `#5A9A82` |
| **"%" 单位符号** | `theme.muted` | `#A09080` | `#636E72` |
| **副标题（总内存 GB）** | `theme.muted` | `#A09080` | `#636E72` |
| **内存条（used/total）** | `theme.muted` | `#A09080` | `#636E72` |
| **内存进度条背景** | `theme.memAccent.opacity(0.20)` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| **内存进度条填充** | `LinearGradient` `memAccent → memGrad2` | `#8ED8BE → #7c3aed` | `#5A9A82 → #B080F0` |
| **DetailRow: 已用** | `theme.accent3` | `#F5D5A0` | `#C4A870` |
| **DetailRow: 可用** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **"Swap" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **Swap Used GB** | `theme.orange` | `#F5D5A0` | `#C4A870` |
| **Swap "/" 分隔符** | `theme.muted` | `#A09080` | `#636E72` |
| **Swap Total GB** | `theme.muted` | `#A09080` | `#636E72` |
| **Swap %** | `theme.orange` | `#F5D5A0` | `#C4A870` |
| **Swap 进度条背景** | `theme.memAccent.opacity(0.20)` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| **Swap 进度条填充** | `LinearGradient` `swapGrad1 → swapGrad2` | `#f87171 → #ff1744` | `#FF9070 → #FF5070` |

---

### 🟡 GPU Card（蜜桃黄 `#F5D5A0` / `#C4A870`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.gpuCardBg` | `#F5D5A0` @ 20% | `#C4A870` @ 20% |
| **图标圆圈背景** | `theme.gpuAccent.opacity(0.20)` | `#F5D5A0` @ 20% | `#C4A870` @ 20% |
| **图标 (SF Symbol)** | `theme.gpuAccent` | `#F5D5A0` | `#C4A870` |
| **主百分比数值** | `theme.gpuAccent` | `#F5D5A0` | `#C4A870` |
| **"%" 单位符号** | `theme.muted` | `#A09080` | `#636E72` |
| **"GPU 占用" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **GPU 名称副标题** | `theme.muted` | `#A09080` | `#636E72` |
| **Sparkline 背景** | `theme.gpuAccent.opacity(0.20)` | `#F5D5A0` @ 20% | `#C4A870` @ 20% |
| **Sparkline 波浪线** | `theme.accent2` | `#8ED8BE` | `#5A9A82` |
| **Sparkline 填充渐变** | `LinearGradient` `accent2.opacity(0.45) → accent2.opacity(0.02)` | `#8ED8BE` @ 45% → 2% | `#5A9A82` @ 45% → 2% |
| **DetailRow: 名称** | `theme.accent2` | `#8ED8BE` | `#5A9A82` |
| **DetailRow: VRAM** | `theme.accent3` | `#F5D5A0` | `#C4A870` |
| **DetailRow: 核心** | `theme.muted` | `#A09080` | `#636E72` |

---

### 🟣 Disk Card（薰衣草紫 `#C4B0E8` / `#9870B8`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.diskCardBg` | `#C4B0E8` @ 20% | `#9870B8` @ 20% |
| **图标圆圈背景** | `theme.diskAccent.opacity(0.20)` | `#C4B0E8` @ 20% | `#9870B8` @ 20% |
| **图标 (SF Symbol)** | `theme.diskAccent` | `#C4B0E8` | `#9870B8` |
| **SSD 温度图标** | `theme.diskAccent` | `#C4B0E8` | `#9870B8` |
| **SSD 温度数值** | `theme.diskAccent` | `#C4B0E8` | `#9870B8` |
| **"↓ 读取" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **读取速度数值** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **"↑ 写入" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **写入速度数值** | `theme.accent` | `#E8A598` | `#BA7A6E` |
| **"MB/s" 单位** | `theme.muted` | `#A09080` | `#636E72` |
| **分割线** | `theme.diskCardBg` | `#C4B0E8` @ 20% | `#9870B8` @ 20% |
| **磁盘图标** | `theme.diskAccent` | `#C4B0E8` | `#9870B8` |
| **磁盘名称** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **已用 % 数值 >90%** | `theme.red` | `#E8A598` | `#BA7A6E` |
| **已用 % 数值 70-90%** | `theme.yellow` | `#F5D5A0` | `#C4A870` |
| **已用 % 数值 <70%** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **剩余空间文字** | `theme.muted` | `#A09080` | `#636E72` |
| **磁盘进度条背景** | `theme.diskAccent.opacity(0.20)` | `#C4B0E8` @ 20% | `#9870B8` @ 20% |
| **磁盘进度条填充 >90%** | `LinearGradient` `red → diskRed` | `#E8A598 → #ff1744` | `#BA7A6E → #FF5070` |
| **磁盘进度条填充 70-90%** | `LinearGradient` `yellow → orange` | `#F5D5A0 → #F5D5A0` | `#C4A870 → #C4A870` |
| **磁盘进度条填充 <70%** | `LinearGradient` `diskGrad1 → diskGrad2` | `#34d399 → #16a34a` | `#70E0A8 → #50C080` |
| **未挂载图标** | `theme.muted` | `#A09080` | `#636E72` |
| **未挂载名称** | `theme.muted` | `#A09080` | `#636E72` |
| **"未挂载" 文字** | `theme.muted` | `#A09080` | `#636E72` |

---

### 🔵 Network Card（天蓝 `#9DD3E8` / `#6A9AB8`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.netCardBg` | `#9DD3E8` @ 20% | `#6A9AB8` @ 20% |
| **图标圆圈背景** | `theme.netAccent.opacity(0.20)` | `#9DD3E8` @ 20% | `#6A9AB8` @ 20% |
| **图标 (SF Symbol)** | `theme.netAccent` | `#9DD3E8` | `#6A9AB8` |
| **"网络 I/O" 标题** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **"实时速度" 副标题** | `theme.muted` | `#A09080` | `#636E72` |
| **"↓ 接收" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **接收速度数值** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **"↑ 发送" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **发送速度数值** | `theme.accent` | `#E8A598` | `#BA7A6E` |
| **速度单位** | `theme.muted` | `#A09080` | `#636E72` |
| **分割线 1** | `theme.netCardBg` | `#9DD3E8` @ 20% | `#6A9AB8` @ 20% |
| **接口名称** | `theme.muted` | `#A09080` | `#636E72` |
| **接口 IP** | `theme.accent2` | `#8ED8BE` | `#5A9A82` |
| **接口接收速度** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **接口发送速度** | `theme.accent` | `#E8A598` | `#BA7A6E` |
| **分割线 2** | `theme.netCardBg` | `#9DD3E8` @ 20% | `#6A9AB8` @ 20% |
| **"总发送" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **总发送数值** | `theme.accent2` | `#8ED8BE` | `#5A9A82` |
| **"总接收" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **总接收数值** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **"🔍 网络诊断" 按钮** | `theme.muted` | `#A09080` | `#636E72` |

---

### 🟡 Battery Card（橄榄绿 `#C8C87A` / `#9A9A50`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.batteryCardBg` | `#C8C87A` @ 20% | `#9A9A50` @ 20% |
| **电池图标圆圈背景** | `theme.green.opacity(0.20)` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| **电池图标 (SF Symbol)** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **"电池" 标题** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **状态文字（电源已接通/电池供电）** | `theme.muted` | `#A09080` | `#636E72` |
| **温度图标** | `theme.batteryAccent` | `#C8C87A` | `#9A9A50` |
| **温度数值** | `theme.batteryAccent` | `#C8C87A` | `#9A9A50` |
| **主百分比数值 >50%** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **主百分比数值 20-50%** | `theme.yellow` | `#F5D5A0` | `#C4A870` |
| **主百分比数值 <20%** | `theme.red` | `#E8A598` | `#BA7A6E` |
| **"%" 单位** | `theme.muted` | `#A09080` | `#636E72` |
| **"⚡ 充电中"** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **"🔋 使用中"** | `theme.yellow` | `#F5D5A0` | `#C4A870` |
| **累计运行时间** | `theme.muted` | `#A09080` | `#636E72` |
| **电池进度条背景** | `theme.batteryAccent.opacity(0.20)` | `#C8C87A` @ 20% | `#9A9A50` @ 20% |
| **电池进度条填充** | `percentColor`（同主百分比颜色逻辑） | — | — |
| **BatteryMetric 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **BatteryMetric 数值（循环/健康/容量/电压）** | `valueColor`（healthColor: green/yellow/red; default: muted） | — | — |
| **无电池时文字** | `theme.muted` | `#A09080` | `#636E72` |

> **注意**：Battery Card 是唯一一个图标圆圈用 `green` 而非 `batteryAccent` 的卡片。

---

### 🟠 Power Card（功率，橄榄绿 `#C8C87A` / `#9A9A50`，但图标圆圈用 `batteryAccent`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.batteryAccent.opacity(0.20)` | `#C8C87A` @ 20% | `#9A9A50` @ 20% |
| **图标圆圈背景** | `theme.batteryAccent.opacity(0.20)` | `#C8C87A` @ 20% | `#9A9A50` @ 20% |
| **图标 (bolt.fill)** | `theme.batteryAccent` | `#C8C87A` | `#9A9A50` |
| **"功率" 标题** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **副标题（电池供电/电源已接通/SOC功耗）** | `theme.muted` | `#A09080` | `#636E72` |
| **总功耗数值 (W)** | `theme.orange` | `#F5D5A0` | `#C4A870` |
| **"W" 单位** | `theme.muted` | `#A09080` | `#636E72` |
| **"总功耗" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **"CPU 功耗" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **CPU 功耗数值** | `theme.accent` | `#E8A598` | `#BA7A6E` |
| **"GPU 功耗" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **GPU 功耗数值** | `theme.accent2` | `#8ED8BE` | `#5A9A82` |
| **"板载功耗" 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **板载功耗数值** | `theme.muted` | `#A09080` | `#636E72` |

---

### 🔵 Bluetooth Card（天蓝 `#9DD3E8` / `#6A9AB8`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.bluetoothCardBg` | `#9DD3E8` @ 20% | `#6A9AB8` @ 20% |
| **图标圆圈背景** | `theme.bluetoothAccent.opacity(0.20)` | `#9DD3E8` @ 20% | `#6A9AB8` @ 20% |
| **图标 (SF Symbol)** | `theme.bluetoothAccent` | `#9DD3E8` | `#6A9AB8` |
| **"蓝牙" 标题** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **"已配对设备" 副标题** | `theme.muted` | `#A09080` | `#636E72` |
| **连接状态圆点（已连接）** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **连接状态圆点（未连接）** | `theme.muted` | `#A09080` | `#636E72` |
| **设备名称** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **设备类型** | `theme.muted` | `#A09080` | `#636E72` |
| **无设备时文字** | `theme.muted` | `#A09080` | `#636E72` |

---

### 🟣 USB Card（薰衣草紫 `#C4B0E8` / `#9870B8`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.usbCardBg` | `#C4B0E8` @ 20% | `#9870B8` @ 20% |
| **图标圆圈背景** | `theme.usbAccent.opacity(0.20)` | `#C4B0E8` @ 20% | `#9870B8` @ 20% |
| **图标 (SF Symbol)** | `theme.usbAccent` | `#C4B0E8` | `#9870B8` |
| **"USB" 标题** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **"已连接设备" 副标题** | `theme.muted` | `#A09080` | `#636E72` |
| **连接状态圆点** | `theme.green` | `#8ED8BE` | `#5A9A82` |
| **设备名称** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **设备速度** | `theme.muted` | `#A09080` | `#636E72` |
| **无设备时文字** | `theme.muted` | `#A09080` | `#636E72` |

---

### 🟡 MachineInfo Card（蜜桃黄 `#F5D5A0` / `#C4A870`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.machineCardBg` | `#F5D5A0` @ 20% | `#C4A870` @ 20% |
| **图标圆圈背景** | `theme.machineAccent.opacity(0.20)` | `#F5D5A0` @ 20% | `#C4A870` @ 20% |
| **图标 (desktopcomputer)** | `theme.machineAccent` | `#F5D5A0` | `#C4A870` |
| **"本机信息" 标题** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **副标题（型号 · 系统信息）** | `theme.muted` | `#A09080` | `#636E72` |
| **InfoCell 标签** | `theme.muted` | `#A09080` | `#636E72` |
| **InfoCell 数值（accent=true）** | `theme.accent`（即 `cpuAccent` 珊瑚红） | `#E8A598` | `#BA7A6E` |
| **InfoCell 数值（accent=false）** | `theme.text` | `#FFF5EB` | `#2D3436` |

---

### 🟢 TopCPU Card（薄荷绿 `#8ED8BE` / `#5A9A82`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.topCardBg` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| **图标圆圈背景** | `theme.topAccent.opacity(0.20)` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| **图标 (chart.bar.fill)** | `theme.topAccent` | `#8ED8BE` | `#5A9A82` |
| **"Top CPU 进程" 标题** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **进程名称** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **PID** | `theme.muted` | `#A09080` | `#636E72` |
| **CPU % 数值** | `theme.topAccent` | `#8ED8BE` | `#5A9A82` |

---

### 🟢 TopMem Card（薄荷绿 `#8ED8BE` / `#5A9A82`）

| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **卡片背景** | `theme.topCardBg` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| **图标圆圈背景** | `theme.topAccent.opacity(0.20)` | `#8ED8BE` @ 20% | `#5A9A82` @ 20% |
| **图标 (memorychip.fill)** | `theme.topAccent` | `#8ED8BE` | `#5A9A82` |
| **"Top 内存进程" 标题** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **进程名称** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **PID** | `theme.muted` | `#A09080` | `#636E72` |
| **内存 MB 数值** | `theme.topAccent` | `#8ED8BE` | `#5A9A82` |

---

## 四、全局 Shell 元素

### HeaderView
| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **设备图标圆圈背景** | `theme.accent.opacity(0.15)` | `#E8A598` @ 15% | `#BA7A6E` @ 15% |
| **设备图标** | `theme.accent` | `#E8A598` | `#BA7A6E` |
| **用户名** | `theme.text` | `#FFF5EB` | `#2D3436` |
| **型号名** | `theme.muted` | `#A09080` | `#636E72` |
| **运行时长** | `theme.muted` | `#A09080` | `#636E72` |
| **设置/编辑按钮图标** | `theme.muted` | `#A09080` | `#636E72` |
| **Logo** | `logo_dark` / `logo_light`（图片资源） | — | — |
| **Header 背景** | `FrostedGlassView` / `LiquidGlassHeaderBackground` | macOS 系统模糊 | 系统模糊 |

### FooterView
| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **"mini pulse"** | `theme.muted` | `#A09080` | `#636E72` |
| **主机名** | `theme.muted` | `#A09080` | `#636E72` |
| **"3s refresh"** | `theme.muted` | `#A09080` | `#636E72` |
| **Footer 背景** | `theme.surface` | `#1E1E1E` | `#F0F0F0` |

### SplashView
| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **背景（深色）** | `Color.black.opacity(0.4)` + `.ultraThinMaterial` | — | — |
| **背景（浅色）** | `Color.white` | `#FFFFFF` | — |
| **Slogan 文字** | `theme.accent` | `#E8A598` | `#BA7A6E` |
| **Slogan 阴影** | `theme.accent.opacity(0.4)` | `#E8A598` @ 40% | `#BA7A6E` @ 40% |
| **Logo** | `logo_splash` / `logo_splash_light`（图片资源） | — | — |

### SettingsPanel
| UI 元素 | 颜色变量 | 深色值 | 浅色值 |
|---------|---------|--------|--------|
| **"设置" 标题** | `AppTheme.shared.text` | `#FFF5EB` | `#2D3436` |
| **关闭按钮** | `AppTheme.shared.muted` | `#A09080` | `#636E72` |
| **"主题" 标签** | `AppTheme.shared.muted` | `#A09080` | `#636E72` |
| **ThemeButton 选中环** | `AppTheme.shared.accent` | `#E8A598` | `#BA7A6E` |
| **ThemeButton 预览（Ocean）** | 硬编码 `["1a2537", "2d4a6f"]` | — | — |
| **ThemeButton 预览（8-bit）** | 硬编码 `["1A1512", "2A2520"]` | — | — |
| **ThemeButton 文字（Ocean）** | `Color.white.opacity(0.9)` | — | — |
| **ThemeButton 文字（8-bit）** | `Color(hex: "FAB1A0")` | — | — |
| **版本文字** | `AppTheme.shared.muted.opacity(0.5)` | `#A09080` @ 50% | `#636E72` @ 50% |
| **面板背景** | `AppTheme.shared.surface` | `#1E1E1E` | `#F0F0F0` |

---

## 五、背景纹理（8-bit 专属）

### ContentView 背景
- **底层**：`AppTheme.shared.surface` = `#1E1E1E`（深色）/ `#F0F0F0`（浅色）
- **渐变晕染层**：`LinearGradient` 6 色相各 6-10% opacity，斜向渐变
- **像素点层**：`PixelDotsBackground`，6 色相 @ 10% opacity，6 层偏移叠加

### PixelDotsBackground 色板
| 模式 | 颜色 | Hex |
|------|------|-----|
| 深色 - 层1 | 珊瑚红 | `#E8A598` |
| 深色 - 层2 | 薄荷绿 | `#8ED8BE` |
| 深色 - 层3 | 蜜桃黄 | `#F5D5A0` |
| 深色 - 层4 | 天蓝 | `#9DD3E8` |
| 深色 - 层5 | 薰衣草紫 | `#C4B0E8` |
| 深色 - 层6 | 橄榄绿 | `#C8C87A` |
| 浅色 - 层1 | 浅珊瑚红 | `#F5C4C4` |
| 浅色 - 层2 | 浅薄荷绿 | `#B8E8D8` |
| 浅色 - 层3 | 浅蜜桃黄 | `#F0D890` |
| 浅色 - 层4 | 浅天蓝 | `#A0C8F0` |
| 浅色 - 层5 | 浅薰衣草紫 | `#D0A8E8` |

---

## 六、进度条渐变色速查

### CPU 进度条
| 状态 | 深色 | 浅色 |
|------|------|------|
| 填充（低） | `#E8A598 → #E8A598`（实色到实色） | `#BA7A6E → #F5D5A0` |

### CPU Core Bar
| 负载区间 | 深色 | 浅色 |
|---------|------|------|
| >80% | `#E8A598 → #ff1744` | `#BA7A6E → #FF5070` |
| 50-80% | `#F5D5A0 → #F5D5A0` | `#C4A870 → #C4A870` |
| <50% | `#E8A598 → #E8A598` | `#BA7A6E → #F5D5A0` |

### Memory 进度条
| 区间 | 深色 | 浅色 |
|------|------|------|
| 填充 | `#8ED8BE → #7c3aed` | `#5A9A82 → #B080F0` |

### Swap 进度条
| 区间 | 深色 | 浅色 |
|------|------|------|
| 填充 | `#f87171 → #ff1744` | `#FF9070 → #FF5070` |

### Disk 进度条
| 负载区间 | 深色 | 浅色 |
|---------|------|------|
| >90% | `#E8A598 → #ff1744` | `#BA7A6E → #FF5070` |
| 70-90% | `#F5D5A0 → #F5D5A0` | `#C4A870 → #C4A870` |
| <70% | `#34d399 → #16a34a` | `#70E0A8 → #50C080` |

---

## 七、关键设计规则总结

1. **所有卡片背景** = `xxxCardBg` = 对应 accent @ 20% opacity
2. **所有进度条背景** = `xxxAccent.opacity(0.20)` = 同卡片 accent
3. **所有分割线背景** = `xxxCardBg` = 对应 accent @ 20% opacity
4. **图标圆圈背景** = `xxxAccent.opacity(0.20)` = 同 accent
5. **图标本身** = `xxxAccent` = 实色
6. **主数值** = `xxxAccent` = 实色
7. **次要文字/标签** = `theme.muted`
8. **主标题文字** = `theme.text`
9. **Status 色**（green/yellow/red）用于负载指示，不用于卡片主色
