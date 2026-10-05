# ✅ Checklist del dueño — lo que tienes que hacer tú

Lo que **no puede hacer el código**: cuentas, pagos, credenciales, validación legal y comercial.
Orden recomendado. Marca `[x]` a medida que avances (puedes editar este archivo desde GitHub).

> Leyenda: 🟢 gratis · 💲 pago · ⏱ tiempo estimado · 🚧 bloquea el siguiente paso de desarrollo

---

## 0. Decisiones (antes de seguir) 🚧

- [ ] **¿Apple Wallet desde el día 1?** 💲 USD 99/año. Sin Apple, la mayoría de tu público (en Perú ~80% de smartphones son Android) queda cubierta con Google Wallet; los iPhone usan la tarjeta web.
  - Recomendación: lanzar piloto **solo con Google + web**, pagar Apple cuando tengas el primer comercio pagando.
- [ ] **¿Repo público o privado?** GitHub Pages en repo **privado** requiere GitHub Pro (USD 4/mes). Si es público, todo es gratis — los secretos nunca van en el código, así que público es seguro.
- [ ] **Nombre/marca definitiva** (hoy "Powercards") y dominio (opcional, ver §5).

## 1. Cuentas gratuitas (hoy) 🟢 ⏱ ~1 h

### 1.1 Base de datos — Neon 🚧

- [ ] Crear cuenta en <https://neon.tech> (login con GitHub).
- [ ] Nuevo proyecto `powercards`, región **AWS São Paulo (sa-east-1)** — la más cercana a Lima.
- [ ] Copiar la **connection string** (botón _Connect_) → guardarla para `DATABASE_URL`.

### 1.2 Hosting API — Render 🚧

- [ ] Crear cuenta en <https://render.com> con GitHub y autorizar el repo `anotami/Powercards`.
- [ ] (Nada más por ahora — el servicio se crea cuando exista `apps/api`.)
- ⚠️ Plan free se duerme tras 15 min sin tráfico (primer request ~30 s). Para producción real: plan Starter USD 7/mes.

### 1.3 GitHub Pages 🚧

- [ ] Repo → **Settings → Pages → Source: "GitHub Actions"**.
- [ ] Repo → **Settings → Actions → General → Workflow permissions: "Read and write"**.

## 2. Google Wallet 🟢 ⏱ ~1 h + espera de aprobación 🚧

- [ ] Entrar a <https://pay.google.com/business/console> → aceptar términos → **Google Wallet API** → copiar el **Issuer ID**.
- [ ] En <https://console.cloud.google.com>: crear proyecto `powercards` → **APIs & Services → Enable "Google Wallet API"**.
- [ ] **IAM → Service Accounts → Create** (`wallet-issuer`) → _Keys → Add key → JSON_ → descargar.
- [ ] Guardar el JSON como `certs/google-service-account.json` (la carpeta `certs/` está en `.gitignore`).
- [ ] Volver a Pay & Wallet Console → **Users → Invite** el email de la service account (rol _Developer_).
- [ ] Agregar tu Gmail personal como **test user** (mientras estés en modo demo, solo los test users pueden guardar pases).
- [ ] Cuando el piloto funcione: **Request publishing access** (Google revisa en días; pide logo y capturas).

## 3. Apple Wallet 💲 USD 99/año ⏱ 1–14 días (opcional según §0)

- [ ] Inscribirte en <https://developer.apple.com/programs/enroll/>.
  - Como **persona natural**: rápido (1–2 días).
  - Como **empresa** (recomendado, aparece tu razón social): requiere **número D-U-N-S** (gratis, tarda 1–2 semanas).
- [ ] Anotar tu **Team ID** (Membership details).
- [ ] _Certificates, IDs & Profiles → Identifiers → +_ → **Pass Type IDs** → `pass.pe.powercards.loyalty`.
- [ ] Generar el certificado del Pass Type ID. Sin Mac, con OpenSSL:
  ```bash
  mkdir -p certs && cd certs
  openssl req -new -newkey rsa:2048 -nodes -keyout signerKey.pem -out request.csr \
    -subj "/emailAddress=tu@email.com/CN=Powercards/C=PE"
  # Subir request.csr a Apple → descargar pass.cer
  openssl x509 -inform der -in pass.cer -out signerCert.pem
  # Certificado intermedio de Apple (WWDR G4):
  curl -sO https://www.apple.com/certificateauthority/AppleWWDRCAG4.cer
  openssl x509 -inform der -in AppleWWDRCAG4.cer -out wwdr.pem
  ```
