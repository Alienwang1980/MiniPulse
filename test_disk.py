#!/usr/bin/env python3
"""
MiniPulseV2 Disk Collection Test
复制 SystemMonitor.swift performDiskCollection() 的逻辑，输出到文件
"""
import subprocess
import datetime
import platform

def get_disk_info():
    """模拟 Swift performDiskCollection() 的逻辑"""
    result = {}
    
    try:
        output = subprocess.check_output(['df', '-k'], text=True)
    except Exception as e:
        result['error'] = str(e)
        return result
    
    lines = output.strip().split('\n')
    
    # 跳过 header (OSX 输出第一行是 volume list)
    # df -k header: "Filesystem      1K-blocks      Used Available Capacity  Mounted on"
    # 或者 OSX 直接是数据 (没有 header)
    
    skip_mounts = {
        '/System/Volumes/Data',       # APFS Data 卷，与 / 同一 container
        '/System/Volumes/Preboot',   # APFS Preboot
        '/System/Volumes/VM',        # APFS VM
        '/System/Volumes/Update',    # APFS Update
        '/System/Volumes/Hardware',   # APFS Hardware
        '/System/Volumes/xarts',     # APFS xART (lowercase in df output!)
        '/System/Volumes/iSCPreboot', # APFS iSCPreboot
        '/Volumes/Time Machine Backups',
        '/Library/Application Support',
    }
    
    seen_devs = set()
    disks = []
    
    raw_lines = []
    
    for line in lines:
        raw_lines.append(line)
        
        parts = line.split()
        if len(parts) < 9:
            continue
        
        # Skip non-numeric rows (e.g. "map auto_home")
        try:
            float(parts[1])
        except ValueError:
            continue
        
        # Mount point is always the LAST token starting with "/"
        mount_point = None
        for part in reversed(parts):
            if part.startswith('/'):
                mount_point = part
                break
        if mount_point is None:
            continue
        
        device = parts[0]
        total_kb_str = parts[1]
        available_kb_str = parts[3]
        
        # 跳过非数字行 (如 "map auto_home")
        try:
            total_kb = float(total_kb_str)
            available_kb = float(available_kb_str)
        except ValueError:
            continue
        
        # 跳过容量 <= 1MB 的 (系统保留)
        if total_kb <= 1024:
            continue
        
        # 跳过已见过的设备 (APFS Container 去重)
        if device in seen_devs:
            continue
        
        # 跳过特定挂载点 (exact match, same as Swift skipMounts.contains)
        if mount_point in skip_mounts:
            continue
        
        # 跳过 App Translocation 路径（macOS 安全隔离的下载应用临时路径）
        if '/AppTranslocation/' in mount_point:
            continue
        
        # 跳过网络磁盘 (// 开头的)
        if mount_point.startswith('//'):
            continue
        
        seen_devs.add(device)
        
        total_bytes = total_kb * 1024
        available_bytes = available_kb * 1024
        used_bytes = total_bytes - available_bytes
        
        # 转换为 GB (10^9 bytes)
        total_gb = total_bytes / (1024**3)
        available_gb = available_bytes / (1024**3)
        used_gb = used_bytes / (1024**3)
        
        disks.append({
            'device': device,
            'mount_point': mount_point,
            'total_gb': round(total_gb, 1),
            'available_gb': round(available_gb, 1),
            'used_gb': round(used_gb, 1),
        })
    
    result['disks'] = disks
    result['raw_df'] = raw_lines
    return result


if __name__ == '__main__':
    hostname = platform.node()
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    info = get_disk_info()
    
    output_path = f'/tmp/minipulse_disk_test_{hostname}.txt'
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(f"MiniPulseV2 Disk Test\n")
        f.write(f"=" * 50 + '\n')
        f.write(f"Host: {hostname}\n")
        f.write(f"Time: {timestamp}\n\n")
        
        if 'error' in info:
            f.write(f"ERROR: {info['error']}\n")
        else:
            f.write(f"Raw df -k output:\n")
            f.write(f"-" * 50 + '\n')
            for line in info['raw_df']:
                f.write(line + '\n')
            
            f.write(f"\n\nParsed disks:\n")
            f.write(f"-" * 50 + '\n')
            for i, disk in enumerate(info['disks'], 1):
                f.write(f"\nDisk #{i}:\n")
                f.write(f"  Device: {disk['device']}\n")
                f.write(f"  Mount: {disk['mount_point']}\n")
                f.write(f"  Total: {disk['total_gb']} GB\n")
                f.write(f"  Used: {disk['used_gb']} GB\n")
                f.write(f"  Available: {disk['available_gb']} GB\n")
            
            f.write(f"\n\nSummary:\n")
            f.write(f"-" * 50 + '\n')
            for disk in info['disks']:
                f.write(f"{disk['mount_point']}: {disk['available_gb']}GB available / {disk['total_gb']}GB total\n")
    
    print(f"结果已保存到: {output_path}")
    print()
    print(f"磁盘数量: {len(info.get('disks', []))}")
    for disk in info.get('disks', []):
        print(f"  {disk['mount_point']}: {disk['available_gb']}GB 可用 / {disk['total_gb']}GB 总计")
