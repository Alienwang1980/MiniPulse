#!/usr/bin/env python3
"""验证 AppTheme.swift 中所有颜色属性是否有 themeType 隔离。"""

import re
import sys

def verify_theme_isolation(filepath):
    with open(filepath) as f:
        lines = f.readlines()

    # 找所有 var Xxx: Color { ... } 的定义（可能跨多行）
    # 策略：从 "var " 开始，找到对应的 "}" 结尾
    i = 0
    results = []

    while i < len(lines):
        line = lines[i]
        # 检测 var 名字: Color { 模式
        m = re.match(r'^\s*(var\s+\w+)\s*:\s*Color\s*\{', line)
        if m:
            var_decl = m.group(1)
            var_name = var_decl.replace('var ', '')
            # 收集到这个 var 的 body
            brace_count = 0
            start_i = i
            body_lines = []
            j = i
            while j < len(lines):
                l = lines[j]
                body_lines.append(l)
                brace_count += l.count('{')
                brace_count -= l.count('}')
                if brace_count == 0 and j > i:
                    break
                j += 1
            body = ''.join(body_lines)
            # 去掉首尾的 { 和 }
            body_content = re.sub(r'^\s*\{(.*)\}\s*$', r'\1', body, flags=re.DOTALL).strip()
            has_theme_check = 'themeType' in body_content or 'isEightBit' in body_content
            results.append((var_name, body_content[:100], has_theme_check))
            i = j + 1
        else:
            i += 1

    protected = [(n, b) for n, b, h in results if h]
    unprotected = [(n, b) for n, b, h in results if not h]

    print("=== themeType 隔离检查 ===\n")
    print(f"{'属性名':<30} {'前100字符'}")
    print("-" * 110)

    print("\n✅ 有 themeType 保护：")
    for name, body in protected:
        print(f"  {name:<28} {body}")

    print(f"\n❌ 无 themeType 保护（会窜主题）：")
    for name, body in unprotected:
        print(f"  {name:<28} {body}")

    print(f"\n总计: {len(protected)} 受保护, {len(unprotected)} 未保护")
    return len(unprotected) == 0

if __name__ == '__main__':
    ok = verify_theme_isolation('/Users/mini/Documents/Project/MiniPulseV2/Sources/App/AppTheme.swift')
    sys.exit(0 if ok else 1)
