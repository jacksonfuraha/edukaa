# IDUKA Website Deployment Guide

## Overview
This folder contains everything you need to deploy the IDUKA e-commerce website to any hosting environment.

## Folder Structure
```
IDUKA_DEPLOYMENT/
|
|-- WEB-INF/              # Web application configuration
|-- css/                   # Stylesheets
|-- js/                    # JavaScript files
|-- jsp/                   # JSP pages (HTML templates)
|-- images/                # Static images
|-- uploads/               # User upload directory (create if needed)
|-- database/              # Database scripts
|-- database.properties    # Database configuration template
|-- README.md              # This file
|-- DEPLOYMENT_GUIDE.md    # Deployment instructions
```

## Quick Start (Tomcat Hosting)

### 1. Prerequisites
- Java 17 or higher
- Apache Tomcat 9.0 or higher
- PostgreSQL 12 or higher

### 2. Database Setup
```sql
CREATE DATABASE iduka_db;
```
Then run:
```bash
psql -d iduka_db -f database/iduka_schema.sql
```

### 3. Configure Database
Edit `database.properties`:
```properties
db.url=jdbc:postgresql://localhost:5432/iduka_db
db.username=your_username
db.password=your_password
```

### 4. Deploy to Tomcat
1. Copy entire `IDUKA_DEPLOYMENT` folder to Tomcat's `webapps` directory
2. Rename it to `IDUKA`
3. Start Tomcat
4. Access: `http://localhost:8080/IDUKA`

## Cloud Hosting (AWS, DigitalOcean, etc.)

### 1. Server Setup
```bash
# Install Java 17
sudo apt update
sudo apt install openjdk-17-jdk

# Install Tomcat 9
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz
tar -xzf apache-tomcat-9.0.85.tar.gz
sudo mv apache-tomcat-9.0.85 /opt/tomcat

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib
sudo -u postgres createdb iduka_db
```

### 2. Deploy Application
```bash
# Copy files to server
scp -r IDUKA_DEPLOYMENT/* user@server:/opt/tomcat/webapps/IDUKA/

# Set permissions
sudo chown -R tomcat:tomcat /opt/tomcat/webapps/IDUKA
sudo chmod +x /opt/tomcat/bin/*.sh

# Start Tomcat
sudo /opt/tomcat/bin/startup.sh
```

### 3. Configure Domain
1. Point your domain to server IP
2. Set up reverse proxy (Nginx/Apache)
3. Configure SSL certificate

## Docker Deployment

### 1. Create Dockerfile
```dockerfile
FROM tomcat:9.0-jdk17-openjdk

COPY . /usr/local/tomcat/webapps/ROOT/

EXPOSE 8080

CMD ["catalina.sh", "run"]
```

### 2. Build and Run
```bash
docker build -t iduka .
docker run -p 8080:8080 iduka
```

## Shared Hosting (cPanel, Plesk)

### 1. Requirements Check
- Java support available
- Tomcat support available
- PostgreSQL database available

### 2. Upload Files
1. Upload all files to public_html
2. Configure database through cPanel
3. Set up deployment through hosting panel

## Configuration Details

### Database Configuration
Edit `database.properties`:
- Update database URL, username, password
- Set connection pool settings
- Configure file upload paths

### Web Configuration
Edit `WEB-INF/web.xml` if needed:
- Session timeout
- Error pages
- Security constraints

### File Upload Directory
Create `uploads` directory with write permissions:
```bash
mkdir uploads
chmod 755 uploads
```

## Testing Your Deployment

### 1. Basic Functionality
- Home page loads: `http://your-domain.com/IDUKA`
- Registration works (buyer and seller)
- Login functionality
- Product browsing

### 2. Advanced Features
- Video feed functionality
- Chat system
- Payment processing
- File uploads

### 3. Mobile Testing
- Test on mobile devices
- Check responsive design
- Verify touch interactions

## Security Considerations

### 1. Database Security
- Use strong database password
- Limit database user permissions
- Enable SSL for database connections

### 2. Application Security
- Change default admin password
- Enable HTTPS (SSL certificate)
- Configure firewall rules
- Regular security updates

### 3. File Security
- Protect upload directory
- Limit file types and sizes
- Regular malware scans

## Performance Optimization

### 1. Database Optimization
- Add indexes to frequently queried columns
- Optimize database queries
- Enable connection pooling

### 2. Application Optimization
- Enable gzip compression
- Use CDN for static assets
- Implement caching strategies

### 3. Server Optimization
- Configure JVM memory settings
- Enable HTTP/2 if available
- Use load balancing for high traffic

## Monitoring and Maintenance

### 1. Application Monitoring
- Set up error logging
- Monitor server resources
- Track user activity

### 2. Database Maintenance
- Regular backups
- Database optimization
- Log rotation

### 3. Updates and Patches
- Keep Java updated
- Update Tomcat regularly
- Apply security patches

## Troubleshooting

### Common Issues
1. **Database Connection Failed**
   - Check database credentials
   - Verify database is running
   - Test connection manually

2. **File Upload Not Working**
   - Check directory permissions
   - Verify file size limits
   - Check disk space

3. **Pages Not Loading**
   - Check Tomcat logs
   - Verify deployment structure
   - Test with simple HTML page

4. **Performance Issues**
   - Check server resources
   - Optimize database queries
   - Enable caching

### Getting Help
- Check application logs
- Review server logs
- Test database connectivity
- Verify file permissions

## Backup Strategy

### 1. Database Backup
```bash
# Daily backup
pg_dump iduka_db > backup_$(date +%Y%m%d).sql
```

### 2. Application Backup
```bash
# Weekly backup
tar -czf iduka_backup_$(date +%Y%m%d).tar.gz IDUKA/
```

### 3. Configuration Backup
- Save database.properties
- Backup server configurations
- Document custom changes

## Contact Support

For technical support:
- Email: support@iduka.rw
- Website: www.iduka.rw
- Phone: +250 support hotline

## Final Checklist

Before going live:
- [ ] Database configured and tested
- [ ] All features working correctly
- [ ] Security measures in place
- [ ] SSL certificate installed
- [ ] Backup strategy implemented
- [ ] Monitoring configured
- [ ] Performance optimized
- [ ] Mobile responsive tested

Your IDUKA e-commerce platform is now ready for deployment!
