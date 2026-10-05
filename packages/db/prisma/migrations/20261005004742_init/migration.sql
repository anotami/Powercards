-- CreateEnum
CREATE TYPE "BusinessType" AS ENUM ('CAFETERIA', 'RESTAURANTE', 'POLLERIA', 'CEVICHERIA', 'JUGUERIA', 'PANADERIA', 'BODEGA', 'BARBERIA', 'SPA', 'TIENDA', 'OTRO');

-- CreateEnum
CREATE TYPE "Plan" AS ENUM ('FREE', 'PRO', 'BUSINESS');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('SUPERADMIN', 'OWNER', 'ADMIN', 'CASHIER');

-- CreateEnum
CREATE TYPE "ProgramType" AS ENUM ('STAMPS', 'POINTS');

-- CreateEnum
CREATE TYPE "PassStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'REVOKED');

-- CreateEnum
CREATE TYPE "WalletPlatform" AS ENUM ('APPLE', 'GOOGLE', 'WEB');

-- CreateEnum
CREATE TYPE "TransactionType" AS ENUM ('ENROLL', 'STAMP', 'POINTS_EARN', 'REDEEM', 'ADJUST');

-- CreateEnum
CREATE TYPE "CampaignStatus" AS ENUM ('DRAFT', 'SCHEDULED', 'SENDING', 'SENT', 'FAILED', 'CANCELLED');

