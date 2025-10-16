# scripts/bom_diff.py
import sys, json, argparse, math

p = argparse.ArgumentParser(description="Vergelijk huidige BOM JSONL (stdin) met golden JSONL (bestand).")
p.add_argument("golden", help="Pad naar golden .jsonl")
p.add_argument("--epsilon", type=float, default=0.0005, help="Tolerantie voor floats")
args = p.parse_args()

def load_jsonl_from_handle(h):
    out = []
    for raw in h:
        line = raw.lstrip("\ufeff").strip()  # BOM & whitespace tolerant
        if not line:
            continue
        out.append(json.loads(line))
    return out

def eq(a, b, eps):
    if a is b:
        return True
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return math.isclose(float(a), float(b), rel_tol=0.0, abs_tol=eps)
    if isinstance(a, (str, bool)) or a is None:
        return a == b
    if isinstance(a, list) and isinstance(b, list):
        return len(a) == len(b) and all(eq(x, y, eps) for x, y in zip(a, b))
    if isinstance(a, dict) and isinstance(b, dict):
        return a.keys() == b.keys() and all(eq(a[k], b[k], eps) for k in a.keys())
    return a == b

# golden uit bestand (BOM tolerant)
with open(args.golden, encoding="utf-8-sig") as f:
    golden = load_jsonl_from_handle(f)

# current via stdin (BOM tolerant)
stdin_text = sys.stdin.read()
if stdin_text.startswith("\ufeff"):
    stdin_text = stdin_text.lstrip("\ufeff")
current = [json.loads(l) for l in stdin_text.splitlines() if l.strip()]

ok = True
if len(golden) != len(current):
    print(f"Count mismatch: golden {len(golden)} != current {len(current)}")
    ok = False

for i, (g, c) in enumerate(zip(golden, current)):
    if not eq(g, c, args.epsilon):
        print(f"Mismatch at record {i} (epsilon={args.epsilon})")
        print("GOLDEN:", json.dumps(g, ensure_ascii=False))
        print("CURRNT:", json.dumps(c, ensure_ascii=False))
        ok = False

sys.exit(0 if ok else 1)
