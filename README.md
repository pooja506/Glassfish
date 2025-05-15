GlassFish Application Setup Script

This repository contains an automated setup script (`testing.sh`) designed to streamline the deployment and configuration process for a Java web application running on GlassFish with MySQL.

---

🚀 What the Script Does

The `testing.sh` script performs the following tasks:

✅ 1. **Java Check & Install**
- Verifies if Java 8 is installed.
- If not, prompts to install it.
- If multiple versions exist, switches to Java 8.

✅ 2. **MySQL Check & Install**
- Checks if MySQL 5.7.42 is installed.
- If not, offers to install the exact version.

✅ 3. **Database Setup**
- Checks for presence of `mfin_db.sql`.
- Verifies if the target database (`mfin_synergy`) exists.
- Offers to create or restore it as needed.

✅ 4. **WAR File Check**
- Validates the existence of `synergy.war`.

✅ 5. **GlassFish Domain & Deployment**
- Checks if GlassFish is installed.
- Detects whether the domain is running.
- Offers to:
  - Edit `Xmx` memory value in `domain.xml`.
  - Start/stop the domain as needed.
  - Deploy or redeploy the WAR file.

6. **Log Monitoring**
- After deployment, tails the server log for real-time monitoring.

 🛠 Prerequisites

Before running the script, ensure:

- You have `bash`, `mysql`, and `sudo` privileges.
- All required files (`mfin_db.sql`, `synergy.war`, GlassFish folder) are placed in the correct structure.

🧾 Usage

```bash
chmod +x testing.sh
./testing.sh
