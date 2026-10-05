# Powercards 🇵🇪

SaaS B2B de **tarjetas de lealtad digitales** para Apple Wallet y Google Wallet, pensado para comercios físicos de Perú: cafeterías, pollerías, cevicherías, juguerías de mercado, panaderías, barberías.

- El cliente escanea un QR en la mesa o en la caja, deja su nombre y celular y añade la tarjeta a su Wallet. No descarga ninguna app.
- El cajero escanea la tarjeta desde una PWA y toca **+1 Sello** o **Canjear premio**.
- La tarjeta se actualiza sola en el teléfono, y el comercio puede enviar mensajes a la **pantalla de bloqueo**.

## Stack (gratis y sin complicaciones)

| Capa                | Tecnología                                         | Hosting gratis                                   |
| ------------------- | -------------------------------------------------- | ------------------------------------------------ |
| Monorepo            | pnpm workspaces + Turborepo                        | —                                                |
| Base de datos       | PostgreSQL + Prisma 7                              | [Neon](https://neon.tech) o Supabase (free tier) |
| API                 | Node 22 + Hono + Zod + JWT                         | Render / Koyeb / Fly (free tier)                 |
| Dashboard + landing | Vite + React + TypeScript                          | **GitHub Pages**                                 |
| Scanner             | Vite + React PWA + lector QR por cámara            | **GitHub Pages** (`/scanner`)                    |
| Pases               | `passkit-generator` (Apple) + JWT firmado (Google) | —                                                |
| CI                  | GitHub Actions                                     | gratis en repos públicos                         |

> **Por qué la API no va en GitHub Pages:** Pages solo sirve archivos estáticos. Apple Wallet necesita un servidor HTTPS siempre disponible que reciba el registro de dispositivos y devuelva el pase actualizado. Por eso los frontends van en Pages y la API en un host Node gratuito.

## Estructura

```
powercards/
├─ apps/
│  ├─ web/                  # Dashboard del comercio + landing pública /m/{slug}   (próximo paso)
│  ├─ scanner/              # PWA del cajero                                       (próximo paso)
│  └─ api/                  # API REST + Apple PassKit Web Service                 (próximo paso)
├─ packages/
│  ├─ db/                   # Esquema Prisma, cliente, migraciones, seed  ✅
│  └─ passkit-generator/    # Firma .pkpass + JWT "Add to Google Wallet"           (próximo paso)
├─ scripts/setup.sh         # Setup local en un comando
├─ docker-compose.yml       # PostgreSQL local
└─ .github/workflows/ci.yml # Typecheck + lint + validación del esquema
```

## Inicio rápido

```bash
corepack enable          # activa pnpm
pnpm bootstrap               # .env + deps + Postgres (docker) + migraciones + datos demo
pnpm db:studio           # explora los datos
```

Sin Docker: crea una BD gratis en Neon, pega la connection string en `DATABASE_URL` dentro de `.env` y ejecuta `pnpm bootstrap`.

**Usuarios demo** (password `powercards123`):

| Comercio                     | Distrito             | Programa                           | Owner                    |
| ---------------------------- | -------------------- | ---------------------------------- | ------------------------ |
| Café Tostado                 | Miraflores, Barranco | 8 sellos = 1 café pasado gratis    | `owner@cafetostado.pe`   |
| Pollos a la Brasa Don Lucho  | Lince, Los Olivos    | 10 sellos = 1/4 de pollo gratis    | `owner@donlucho.pe`      |
| Cevichería La Chalaca Fresca | Barranco             | 6 sellos = 1 chilcano gratis       | `owner@chalacafresca.pe` |
| Juguería Mamá Rosa           | Mercado de Surquillo | 6 sellos = 1 jugo surtido          | `owner@mamarosa.pe`      |
| Panadería El Trigal          | San Isidro, Surco    | 150 puntos = panetón o tres leches | `owner@eltrigal.pe`      |

Cada comercio tiene también un `cajero@…` (rol CASHIER). El superadmin de la plataforma es `admin@powercards.pe`. Todos los comercios son ficticios.

## Modelo de datos

Ver [`packages/db/prisma/schema.prisma`](packages/db/prisma/schema.prisma).

```
Merchant ─┬─ Location (sedes)
          ├─ User (OWNER / ADMIN / CASHIER)
          ├─ LoyaltyProgram (plantilla: reglas + diseño) ── Pass ─┬─ PassRegistration ── AppleDevice
          ├─ Customer ───────────────────────────────────────────┘└─ Transaction (ledger)
          └─ PushCampaign
```

Decisiones de diseño:

- **`AppleDevice` + `PassRegistration` en vez de guardar `pushToken` en `Pass`.** Un pase puede estar instalado en varios dispositivos (iPhone y Apple Watch) y un dispositivo puede tener muchos pases. Así lo modela el protocolo PassKit Web Service.
- **`LoyaltyProgram` separado de `Merchant`.** Un comercio puede tener varias tarjetas (por ejemplo, café y almuerzos) sin migrar datos.
- **`Transaction` es un ledger inmutable.** Los saldos de `Pass` son una caché desnormalizada para que el escaneo sea rápido. Para auditar o recalcular se usa el ledger.
- **`idempotencyKey` en `Transaction`.** Si el cajero toca dos veces o la red reintenta, no se cobran dos sellos.
- **`maxStampsPerDay` por programa.** Evita que un cajero regale sellos a un amigo sin control.
- **Ley 29733 (datos personales).** `Customer.marketingConsent` y `marketingConsentAt` registran el consentimiento explícito para campañas push.
- **Multi-sede.** `Location` guarda coordenadas, que Apple Wallet usa para mostrar el pase en la pantalla de bloqueo cuando el cliente está cerca del local.

## Requisitos externos

| Plataforma    | Costo          | Qué necesitas                                                                             |
| ------------- | -------------- | ----------------------------------------------------------------------------------------- |
| Google Wallet | Gratis         | Cuenta en Google Pay & Wallet Console (Issuer ID) y una service account de GCP            |
| Apple Wallet  | **USD 99/año** | Apple Developer Program, un Pass Type ID y su certificado (sirve para firmar y para APNs) |

Sin cuenta de Apple, el sistema funciona con Google Wallet y con la tarjeta web de respaldo (`WalletPlatform.WEB`).

## Scripts

| Comando                        | Descripción                               |
| ------------------------------ | ----------------------------------------- |
| `pnpm bootstrap`               | Setup local completo                      |
| `pnpm dev`                     | Levanta todas las apps en modo desarrollo |
| `pnpm typecheck` / `pnpm lint` | Lo mismo que corre CI                     |
| `pnpm db:migrate`              | Crea y aplica una migración nueva         |
| `pnpm db:seed`                 | Carga los datos demo (idempotente)        |
| `pnpm db:studio`               | Prisma Studio                             |

## Roadmap

1. ✅ Monorepo, CI y esquema Prisma con seed de comercios peruanos
2. ⏳ `packages/passkit-generator`: firma de `.pkpass` y JWT de Google Wallet
3. ⏳ `apps/api`: auth/RBAC, `POST /api/passes/generate`, `POST /api/passes/stamp`, PassKit Web Service `/v1/devices/...`, APNs
4. ⏳ `apps/web`: editor de tarjeta con preview en vivo, landing de registro, campañas
5. ⏳ `apps/scanner`: PWA con cámara, `+1 Sello` y `Canjear premio`
6. ⏳ Deploy: GitHub Pages (frontends) y Render + Neon (API + BD)
