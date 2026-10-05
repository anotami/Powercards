/**
 * Seed de demo con comercios peruanos ficticios.
 * Ejecutar: pnpm db:seed   (idempotente: usa upsert por slug / email / teléfono)
 *
 * Credenciales demo (todas): password "powercards123"
 *   owner@cafetostado.pe    cajero@cafetostado.pe
 *   owner@donlucho.pe       cajero@donlucho.pe
 *   ...
 */
import path from "node:path";
import { randomBytes } from "node:crypto";
import { config } from "dotenv";

config({ path: path.resolve(import.meta.dirname, "../../../.env"), quiet: true });

const { prisma } = await import("../src/client.js");
const { hashPassword } = await import("../src/password.js");
const { BusinessType, ProgramType, TransactionType, UserRole, WalletPlatform } =
  await import("../src/generated/prisma/client.js");

const PASS_TYPE_ID = process.env.APPLE_PASS_TYPE_ID || "pass.pe.powercards.loyalty";

type SeedMerchant = {
  slug: string;
  name: string;
  legalName: string;
  ruc: string;
  businessType: (typeof BusinessType)[keyof typeof BusinessType];
  colors: { bg: string; fg: string; label: string };
  instagram: string;
  locations: { name: string; address: string; district: string; lat: number; lng: number }[];
  program: {
    name: string;
    type: (typeof ProgramType)[keyof typeof ProgramType];
    stampsRequired?: number;
    pointsForReward?: number;
    rewardTitle: string;
    rewardDescription: string;
    welcomeStamps?: number;
    terms: string;
  };
};