-- CreateTable
CREATE TABLE "Merchant" (
    "id" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "legalName" TEXT,
    "ruc" VARCHAR(11),
    "businessType" "BusinessType" NOT NULL DEFAULT 'OTRO',
    "plan" "Plan" NOT NULL DEFAULT 'FREE',
    "logoUrl" TEXT,
    "iconUrl" TEXT,
    "primaryColor" TEXT NOT NULL DEFAULT '#0F172A',
    "backgroundColor" TEXT NOT NULL DEFAULT '#0F172A',
    "foregroundColor" TEXT NOT NULL DEFAULT '#FFFFFF',
    "labelColor" TEXT NOT NULL DEFAULT '#CBD5E1',
    "phone" TEXT,
    "email" TEXT,
    "instagram" TEXT,
    "website" TEXT,
    "timezone" TEXT NOT NULL DEFAULT 'America/Lima',
    "currency" VARCHAR(3) NOT NULL DEFAULT 'PEN',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Merchant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Location" (
    "id" TEXT NOT NULL,
    "merchantId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT,
    "district" TEXT,
    "city" TEXT NOT NULL DEFAULT 'Lima',
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Location_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "merchantId" TEXT,
    "locationId" TEXT,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "role" "UserRole" NOT NULL DEFAULT 'CASHIER',
    "active" BOOLEAN NOT NULL DEFAULT true,
    "lastLoginAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LoyaltyProgram" (
    "id" TEXT NOT NULL,
    "merchantId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "type" "ProgramType" NOT NULL DEFAULT 'STAMPS',
    "stampsRequired" INTEGER NOT NULL DEFAULT 10,
    "pointsPerSol" INTEGER NOT NULL DEFAULT 1,
    "pointsForReward" INTEGER NOT NULL DEFAULT 100,
    "rewardTitle" TEXT NOT NULL,
    "rewardDescription" TEXT,
    "welcomeStamps" INTEGER NOT NULL DEFAULT 0,
    "maxStampsPerDay" INTEGER NOT NULL DEFAULT 3,
    "logoUrl" TEXT,
    "stripImageUrl" TEXT,
    "backgroundColor" TEXT,
    "foregroundColor" TEXT,
    "labelColor" TEXT,
    "terms" TEXT,
    "passTypeIdentifier" TEXT NOT NULL,
    "googleClassId" TEXT,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "LoyaltyProgram_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Customer" (
    "id" TEXT NOT NULL,
    "merchantId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "email" TEXT,
    "birthday" DATE,
    "marketingConsent" BOOLEAN NOT NULL DEFAULT false,
    "marketingConsentAt" TIMESTAMP(3),
    "source" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Customer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Pass" (
    "id" TEXT NOT NULL,
    "programId" TEXT NOT NULL,
    "customerId" TEXT NOT NULL,
    "serialNumber" TEXT NOT NULL,
    "passTypeIdentifier" TEXT NOT NULL,
    "authenticationToken" TEXT NOT NULL,
    "googleObjectId" TEXT,
    "platform" "WalletPlatform" NOT NULL DEFAULT 'WEB',
    "status" "PassStatus" NOT NULL DEFAULT 'ACTIVE',
    "stampsBalance" INTEGER NOT NULL DEFAULT 0,
    "pointsBalance" INTEGER NOT NULL DEFAULT 0,
    "rewardsAvailable" INTEGER NOT NULL DEFAULT 0,
    "lifetimeStamps" INTEGER NOT NULL DEFAULT 0,
    "rewardsRedeemed" INTEGER NOT NULL DEFAULT 0,
    "lastMessage" TEXT,
    "lastVisitAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Pass_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AppleDevice" (
    "id" TEXT NOT NULL,
    "deviceLibraryIdentifier" TEXT NOT NULL,
    "pushToken" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AppleDevice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PassRegistration" (
    "id" TEXT NOT NULL,
    "deviceId" TEXT NOT NULL,
    "passId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PassRegistration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Transaction" (
    "id" TEXT NOT NULL,
    "merchantId" TEXT NOT NULL,
    "passId" TEXT NOT NULL,
    "locationId" TEXT,
    "userId" TEXT,
    "type" "TransactionType" NOT NULL,
    "stampsDelta" INTEGER NOT NULL DEFAULT 0,
    "pointsDelta" INTEGER NOT NULL DEFAULT 0,
    "rewardsDelta" INTEGER NOT NULL DEFAULT 0,
    "stampsAfter" INTEGER NOT NULL,
    "pointsAfter" INTEGER NOT NULL DEFAULT 0,
    "amountCents" INTEGER,
    "note" TEXT,
    "idempotencyKey" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PushCampaign" (
    "id" TEXT NOT NULL,
    "merchantId" TEXT NOT NULL,
    "programId" TEXT,
    "createdById" TEXT,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "segment" JSONB,
    "status" "CampaignStatus" NOT NULL DEFAULT 'DRAFT',
    "scheduledAt" TIMESTAMP(3),
    "sentAt" TIMESTAMP(3),
    "recipientsCount" INTEGER NOT NULL DEFAULT 0,
    "appleSent" INTEGER NOT NULL DEFAULT 0,
    "googleSent" INTEGER NOT NULL DEFAULT 0,
    "failedCount" INTEGER NOT NULL DEFAULT 0,
    "error" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PushCampaign_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Merchant_slug_key" ON "Merchant"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "Merchant_ruc_key" ON "Merchant"("ruc");

-- CreateIndex
CREATE INDEX "Location_merchantId_idx" ON "Location"("merchantId");

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "User_merchantId_idx" ON "User"("merchantId");

-- CreateIndex
CREATE UNIQUE INDEX "LoyaltyProgram_googleClassId_key" ON "LoyaltyProgram"("googleClassId");

-- CreateIndex
CREATE INDEX "LoyaltyProgram_merchantId_idx" ON "LoyaltyProgram"("merchantId");

-- CreateIndex
CREATE INDEX "Customer_merchantId_createdAt_idx" ON "Customer"("merchantId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Customer_merchantId_phone_key" ON "Customer"("merchantId", "phone");

-- CreateIndex
CREATE UNIQUE INDEX "Pass_serialNumber_key" ON "Pass"("serialNumber");

-- CreateIndex
CREATE UNIQUE INDEX "Pass_googleObjectId_key" ON "Pass"("googleObjectId");

-- CreateIndex
CREATE INDEX "Pass_passTypeIdentifier_updatedAt_idx" ON "Pass"("passTypeIdentifier", "updatedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Pass_programId_customerId_key" ON "Pass"("programId", "customerId");

-- CreateIndex
CREATE UNIQUE INDEX "AppleDevice_deviceLibraryIdentifier_key" ON "AppleDevice"("deviceLibraryIdentifier");

-- CreateIndex
CREATE INDEX "PassRegistration_passId_idx" ON "PassRegistration"("passId");

-- CreateIndex
CREATE UNIQUE INDEX "PassRegistration_deviceId_passId_key" ON "PassRegistration"("deviceId", "passId");

-- CreateIndex
CREATE UNIQUE INDEX "Transaction_idempotencyKey_key" ON "Transaction"("idempotencyKey");

-- CreateIndex
CREATE INDEX "Transaction_merchantId_createdAt_idx" ON "Transaction"("merchantId", "createdAt");

-- CreateIndex
CREATE INDEX "Transaction_passId_createdAt_idx" ON "Transaction"("passId", "createdAt");

-- CreateIndex
CREATE INDEX "PushCampaign_merchantId_createdAt_idx" ON "PushCampaign"("merchantId", "createdAt");

-- CreateIndex
CREATE INDEX "PushCampaign_status_scheduledAt_idx" ON "PushCampaign"("status", "scheduledAt");

-- AddForeignKey
ALTER TABLE "Location" ADD CONSTRAINT "Location_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LoyaltyProgram" ADD CONSTRAINT "LoyaltyProgram_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Customer" ADD CONSTRAINT "Customer_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Pass" ADD CONSTRAINT "Pass_programId_fkey" FOREIGN KEY ("programId") REFERENCES "LoyaltyProgram"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Pass" ADD CONSTRAINT "Pass_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "Customer"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PassRegistration" ADD CONSTRAINT "PassRegistration_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "AppleDevice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PassRegistration" ADD CONSTRAINT "PassRegistration_passId_fkey" FOREIGN KEY ("passId") REFERENCES "Pass"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_passId_fkey" FOREIGN KEY ("passId") REFERENCES "Pass"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PushCampaign" ADD CONSTRAINT "PushCampaign_merchantId_fkey" FOREIGN KEY ("merchantId") REFERENCES "Merchant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PushCampaign" ADD CONSTRAINT "PushCampaign_programId_fkey" FOREIGN KEY ("programId") REFERENCES "LoyaltyProgram"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PushCampaign" ADD CONSTRAINT "PushCampaign_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