- [ ] El mismo certificado sirve para **APNs** (push que actualiza el pase). No requiere configuración extra.
- [ ] ⚠️ El certificado vence al año: poner recordatorio en el calendario.

## 4. Secretos y variables 🚧 (cuando exista `apps/api`)

| Dónde                                                               | Qué                                                                                                  |
| ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `.env` local                                                        | Copia de `.env.example` con tus valores                                                              |
| **Render → Environment**                                            | `DATABASE_URL`, `JWT_SECRET`, `PUBLIC_API_URL`, `CORS_ORIGINS`, `GOOGLE_WALLET_ISSUER_ID`, `APPLE_*` |
| **Render → Secret Files**                                           | `google-service-account.json`, `signerCert.pem`, `signerKey.pem`, `wwdr.pem`                         |
| **GitHub → Settings → Secrets and variables → Actions → Variables** | `VITE_API_URL` = URL pública de Render                                                               |

- [ ] Generar `JWT_SECRET`: `openssl rand -base64 48`
- [ ] **Nunca** subir certificados ni el JSON de Google al repo. Si pasa: revocar y regenerar.

## 5. Legal y negocio en Perú ⏱ variable (validar con abogado/contador)

- [ ] **Ley 29733 – Protección de Datos Personales**: los comercios recopilan nombre, celular, email.
  - Política de privacidad y términos visibles en el formulario de registro (el sistema ya guarda el consentimiento).
  - Tú eres **encargado del tratamiento**; cada comercio es el titular del banco de datos → contrato/cláusula de tratamiento de datos con cada comercio.
  - Inscripción del banco de datos ante la **ANPD** (MINJUSDH): normalmente la hace el comercio; confirmar.
- [ ] **Facturación**: RUC activo y facturación electrónica SUNAT para cobrar la suscripción (ej. Nubefact, gratis/bajo costo al inicio).
- [ ] **Cobro recurrente**: Culqi, Mercado Pago o Izipay (aceptan Yape/Plin/tarjetas). Decidir cuando haya piloto.
- [ ] **Dominio** (opcional): `.pe` en punto.pe (~USD 40/año) o `.com`. Mientras tanto: `anotami.github.io/Powercards`.

## 6. Validación comercial — lo más importante ⏱ 2–4 semanas

El riesgo principal no es técnico: es que el comercio no lo use en caja. Valida antes de invertir en features.

- [ ] Lista de **5 comercios piloto** (cafetería, pollería, juguería de mercado, barbería, panadería) con acceso al dueño.
- [ ] Ofrecer **piloto gratis 60 días** a cambio de feedback y testimonio.
- [ ] Definir precio tentativo (referencia: S/ 49–99/mes por local).
- [ ] KPIs del piloto (el dashboard los mostrará):
  - % de clientes que se registran desde el QR (meta > 15% de tickets)
  - Sellos por semana por local
  - Tasa de canje (premios canjeados / premios ganados)
  - Frecuencia de retorno a 30 días: registrados vs. no registrados
- [ ] Material para el local: QR impreso en mesa/caja + cartel "Pide tu tarjeta digital, sin descargar apps".

## 7. Pruebas que necesitan tu teléfono

Claude no puede probar en un teléfono físico. Después de cada entrega:

- [ ] Android: guardar el pase en Google Wallet, recibir un sello, ver que se actualiza.
- [ ] iPhone (si hay Apple): agregar `.pkpass`, recibir sello, ver notificación en pantalla de bloqueo.
- [ ] Scanner: abrir la PWA en el celular del cajero → "Agregar a pantalla de inicio" → escanear.

---

## Lo que construye Claude (para que sepas qué esperar)

| #   | Entrega                                                      | Qué necesitas tener listo                     |
| --- | ------------------------------------------------------------ | --------------------------------------------- |
| 1   | ✅ Monorepo, BD, seed, CI                                    | —                                             |
| 2   | `packages/passkit-generator`                                 | Nada (funciona con certificados de prueba)    |
| 3   | `apps/api` (auth, generar pase, sellar, PassKit web service) | §1.1 Neon, §1.2 Render                        |
| 4   | `apps/web` (dashboard + landing de registro)                 | §1.3 Pages                                    |
| 5   | `apps/scanner` (PWA del cajero)                              | §1.3 Pages                                    |
| 6   | Deploy end-to-end                                            | §2 Google (y §3 Apple si aplica), §4 secretos |
| 7   | Piloto                                                       | §5 y §6                                       |

**Tu ruta crítica esta semana:** §0 decisiones → §1 cuentas → §2 Google Wallet (la aprobación tarda; empézala ya).
