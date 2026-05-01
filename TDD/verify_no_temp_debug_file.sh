#!/bin/bash
# TDD Test: No temperature debug file writes should exist in production code
# RED: This test should FAIL before the fix (file write exists)
# GREEN: This test should PASS after removing the debug file write

set -e

echo "=== TDD Verification: No temperature debug file writes ==="

# Check that no source file writes minipulse_temp_debug to disk
MATCHES=$(grep -r "minipulse_temp_debug" ~/Documents/Project/MiniPulseV2/Sources --include="*.swift" 2>/dev/null || true)

if [ -n "$MATCHES" ]; then
    echo "FAIL: Found temperature debug file writes in source code:"
    echo "$MATCHES"
    echo ""
    echo "Expected: 0 matches"
    echo "Actual: $(echo "$MATCHES" | wc -l) matches"
    exit 1
else
    echo "PASS: No temperature debug file writes found"
    exit 0
fi
