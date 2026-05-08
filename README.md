# IDUKA Marketplace

A responsive e-commerce marketplace built with React, Tailwind CSS, and a Node.js backend using Prisma ORM for PostgreSQL.

## Features
- Buyer and seller account registration with full address capture
- Seller verification flow with ID number and TIN
- TikTok-style product video browsing feed
- Real-time-style chat interface for buyer-seller negotiation
- Responsive layout for mobile and desktop
- REST API backend for authentication, products, videos, and chats

## Getting Started
1. Install dependencies:
   ```bash
   npm install
   ```
2. Copy the backend environment example and update it with your database settings:
   ```bash
   cd backend
   copy .env.example .env
   ```
3. Set `DATABASE_URL` to your PostgreSQL connection string and configure `JWT_SECRET`.
4. Generate Prisma client and run migrations:
   ```bash
   npx prisma generate
   npx prisma migrate dev --name init
   ```
5. Start both frontend and backend from the workspace root:
   ```bash
   npm run dev
   ```

## Running projects separately
- Frontend: `cd frontend && npm run dev`
- Backend: `cd backend && npm run dev`

## Notes
- This starter uses PostgreSQL as the recommended database for hosting.
- Update `backend/.env` to point to your hosted PostgreSQL instance.
- The frontend runs on `http://localhost:5173` and backend on `http://localhost:4000`.
- Use the seller verification flow to collect ID and TIN data and reduce scam risk.
