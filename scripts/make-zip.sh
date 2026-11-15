#!/usr/bin/env bash
# Build the submission zip: 23120264_HW05_AI_Performance_<grade>.zip (grade = self-assessed total, 3 digits, e.g. 090)
# Usage: bash scripts/make-zip.sh 090
set -eu
cd "$(dirname "$0")/.."
grade="${1:?usage: make-zip.sh <self-grade, e.g. 090>}"
name="23120264_HW05_AI_Performance_${grade}.zip"
bash scripts/gen-commit-log.sh
bash scripts/md2pdf.sh docs/report.md docs/ai-critique.md docs/ai-audit-report.md
rm -f "../$name"
zip -r -q "../$name" . -x '.git/*' '.env' '*.DS_Store' '*.zip'
echo "Wrote ../$name ($(du -h "../$name" | cut -f1))"