const merchants: SeedMerchant[] = [
  {
    slug: "cafe-tostado",
    name: "Café Tostado",
    legalName: "Tostado Coffee Roasters S.A.C.",
    ruc: "20601234561",
    businessType: BusinessType.CAFETERIA,
    colors: { bg: "#3B2416", fg: "#FFF8F0", label: "#E8C39E" },
    instagram: "@cafetostado.pe",
    locations: [
      {
        name: "Miraflores",
        address: "Calle Berlín 245",
        district: "Miraflores",
        lat: -12.1211,
        lng: -77.0297,
      },
      {
        name: "Barranco",
        address: "Av. Grau 310",
        district: "Barranco",
        lat: -12.1494,
        lng: -77.0213,
      },
    ],
    program: {
      name: "Tarjeta Cafetera",
      type: ProgramType.STAMPS,
      stampsRequired: 8,
      rewardTitle: "1 café pasado gratis",
      rewardDescription: "Café de Villa Rica o Chanchamayo, tamaño regular.",
      welcomeStamps: 1,
      terms:
        "Un sello por compra de bebida. No acumulable con otras promociones. Válido en Miraflores y Barranco.",
    },
  },
  {
    slug: "don-lucho",
    name: "Pollos a la Brasa Don Lucho",
    legalName: "Inversiones Don Lucho E.I.R.L.",
    ruc: "20512345672",
    businessType: BusinessType.POLLERIA,
    colors: { bg: "#B91C1C", fg: "#FFFFFF", label: "#FDE68A" },
    instagram: "@donlucho.brasa",
    locations: [
      {
        name: "Lince",
        address: "Av. Arequipa 2150",
        district: "Lince",
        lat: -12.0849,
        lng: -77.0352,
      },
      {
        name: "Los Olivos",
        address: "Av. Antúnez de Mayolo 880",
        district: "Los Olivos",
        lat: -11.9925,
        lng: -77.0702,
      },
    ],
    program: {
      name: "Club Brasero",
      type: ProgramType.STAMPS,
      stampsRequired: 10,
      rewardTitle: "1/4 de pollo a la brasa gratis",
      rewardDescription: "Con papas fritas y ensalada. Incluye cremas de la casa.",
      terms:
        "Un sello por consumo mínimo de S/ 25. Válido en salón y para llevar. No aplica delivery por apps.",
    },
  },
  {
    slug: "la-chalaca-fresca",
    name: "Cevichería La Chalaca Fresca",
    legalName: "Mar de Grau Gastronomía S.A.C.",
    ruc: "20609876543",
    businessType: BusinessType.CEVICHERIA,
    colors: { bg: "#0E7490", fg: "#FFFFFF", label: "#A5F3FC" },
    instagram: "@lachalacafresca",
    locations: [
      {
        name: "Barranco",
        address: "Jr. Domeyer 128",
        district: "Barranco",
        lat: -12.1445,
        lng: -77.0201,
      },
    ],
    program: {
      name: "Pasaporte Marino",
      type: ProgramType.STAMPS,
      stampsRequired: 6,
      rewardTitle: "1 chilcano de pisco gratis",
      rewardDescription: "Clásico o de maracuyá. Solo mayores de 18 años.",
      terms: "Un sello por plato de fondo. Atención solo almuerzo (12:00–17:00).",
    },
  },
  {
    slug: "jugueria-mama-rosa",
    name: "Juguería Mamá Rosa",
    legalName: "Rosa Quispe Huamán",
    ruc: "10456789012",
    businessType: BusinessType.JUGUERIA,
    colors: { bg: "#EA580C", fg: "#FFFFFF", label: "#FED7AA" },
    instagram: "@mamarosa.jugos",
    locations: [
      {
        name: "Mercado de Surquillo",
        address: "Puesto 112, Mercado N° 1",
        district: "Surquillo",
        lat: -12.1131,
        lng: -77.0254,
      },
    ],
    program: {
      name: "Tarjeta Juguera",
      type: ProgramType.STAMPS,
      stampsRequired: 6,
      rewardTitle: "1 jugo surtido gratis",
      rewardDescription: "Jugo surtido de vaso grande, con su yapa.",
      welcomeStamps: 1,
      terms: "Un sello por jugo. Válido de lunes a sábado.",
    },
  },
  {
    slug: "panaderia-el-trigal",
    name: "Panadería El Trigal",
    legalName: "Panificadora El Trigal S.A.C.",
    ruc: "20556677889",
    businessType: BusinessType.PANADERIA,
    colors: { bg: "#78350F", fg: "#FEF3C7", label: "#FCD34D" },
    instagram: "@eltrigal.pan",
    locations: [
      {
        name: "San Isidro",
        address: "Av. Conquistadores 455",
        district: "San Isidro",
        lat: -12.1003,
        lng: -77.0366,
      },
      {
        name: "Surco",
        address: "Av. Primavera 1320",
        district: "Santiago de Surco",
        lat: -12.1112,
        lng: -76.9897,
      },
    ],
    program: {
      name: "Puntos Trigal",
      type: ProgramType.POINTS,
      pointsForReward: 150,
      rewardTitle: "1 panetón chico o 1 torta tres leches",
      rewardDescription: "Canjea 150 puntos (S/ 1 = 1 punto).",
      terms: "1 punto por cada S/ 1 de consumo. Los puntos vencen a los 12 meses.",
    },
  },
];

const demoCustomers = [
  { name: "María Fernanda Torres", phone: "+51987654321", email: "mafe.torres@example.pe" },
  { name: "José Carlos Mendoza", phone: "+51912345678", email: "jcmendoza@example.pe" },
  { name: "Lucía Paredes Rojas", phone: "+51955443322", email: null },
  { name: "Renzo Gutiérrez", phone: "+51999888777", email: "renzo.g@example.pe" },
  { name: "Ana Lucía Chávez", phone: "+51944332211", email: null },
];

const token = () => randomBytes(24).toString("hex");

