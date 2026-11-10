# KidDo backend

The backend is an Express API backed by PostgreSQL through Prisma. The Flutter
app continues to use the existing HTTP API.

## Local setup

1. Copy `.env.example` to `.env` and keep `.env` local. Set `DATABASE_URL` and
   `JWT_SECRET` for your machine.
2. Start PostgreSQL from this directory with `docker compose up -d postgres`.
3. Install dependencies with `npm install`.
4. For a new database, apply checked-in migrations with `npm run db:deploy`.
5. Seed baseline content with `npm run seed`, game data with
   `npm run seed:games`, and optional social/demo data with
   `npm run seed:features`.
6. Start the API with `npm run dev`.

The API health endpoint is `http://localhost:3000/api/health`.

## Schema changes

For local development, update `prisma/schema.prisma` and run
`npm run db:migrate -- --name describe_the_change`. This creates a checked-in
migration and updates the local database. Use `npm run db:deploy` to apply
already-created migrations in staging or production. Do not use `prisma db push`
for shared or deployed databases because it does not create migration history.

This repository previously used `prisma db push` for local setup. If your
PostgreSQL database already has these tables and data, do not run the initial
migration against it as-is: it would try to create the existing tables again.
First verify that its schema matches `20261110000000_init/migration.sql`, then
baseline that migration with `npx prisma migrate resolve --applied
20261110000000_init`. After confirming the existing records have valid user and
game references, apply the follow-up constraints with `npm run db:deploy`.
Back up data before baselining or applying schema changes.

## MongoDB data

The application runtime no longer reads MongoDB. Existing MongoDB records are
not copied automatically by the PostgreSQL schema migrations; export/import
must be performed separately if those records need to be retained.
