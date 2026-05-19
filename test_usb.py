#!/usr/bin/env python3
"""Verify USB collection logic before deploying."""
import subprocess
import re
import sys

def usb_speed_string(speed, link_bps):
    spec_map = {
        0: "USB 1.0",
        1: "USB 1.1",
        2: "USB 2.0",
        3: "USB 3.0",
        4: "USB 3.2 Gen2",
        5: "USB 3.2 Gen1",
    }
    spec = spec_map.get(speed, "")

    if not link_bps or link_bps == 0:
        return spec

    link_gbps = link_bps / 1_000_000_000

    floor_map = {
        2: 480_000_000,
        3: 5_000_000_000,
        4: 10_000_000_000,
        5: 5_000_000_000,
    }
    floor_bps = floor_map.get(speed, 0)

    if floor_bps > 0 and link_gbps > (floor_bps / 1_000_000_000) + 0.5:
        return f"{spec} ({link_gbps:.0f} Gbps)"
    return spec


def parse_ioreg(output):
    devices = []
    current = {}

    for line in output.split("\n"):
        trimmed = line.strip()

        # Top-level device: save previous and reset
        if trimmed.startswith("+-o ") and "IOUSBHostDevice" in trimmed:
            name = current.get("name")
            dev_class = current.get("class")
            speed = current.get("speed")
            link = current.get("link_speed")

            if name:
                if dev_class in (9, 17):
                    print(f"  SKIP hub: {name} (class={dev_class})")
                else:
                    speed_str = usb_speed_string(speed, link)
                    print(f"  ADD: {name} | class={dev_class} speed={speed} link={link} → '{speed_str}'")
                    devices.append({"name": name, "speed": speed_str})
            current = {}

        # Parse key-value pairs
        if '"bDeviceClass" = ' in trimmed:
            m = re.search(r'"bDeviceClass" = (\d+)', trimmed)
            if m: current["class"] = int(m.group(1))
        if '"USBSpeed" = ' in trimmed:
            m = re.search(r'"USBSpeed" = (\d+)', trimmed)
            if m: current["speed"] = int(m.group(1))
        if '"UsbLinkSpeed" = ' in trimmed:
            m = re.search(r'"UsbLinkSpeed" = (\d+)', trimmed)
            if m: current["link_speed"] = int(m.group(1))
        if '"USB Product Name" = ' in trimmed:
            m = re.search(r'"USB Product Name" = "([^"]+)"', trimmed)
            if m: current["name"] = m.group(1)

    # Last device
    name = current.get("name")
    if name:
        dev_class = current.get("class")
        if dev_class in (9, 17):
            print(f"  SKIP hub: {name} (class={dev_class})")
        else:
            speed = current.get("speed")
            link = current.get("link_speed")
            speed_str = usb_speed_string(speed, link)
            print(f"  ADD: {name} | class={dev_class} speed={speed} link={link} → '{speed_str}'")
            devices.append({"name": name, "speed": speed_str})

    return devices


result = subprocess.run(["/usr/sbin/ioreg", "-r", "-c", "IOUSBHostDevice"], capture_output=True, text=True)
output = result.stdout

print("=== ioreg raw (first 5 lines) ===")
for line in output.split("\n")[:5]:
    print(f"  {line}")

print("\n=== Parsed USB devices ===")
devices = parse_ioreg(output)

print(f"\n=== Result: {len(devices)} devices ===")
for d in devices:
    print(f"  {d['name']}: {d['speed']}")

if not devices:
    print("ERROR: No devices found! Check parsing logic.")
    sys.exit(1)
else:
    print("\nOK: Devices detected correctly.")
    sys.exit(0)