async function main() {
  const passwordHash = await hashPassword("powercards123");

  await prisma.user.upsert({
    where: { email: "admin@powercards.pe" },
    update: {},
    create: {
      email: "admin@powercards.pe",
      name: "Admin Plataforma",
      role: UserRole.SUPERADMIN,
      passwordHash,
    },
  });

  for (const m of merchants) {
    const domain = `${m.slug.split("-").slice(-2).join("")}.pe`;
    const merchant = await prisma.merchant.upsert({
      where: { slug: m.slug },
      update: {},
      create: {
        slug: m.slug,
        name: m.name,
        legalName: m.legalName,
        ruc: m.ruc,
        businessType: m.businessType,
        primaryColor: m.colors.bg,
        backgroundColor: m.colors.bg,
        foregroundColor: m.colors.fg,
        labelColor: m.colors.label,
        instagram: m.instagram,
        email: `hola@${domain}`,
        locations: {
          create: m.locations.map((l) => ({
            name: l.name,
            address: l.address,
            district: l.district,
            latitude: l.lat,
            longitude: l.lng,
          })),
        },
      },
      include: { locations: true },
    });

    const mainLocation = merchant.locations[0];

    await prisma.user.upsert({
      where: { email: `owner@${domain}` },
      update: {},
      create: {
        email: `owner@${domain}`,
        name: `Dueño ${m.name}`,
        role: UserRole.OWNER,
        merchantId: merchant.id,
        passwordHash,
      },
    });
    const cashier = await prisma.user.upsert({
      where: { email: `cajero@${domain}` },
      update: {},
      create: {
        email: `cajero@${domain}`,
        name: "Cajero Turno Mañana",
        role: UserRole.CASHIER,
        merchantId: merchant.id,
        locationId: mainLocation?.id,
        passwordHash,
      },
    });

    const existingProgram = await prisma.loyaltyProgram.findFirst({
      where: { merchantId: merchant.id },
    });
    const program =
      existingProgram ??
      (await prisma.loyaltyProgram.create({
        data: {
          merchantId: merchant.id,
          name: m.program.name,
          type: m.program.type,
          stampsRequired: m.program.stampsRequired ?? 10,
          pointsForReward: m.program.pointsForReward ?? 100,
          rewardTitle: m.program.rewardTitle,
          rewardDescription: m.program.rewardDescription,
          welcomeStamps: m.program.welcomeStamps ?? 0,
          terms: m.program.terms,
          passTypeIdentifier: PASS_TYPE_ID,
        },
      }));

    // Clientes demo con saldos variados (incluye uno con premio listo)
    for (const [i, c] of demoCustomers.entries()) {
      const customer = await prisma.customer.upsert({
        where: { merchantId_phone: { merchantId: merchant.id, phone: c.phone } },
        update: {},
        create: {
          merchantId: merchant.id,
          name: c.name,
          phone: c.phone,
          email: c.email,
          marketingConsent: i % 2 === 0,
          marketingConsentAt: i % 2 === 0 ? new Date() : null,
          source: i === 0 ? "instagram" : "qr-caja",
        },
      });

      const exists = await prisma.pass.findUnique({
        where: { programId_customerId: { programId: program.id, customerId: customer.id } },
      });
      if (exists) continue;

      const isPoints = program.type === ProgramType.POINTS;
      const stamps = isPoints ? 0 : Math.min(i * 2 + 1, program.stampsRequired);
      const points = isPoints ? ([40, 95, 150, 12, 70][i] ?? 0) : 0;
      const rewardReady = isPoints
        ? points >= program.pointsForReward
        : stamps >= program.stampsRequired;

      await prisma.pass.create({
        data: {
          programId: program.id,
          customerId: customer.id,
          serialNumber: `PC-${m.slug.slice(0, 4).toUpperCase()}-${randomBytes(5).toString("hex").toUpperCase()}`,
          passTypeIdentifier: program.passTypeIdentifier,
          authenticationToken: token(),
          platform: i % 2 === 0 ? WalletPlatform.APPLE : WalletPlatform.GOOGLE,
          stampsBalance: rewardReady && !isPoints ? 0 : stamps,
          pointsBalance: points,
          rewardsAvailable: rewardReady ? 1 : 0,
          lifetimeStamps: stamps,
          lastVisitAt: new Date(Date.now() - i * 3 * 86_400_000),
          transactions: {
            create: [
              {
                merchantId: merchant.id,
                type: TransactionType.ENROLL,
                stampsAfter: 0,
              },
              {
                merchantId: merchant.id,
                locationId: mainLocation?.id,
                userId: cashier.id,
                type: isPoints ? TransactionType.POINTS_EARN : TransactionType.STAMP,
                stampsDelta: stamps,
                pointsDelta: points,
                rewardsDelta: rewardReady ? 1 : 0,
                stampsAfter: rewardReady && !isPoints ? 0 : stamps,
                pointsAfter: points,
                amountCents: isPoints ? points * 100 : null,
                note: "Saldo inicial (seed)",
              },
            ],
          },
        },
      });
    }

    console.log(`✔ ${m.name} — ${program.name}: ${program.rewardTitle}`);
  }
}

try {
  await main();
} finally {
  await prisma.$disconnect();
}
