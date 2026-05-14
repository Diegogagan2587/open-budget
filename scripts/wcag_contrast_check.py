#!/usr/bin/env python3
import re
import math

CSS_FILE = 'app/assets/tailwind/shadcn.css'

def parse_tokens(path):
    tokens = {}
    with open(path, 'r') as f:
        text = f.read()
    # Prefer tokens declared in the :root block (light theme)
    root_match = re.search(r":root\s*\{([\s\S]*?)\}\s*", text, re.I)
    scope_text = root_match.group(1) if root_match else text
    for m in re.finditer(r"--([a-z0-9-]+)\s*:\s*([^;]+);", scope_text, re.I):
        name = m.group(1)
        val = m.group(2).strip()
        # only set once (first declaration in root wins)
        if name not in tokens:
            tokens[name] = val
    return tokens

def parse_hsl_value(val):
    # Accept formats like: 40 18% 88%  OR 223 72% 46% OR 0 0% 100%
    parts = val.split()
    if len(parts) >= 3 and '%' in parts[1] and '%' in parts[2]:
        h = float(parts[0])
        s = float(parts[1].rstrip('%'))/100.0
        l = float(parts[2].rstrip('%'))/100.0
        return (h, s, l)
    return None

import colorsys

def hsl_to_rgb(h,s,l):
    # colorsys.hls_to_rgb expects H, L, S in 0..1
    h_f = (h % 360) / 360.0
    r,g,b = colorsys.hls_to_rgb(h_f, l, s)
    return (r,g,b)

def srgb_to_linear(c):
    if c <= 0.04045:
        return c/12.92
    return ((c+0.055)/1.055) ** 2.4

def relative_luminance(rgb):
    r,g,b = rgb
    R = srgb_to_linear(r)
    G = srgb_to_linear(g)
    B = srgb_to_linear(b)
    return 0.2126*R + 0.7152*G + 0.0722*B

def contrast_ratio(l1,l2):
    L1 = max(l1,l2)
    L2 = min(l1,l2)
    return (L1+0.05)/(L2+0.05)

pairs = [
    ('background','foreground'),
    ('card','card-foreground'),
    ('sidebar-background','sidebar-foreground'),
    ('sidebar-primary','sidebar-primary-foreground'),
    ('primary','primary-foreground'),
    ('accent','accent-foreground'),
    ('border','foreground'),
    ('input','foreground')
]

def main():
    tokens = parse_tokens(CSS_FILE)
    results = []
    for a,b in pairs:
        va = tokens.get(a)
        vb = tokens.get(b)
        if not va or not vb:
            results.append((a,b,None,'missing token'))
            continue
        a_hsl = parse_hsl_value(va)
        b_hsl = parse_hsl_value(vb)
        if a_hsl and b_hsl:
            ra = hsl_to_rgb(*a_hsl)
            rb = hsl_to_rgb(*b_hsl)
            la = relative_luminance(ra)
            lb = relative_luminance(rb)
            ratio = contrast_ratio(la,lb)
            results.append((a,b,round(ratio,2), 'pass' if ratio>=4.5 else 'fail'))
        else:
            # fallback: try parse hex or simple numbers
            results.append((a,b,None,'unsupported format'))

    print('\nWCAG Contrast Check Report')
    print('Checked pairs and results (target >= 4.5 for normal text):\n')
    for r in results:
        a,b,ratio,status = r
        print(f"- {a} vs {b}: {ratio if ratio is not None else '-'} -> {status}")

    # Print tokens used for debugging
    print('\nTokens read:')
    keys = sorted(tokens.keys())
    for k in keys:
        print(f"{k}: {tokens[k]}")

if __name__ == '__main__':
    main()
