#!/usr/bin/env bash
# Start (or restart) the EShop backend on :3000. The backend reseeds the DB on every start,
# which also resets login lockout and clears orders/carts: use this between test runs.
# Usage: bash scripts/start-sut.sh   (set SUT_DIR to override the SUT location)
set -eu
SUT_DIR="${SUT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)/eshop-sut-fithcmus}"
pkill -f "node server.js" 2>/dev/null || true
sleep 1
cd "$SUT_DIR/backend"
[ -d node_modules ] || npm install
nohup node server.js > /tmp/eshop-backend.log 2>&1 &
sleep 2
curl -fsS -o /dev/null -w "backend HTTP %{http_code}\n" http://localhost:3000/api/categories
