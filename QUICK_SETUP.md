# Quick Setup Checklist

Follow these steps in order to get your database set up:

## ✅ Step 1: Supabase Project Setup
- [ ] Create account at https://supabase.com
- [ ] Create a new project
- [ ] Wait for project to finish initializing

## ✅ Step 2: Environment Variables
- [ ] Create `.env` file in project root
- [ ] Get your project URL from: **Settings → API → Project URL**
- [ ] Get your anon key from: **Settings → API → anon/public key**
- [ ] Add to `.env`:
  ```env
  VITE_SUPABASE_URL=your_project_url_here
  VITE_SUPABASE_ANON_KEY=your_anon_key_here
  ```

## ✅ Step 3: Database Tables
- [ ] Go to **SQL Editor** in Supabase dashboard
- [ ] Copy and paste contents of `supabase/migrations/001_initial_schema.sql`
- [ ] Click **Run** (or press Ctrl+Enter)
- [ ] Verify tables are created: Go to **Table Editor** → should see `satarknity_incidents`

## ✅ Step 4: Storage Bucket
- [ ] Go to **Storage** in Supabase dashboard
- [ ] Click **New bucket**
- [ ] Name: `incidentmedia`
- [ ] **Public bucket**: ✅ Enable this
- [ ] Click **Create bucket**
- [ ] Go to **SQL Editor** again
- [ ] Copy and paste contents of `supabase/migrations/002_storage_policies.sql`
- [ ] Click **Run**

## ✅ Step 5: Authentication
- [ ] Go to **Authentication → Providers**
- [ ] Ensure **Email** provider is enabled
- [ ] For development: Go to **Authentication → Settings → Email Auth**
- [ ] Toggle **Enable email confirmations** OFF (for easier testing)

## ✅ Step 6: Test Your Setup
- [ ] Restart your dev server: `npm run dev`
- [ ] Try signing up a new account
- [ ] Check **Authentication → Users** to see your test user
- [ ] Sign in and submit a test incident
- [ ] Check **Table Editor → satarknity_incidents** to see the incident
- [ ] Check **Storage → incidentmedia** to see uploaded files

## 🎉 Done!

Your database is now set up and ready to use!

---

**Need help? Check the detailed guide:** `DATABASE_SETUP_GUIDE.md`

