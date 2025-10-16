# /scripts/render_bom.py
import sys, re, json, csv, argparse
from pathlib import Path

p = argparse.ArgumentParser(description="Parse OpenSCAD BOM echo's to JSONL/CSV")
p.add_argument("--product", required=True, help="Productnaam (bijv. filterslang)")
p.add_argument("--version", required=True, help="Productversie (bijv. 1.0.0)")
p.add_argument("--csv", default="", help="Pad om CSV te schrijven (optioneel)")
p.add_argument("--jsonl", default="", help="Pad om JSONL te schrijven (optioneel)")
p.add_argument("--echo", default="", help="Lees een OpenSCAD .echo-bestand i.p.v. stdin")
p.add_argument("--allow-empty", action="store_true",
               help="Sta toe dat er geen BOM-records zijn (exit 0 i.p.v. 1)")
p.add_argument("--debug", action="store_true",
               help="Print de eerste 400 tekens input naar stderr")
args = p.parse_args()

# --- Input lezen (echo-bestand of stdin)
if args.echo:
    text = Path(args.echo).read_text(encoding="utf-8", errors="ignore")
else:
    text = sys.stdin.read()

if args.debug:
    sys.stderr.write("DEBUG first 400 chars:\n" + text[:400] + "\n")

items = []

def parse_line(line: str):
    """Pak één BOM-regel uit een willekeurige ECHO-stijl."""
    if "BOM_ITEM" not in line:
        return None
    # Deel na 'BOM_ITEM'
    try:
        _pre, post = line.split("BOM_ITEM", 1)
    except ValueError:
        return None

    # Vind JSON-achtige array [ ... ] met key/value's
    lb = post.find("[")
    rb = post.rfind("]")
    if lb == -1 or rb == -1 or rb <= lb:
        return None
    kv_raw = post[lb:rb+1].strip()

    # Optionele tag vóór de '[': ..."TAG", [
    pre_tag = post[:lb]
    m = re.search(r'"([^"]+)"\s*,\s*$', pre_tag.strip())
    tag = m.group(1) if m else None

    try:
        kv = json.loads(kv_raw)
    except Exception:
        return None

    d = {"product": args.product, "version": args.version}
    if tag:
        d["bom_tag"] = tag
    it = iter(kv)
    for k in it:
        d[str(k)] = next(it, None)
    return d

# --- 1) Lijn-voor-lijn proberen (de meest robuuste aanpak)
for line in text.splitlines():
    rec = parse_line(line)
    if rec:
        items.append(rec)

# --- 2) Als niets gevonden: probeer nog twee regex-vormen op de hele tekst
if not items:
    # A) Console-stijl: ECHO: "BOM_ITEM:", "TAG", [ ... ]
    for m in re.finditer(r'"BOM_ITEM:",\s*(?:"([^"]+)"\s*,\s*)?(\[.*?\])', text, re.S):
        bom_tag = m.group(1)
        kv_raw  = m.group(2)
        try:
            kv = json.loads(kv_raw)
        except Exception:
            continue
        d = {"product": args.product, "version": args.version}
        if bom_tag: d["bom_tag"] = bom_tag
        it = iter(kv)
        for k in it: d[str(k)] = next(it, None)
        items.append(d)

if not items:
    # B) Ongequote variant: BOM_ITEM: "TAG", [ ... ]
    for m in re.finditer(r'BOM_ITEM:\s*(?:"([^"]+)"\s*,\s*)?(\[.*?\])', text, re.S):
        bom_tag = m.group(1)
        kv_raw  = m.group(2)
        try:
            kv = json.loads(kv_raw)
        except Exception:
            continue
        d = {"product": args.product, "version": args.version}
        if bom_tag: d["bom_tag"] = bom_tag
        it = iter(kv)
        for k in it: d[str(k)] = next(it, None)
        items.append(d)

# --- Altijd JSONL naar stdout (handig voor debugging/pipes)
for d in items:
    sys.stdout.write(json.dumps(d, ensure_ascii=False) + "\n")

# --- Geen items?
if not items and not args.allow_empty:
    sys.stderr.write("No BOM_ITEM records found in input.\n")
    sys.exit(1)

# --- Optioneel JSONL-bestand
if args.jsonl:
    outj = Path(args.jsonl)
    outj.parent.mkdir(parents=True, exist_ok=True)
    outj.write_text("".join(json.dumps(d, ensure_ascii=False) + "\n" for d in items), encoding="utf-8")

# --- Optioneel CSV-bestand
if args.csv:
    out_path = Path(args.csv)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    keys = set()
    for d in items:
        keys.update(d.keys())
    preferred = [
        "product","version","bom_tag","L","D","t","medium","top","open_top",
        "bottom","bottom_opt","rings","ring_w","ring_t",
        "reinforce","rein_side","rein_spans","productzijde"
    ]
    
    header = [k for k in preferred if k in keys] + [k for k in sorted(keys) if k not in preferred]
    with out_path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=header)
        w.writeheader()
        for d in items:
            dd = {k: (json.dumps(v, ensure_ascii=False) if isinstance(v, (list, dict)) else v)
                  for k, v in d.items()}
            w.writerow(dd)
