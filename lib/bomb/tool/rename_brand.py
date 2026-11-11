"""Sostituisce il nome "Plezy" con il nome del fork nei testi visibili (valori di lib/i18n/*.i18n.json).

Si esegue in CI prima di `dart run slang`. Le chiavi (es. "addPlezyProfile") non si toccano.
Uso: python3 lib/bomb/tool/rename_brand.py <NuovoNome>
"""
import glob
import os
import re
import sys

new = sys.argv[1]
line = re.compile(r'^(\s*"(?:[^"\\]|\\.)*"\s*:\s*)(".*")(,?\s*)$')
total = 0
for path in sorted(glob.glob("lib/i18n/*.i18n.json")):
    with open(path, encoding="utf-8", newline="") as f:
        lines = f.read().split("\n")
    count = 0
    for i, text in enumerate(lines):
        tail = "\r" if text.endswith("\r") else ""
        m = line.match(text.rstrip("\r"))
        if m and "Plezy" in m.group(2):
            count += m.group(2).count("Plezy")
            lines[i] = m.group(1) + m.group(2).replace("Plezy", new) + m.group(3) + tail
    if os.path.basename(path) == "en.i18n.json" and count == 0:
        sys.exit("::error::nessuna occorrenza di Plezy in en.i18n.json: upstream ha cambiato i testi?")
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write("\n".join(lines))
    total += count
print(f"{total} occorrenze sostituite")
