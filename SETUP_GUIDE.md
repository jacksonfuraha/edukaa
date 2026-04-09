# IDUKA - Setup Guide

## STEP 1: Database Setup

**If this is a fresh install (no existing data):**
1. Open MySQL Workbench
2. Run: `database/iduka_schema.sql`

**If you already have the database with data:**
1. Open MySQL Workbench  
2. Run: `database/migrate_existing_db.sql`

---

## STEP 2: Configure Database Password
Open: `src/main/java/com/iduka/util/DBConnection.java`
Change line 4: `private static final String PASSWORD = "your_password_here";`
→ Replace with your MySQL root password.

---

## STEP 3: Import into Eclipse
1. Delete old IDUKA project from Eclipse (right-click → Delete, check "Delete project contents")
2. File → Import → Maven → Existing Maven Projects → Browse to IDUKA folder → Finish
3. Right-click project → Maven → Update Project

---

## STEP 4: Deploy to Tomcat
1. Right-click project → Run As → Run on Server
2. Select Tomcat 10.1 → Finish
3. Visit: `http://localhost:8080/IDUKA`

---

## STEP 5: Configure Email (for payslip feature)
Open: `src/main/java/com/iduka/util/EmailService.java`
```java
private static final String FROM_EMAIL = "your@gmail.com";
private static final String FROM_PASS  = "xxxx xxxx xxxx xxxx"; // Gmail App Password
```
Get Gmail App Password: myaccount.google.com → Security → 2-Step Verification → App Passwords

---

## How Payment Works
1. Buyer selects MTN MoMo / Airtel Money / Cash on Delivery when ordering
2. Seller sees order in dashboard with payment method shown
3. Seller clicks **"Confirm ✅"** on the order
4. System automatically:
   - Generates payment reference (e.g. `IDK-1741032981234`)
   - Marks order as PAID
   - Emails HTML payslip to buyer's email
   - Shows "✉️ Payslip sent" in dashboard

---

## Image & Video Upload
Files save to: `C:\Users\YourName\iduka_uploads\`
- Product images → `iduka_uploads\products\`  
- Videos → `iduka_uploads\videos\`
- Avatars → `iduka_uploads\avatars\`

This folder is served at `/IDUKA/uploads/` via `META-INF/context.xml` (Tomcat resource alias).
