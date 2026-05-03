# MiniPulse

macOS 系统监控仪表盘，实时追踪 Mac 的健康状态。

![Platform](https://img.shields.io/badge/Platform-macOS%2013+-orange)
![Swift](https://img.shields.io/badge/Swift-5.9-blue)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 功能特色

### 实时系统监控
- **CPU**：核心数、使用率、频率、温度
- **GPU**：使用率、温度（Apple Silicon）
- **内存**：已用/可用/总内存
- **磁盘**：容量、剩余空间、I/O 读写速度
- **网络**：实时上下行速率
- **电池**：充放电状态、电量百分比、循环次数
- **电源**：当前功率（W）、插电/电池状态
- **蓝牙/USB**：已连接设备列表
- **Top 进程**：CPU / 内存占用最高的进程

### 双主题系统
- **Ocean**：现代彩色风格，适合日常使用
- **8-bit**：复古像素风格，致敬经典游戏

主题选择保存在本地，重启后自动恢复上次选择。

### 自由排序
支持对监控卡片进行拖拽排序，可按个人关注重点自由排列布局顺序，顺序保存后永久生效。

### 轻量流畅
纯 SwiftUI + Darwin 层原生实现，无第三方依赖后台进程，内存占用极低。

---

## 使用说明

### 下载 & 安装

1. 前往 [Releases](https://github.com/Alienwang1980/MiniPulse/releases) 下载最新版 `MiniPulse-vX.X.X.zip`
2. 解压后拖入应用程序文件夹
3. 首次运行：右键 → 打开（选择"仍然打开"，绕过 Gatekeeper）

### 基本操作

**打开监控面板**：运行 MiniPulse 即可

**进入设置**：点击右上角 ⚙️ 按钮

在设置中可以：
- 切换主题（Ocean / 8-bit）
- 拖拽调整卡片排列顺序
- 提交反馈

**关闭应用**：菜单栏或 `Cmd + Q`

---

## 功能说明

### 卡片排序

在设置页面，点击右上角「调整顺序」进入排序模式，直接拖拽卡片即可重新排列。拖到你满意的位置后点击「完成」保存。

### 主题切换

点击「主题」下的预览卡片即可切换：
- **Ocean**：默认主题，彩色渐变卡片
- **8-bit**：像素字体 + 点阵背景，完整复古游戏界面风格

当前选择的主题会自动保存，关闭应用后再次打开会恢复上次的主题。

### 反馈

使用设置底部的 **Feedback** 按钮，可直接打开邮件客户端发送反馈到 `minipulsemac@gmail.com`。

---

## 运行环境要求

| 项目 | 要求 |
|------|------|
| 系统版本 | macOS 13.0 (Ventura) 及以上 |
| 芯片 | Apple Silicon (M1/M2/M3) 或 Intel |
| 内存 | 建议 4GB+ 可用 |
| 磁盘 | 50MB 可用空间 |

> **注意**：部分监控数据（如 GPU 温度、SMC 传感器）在不同 Mac 型号上可能有差异。电池循环次数仅在有电池的 Mac（MacBook）上显示。

---

## 项目结构

```
Sources/App/
├── SystemMonitor.swift     # 核心监控引擎，数据采集
├── AppTheme.swift          # 主题定义（Ocean / 8-bit）
├── CardType.swift          # 卡片类型枚举
├── ContentView.swift       # 主界面布局
├── SettingsPanel.swift     # 设置面板
├── EditOrderView.swift     # 卡片排序视图
├── PixelFont.swift         # 像素字体包装
├── PixelDotsBackground.swift  # 8-bit 点阵背景
├── SMC.swift               # SMC 传感器访问
├── IOHIDBridge.swift      # IOHID 温度传感器
├── IOReportBridge.swift    # I/O Report 磁盘/网络数据
└── Cards/                  # 各监控卡片实现
    ├── CpuCard.swift
    ├── GpuCard.swift
    ├── MemoryCard.swift
    ├── DiskCard.swift
    ├── NetworkCard.swift
    ├── BatteryCard.swift
    ├── PowerCard.swift
    └── ...
```

---

## 开发说明

### 编译

```bash
cd MiniPulseV2
xcodebuild -target MiniPulseV2 -configuration Debug CODE_SIGN_IDENTITY="-"
```

### 技术栈

- **UI**：SwiftUI
- **数据采集**：Darwin (IOKit, IOHIDEvent, SMC, IORegistry)
- **主题**：自定义 @Observable Theme 协议
- **无外部依赖**：纯 Apple 原生框架

---

**► Made with ♥ by Alienwang**
