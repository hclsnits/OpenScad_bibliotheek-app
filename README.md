## BOM rooktests & golden-vergelijking

Deze repository rendert OpenSCAD → `.echo`, extraheert de BOM naar JSONL en vergelijkt met golden snapshots.

### Lokale vereisten
- OpenSCAD
- Python 3.x
- (Windows) PowerShell 7 aangeraden (maar PS 5.1 werkt ook)

### Snel starten (Windows/PowerShell)

**Default**
```powershell
openscad.com -o .\out\smoke_default.echo "tests\smoke_filterslang_default.scad"
python ".\scripts\render_bom.py" --product filterslang --version 1.0.0 `
  --echo ".\out\smoke_default.echo" --jsonl ".\out\bom_default.jsonl" `
| python ".\scripts\bom_diff.py" ".\tests\golden\bom_default.jsonl" --epsilon 0.0005
