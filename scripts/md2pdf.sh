#!/usr/bin/env bash
# Convert Markdown reports to PDF: pandoc (md -> standalone html) + headless Google Chrome (html -> pdf).
# Usage: bash scripts/md2pdf.sh docs/report.md docs/ai-critique.md docs/ai-audit-report.md [-o outdir]
set -eu
cd "$(dirname "$0")/.."
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
out="docs"; files=()
while [ $# -gt 0 ]; do case "$1" in -o) out="$2"; shift 2;; *) files+=("$1"); shift;; esac; done
mkdir -p "$out"
css=$(mktemp -t md2pdf).css
cat > "$css" <<'CSS'
body{font:12px/1.5 -apple-system,Helvetica,Arial,sans-serif;max-width:none;margin:0;padding:0 8px}
table{border-collapse:collapse;width:100%;font-size:10px}th,td{border:1px solid #bbb;padding:3px 5px;vertical-align:top;word-break:break-word}
th{background:#eee}code{font-size:10px}pre{white-space:pre-wrap}img{max-width:100%}
CSS
for f in "${files[@]}"; do
  base=$(basename "$f" .md); html="$(mktemp -t md2pdf).html"
  pandoc "$f" -f gfm -s --metadata pagetitle="$base" -c "$css" --self-contained -o "$html" 2>/dev/null || pandoc "$f" -f gfm -s --metadata pagetitle="$base" -c "$css" --embed-resources -o "$html"
  "$CHROME" --headless=new --disable-gpu --no-pdf-header-footer --print-to-pdf="$out/$base.pdf" "file://$html" >/dev/null 2>&1
  echo "Wrote $out/$base.pdf"
done
