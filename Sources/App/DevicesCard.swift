import SwiftUI

// MARK: - Bluetooth Card

struct BluetoothCard: View {
    let devices: DeviceInfo
    private var theme: AppTheme { AppTheme.shared }


    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 16.8))
                    .foregroundColor(theme.bluetoothAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.bluetoothAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("蓝牙")
                        .font(.system(size: 14.4, weight: .semibold))
                        .foregroundColor(theme.text)
                    Text("已配对设备")
                        .font(.system(size: 12))
                        .foregroundColor(theme.muted)
                }
                Spacer()
            }

            if devices.bluetooth.isEmpty {
                Text("无已配对设备")
                    .font(.system(size: 13.2))
                    .foregroundColor(theme.muted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                VStack(alignment: .leading, spacing: 7.2) {
                    ForEach(devices.bluetooth.prefix(8)) { device in
                        HStack(spacing: 7.2) {
                            Circle()
                                .fill(device.status == "connected" ? theme.green : theme.muted)
                                .frame(width: 8.6, height: 8.6)
                            Text(device.name)
                                .font(.system(size: 13.2))
                                .foregroundColor(theme.text)
                                .lineLimit(1)
                            Spacer()
                            Text(device.type)
                                .font(.system(size: 10.8))
                                .foregroundColor(theme.muted)
                        }
                    }
                }
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.bluetoothCardBg : theme.card)
        .cornerRadius(14.4)
    }
}

// MARK: - USB Card

struct UsbCard: View {
    let devices: DeviceInfo
    private var theme: AppTheme { AppTheme.shared }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9.6) {
                Image(systemName: "cable.connector")
                    .font(.system(size: 16.8))
                    .foregroundColor(theme.usbAccent)
                    .frame(width: 40.3, height: 40.3)
                    .background(theme.usbAccent.opacity(0.20))
                    .cornerRadius(9.6)
                VStack(alignment: .leading, spacing: 1.2) {
                    Text("USB")
                        .font(.system(size: 14.4, weight: .semibold))
                        .foregroundColor(theme.text)
                    Text("已连接设备")
                        .font(.system(size: 12))
                        .foregroundColor(theme.muted)
                }
                Spacer()
            }

            if devices.usb.isEmpty {
                Text("无设备")
                    .font(.system(size: 13.2))
                    .foregroundColor(theme.muted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                VStack(alignment: .leading, spacing: 7.2) {
                    ForEach(devices.usb.prefix(10)) { device in
                        HStack(spacing: 7.2) {
                            Circle()
                                .fill(theme.green)
                                .frame(width: 8.6, height: 8.6)
                            Text(device.name)
                                .font(.system(size: 13.2))
                                .foregroundColor(theme.text)
                                .lineLimit(1)
                            Spacer()
                            if !device.speed.isEmpty {
                                Text(device.speed)
                                    .font(.system(size: 10.8))
                                    .foregroundColor(theme.muted)
                            }
                        }
                    }
                }
            }
        }
        .padding(19.2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.isEightBit ? theme.usbCardBg : theme.card)
        .cornerRadius(14.4)
    }
}
