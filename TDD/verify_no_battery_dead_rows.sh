#!/bin/bash
# TDD Test: BatteryCard should have no empty HStack rows
# RED: Should find empty Spacer-only HStack in BatteryCard
# GREEN: No empty HStack rows

set -e

MATCH=$(grep -n "Spacer()$" ~/Documents/Project/MiniPulseV2/Sources/App/BatteryCard.swift | grep "HStack" -B1 || true)
if [ -n "$MATCH" ]; then
    echo "FAIL: Found empty Spacer-only HStack rows in BatteryCard.swift"
    exit 1
else
    echo "PASS: No empty Spacer-only HStack rows found"
    exit 0
fi
