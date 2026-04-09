# IDUKA Website - Complete Deployment Package

## What's Included
This folder contains everything you need to host the IDUKA e-commerce website:

### 1. **Application Files**
- `IDUKA.war` - Ready-to-deploy web application
- `src/` - Complete source code
- `database/` - Database schema and scripts

### 2. **Configuration Files**
- `database.properties` - Database connection template
- `server.xml` - Tomcat configuration (if needed)
- `web.xml` - Web application configuration

### 3. **Documentation**
- `DEPLOYMENT_GUIDE.md` - Step-by-step hosting instructions
- `REQUIREMENTS.txt` - Server requirements
- `CONFIGURATION.md` - Configuration details

### 4. **Assets**
- `uploads/` - Empty folder for user uploads
- `static/` - Static resources (images, CSS, JS)

## Quick Deployment

### Option 1: Tomcat Hosting
1. Copy `IDUKA.war` to your Tomcat `webapps` folder
2. Configure database connection
3. Start Tomcat
4. Access: `http://your-domain.com/IDUKA`

### Option 2: Cloud Hosting
1. Upload to your cloud server
2. Install Java 17+ and Tomcat 9+
3. Deploy the WAR file
4. Configure database

### Option 3: Docker Deployment
1. Use provided `Dockerfile`
2. Build and run container
3. Configure environment variables

## Database Setup
1. Create PostgreSQL database: `iduka_db`
2. Run: `database/iduka_schema.sql`
3. Update `database.properties` with your credentials

## Configuration Required
- Database connection settings
- File upload paths
- Domain and SSL settings
- Email configuration (for notifications)

## Support
See `DEPLOYMENT_GUIDE.md` for detailed instructions
Contact: support@iduka.rw
