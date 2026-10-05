#!/usr/bin/env bash
# Setup rápido de entorno local: deps + BD + migraciones + datos demo
set -euo pipefail
cd "$(dirname "$0")/.."

command -v pnpm >/dev/null || { echo "→ Activando pnpm con corepack"; corepack enable; }

[ -f .env ] || { cp .env.example .env; echo "→ .env creado desde .env.example"; }

echo "→ Instalando dependencias"
pnpm install

if command -v docker >/dev/null && grep -q "localhost:5432" .env; then
  echo "→ Levantando PostgreSQL (docker compose)"
  docker compose up -d db
  until docker compose exec -T db pg_isready -U powercards >/dev/null 2>&1; do sleep 1; done
fi

echo "→ Prisma: generate + migrate + seed"
pnpm db:generate
pnpm --filter @powercards/db exec prisma migrate deploy
pnpm db:seed

echo "✔ Listo. Usuario demo: owner@cafetostado.pe / powercards123"
