# Eclipse IDE Import Instructions for IDUKA E-commerce Platform

## Overview
This document provides step-by-step instructions for importing the IDUKA e-commerce platform into Eclipse IDE for development.

## Prerequisites
- Eclipse IDE for Enterprise Java and Web Developers (2023-09 or newer)
- Node.js 16+ installed on your system
- PostgreSQL 12+ installed on your system
- Git (optional, for version control)

## Step 1: Install Required Eclipse Plugins

1. Open Eclipse IDE
2. Go to **Help** > **Eclipse Marketplace**
3. Install the following plugins:
   - **Nodeclipse** (Node.js development support)
   - **Wild Web Developer** (HTML, CSS, JavaScript support)
   - **Eclipse Git Team Provider** (if using Git)
   - **Database Development** (for PostgreSQL management)

## Step 2: Import the Project

### Method 1: Import from Existing Directory

1. Open Eclipse IDE
2. Go to **File** > **Import**
3. Select **General** > **Existing Projects into Workspace**
4. Click **Next**
5. Browse to the `idukaa` directory location
6. Select the **IDUKA-Ecommerce** project
7. Click **Finish**

### Method 2: Import from Git (if using Git)

1. Open Eclipse IDE
2. Go to **File** > **Import**
3. Select **Git** > **Projects from Git**
4. Click **Next**
5. Select **Clone URI**
6. Enter your Git repository URL
7. Follow the wizard to complete the import

## Step 3: Configure Node.js Runtime

1. Go to **Window** > **Preferences**
2. Navigate to **Node** > **Node.js**
3. Set your Node.js installation path
4. Click **Apply** and **OK**

## Step 4: Configure Database Connection

1. Go to **Window** > **Preferences**
2. Navigate to **Data Management** > **Connectivity** > **Driver Definitions**
3. Add PostgreSQL driver if not present
4. Go to **Database Development** perspective
5. Create new database connection:
   - **Database**: PostgreSQL
   - **Host**: localhost
   - **Port**: 5432
   - **Database**: iduka_db
   - **User**: postgres
   - **Password**: your_password

## Step 5: Set Up Environment Variables

1. Create a `.env` file in the project root directory
2. Copy contents from `.env.example`
3. Update the values with your local configuration

## Step 6: Install Dependencies

### Using Terminal in Eclipse

1. Right-click on the project
2. Select **Show In** > **Terminal**
3. Run the following commands:

```bash
# Install root dependencies
npm install

# Install client dependencies
cd client
npm install
cd ..

# Install server dependencies
npm install
```

### Using Nodeclipse

1. Right-click on `package.json`
2. Select **Run As** > **npm install**
3. Repeat for `client/package.json`

## Step 7: Set Up Database

1. Open PostgreSQL using your preferred tool
2. Create database: `createdb iduka_db`
3. Run database setup:
   - Right-click on `server/database/setup.js`
   - Select **Run As** > **Node Application**
   - Or use terminal: `npm run setup-db`

## Step 8: Configure Launch Configurations

### Backend Server

1. Go to **Run** > **Run Configurations**
2. Create new **Node Application** configuration
3. **Name**: IDUKA Backend
4. **Main**: `server/index.js`
5. **Arguments**: None
6. **Working Directory**: Project root
7. **Environment**: Add NODE_ENV=development

### Frontend Development

1. Create new **Node Application** configuration
2. **Name**: IDUKA Frontend
3. **Main**: `node_modules/react-scripts/bin/react-scripts.js`
4. **Arguments**: `start`
5. **Working Directory**: `client` directory
6. **Environment**: Add BROWSER=none

## Step 9: Run the Application

1. Start the backend server:
   - Select **IDUKA Backend** launch configuration
   - Click **Run** (green play button)
   
2. Start the frontend:
   - Select **IDUKA Frontend** launch configuration
   - Click **Run**

3. Access the application:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000

## Step 10: Verify Setup

1. Check Eclipse Console for any errors
2. Open browser and navigate to http://localhost:3000
3. Verify the IDUKA homepage loads correctly
4. Test user registration and login functionality

## Development Workflow in Eclipse

### File Structure Navigation
- **Project Explorer**: Navigate through the project structure
- **JavaScript files**: Open with JavaScript editor
- **CSS files**: Open with CSS editor
- **HTML files**: Open with HTML editor

### Code Editing Features
- **Syntax highlighting**: Automatic for all web technologies
- **Code completion**: For JavaScript, React, and Node.js
- **Error detection**: Real-time syntax and error checking
- **Refactoring**: Rename, extract functions, etc.

### Debugging
- **Backend debugging**: Set breakpoints in server files
- **Frontend debugging**: Use browser developer tools
- **Console output**: View in Eclipse Console view

### Database Management
- **Database Explorer**: View and manage PostgreSQL tables
- **SQL Editor**: Write and execute SQL queries
- **Data Import/Export**: Manage database content

## Troubleshooting

### Common Issues

1. **Node.js not recognized**
   - Check Node.js installation path in Eclipse preferences
   - Restart Eclipse after configuration changes

2. **Port already in use**
   - Change port in `.env` file
   - Kill existing processes using the port

3. **Database connection failed**
   - Verify PostgreSQL is running
   - Check database credentials in `.env`
   - Ensure database exists

4. **Module not found errors**
   - Run `npm install` in appropriate directories
   - Check `package.json` for missing dependencies

5. **Build errors**
   - Check Eclipse Console for specific error messages
   - Verify all dependencies are installed
   - Check for syntax errors in code

### Getting Help

1. **Eclipse Help**: F1 or Help > Help Contents
2. **Project Documentation**: Check README.md
3. **Console Messages**: Always check Eclipse Console for errors
4. **Log Files**: Check application logs in server directory

## Additional Resources

- [Eclipse IDE Documentation](https://www.eclipse.org/eclipseide/)
- [Nodeclipse Documentation](https://github.com/Nodeclipse/nodeclipse-1)
- [React Documentation](https://reactjs.org/docs)
- [Node.js Documentation](https://nodejs.org/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

## Tips for Productive Development

1. **Use keyboard shortcuts** for faster navigation
2. **Configure code formatting** preferences for consistent style
3. **Set up code templates** for common code patterns
4. **Use Git integration** for version control
5. **Regularly save and commit** changes
6. **Test frequently** during development
7. **Use the debugger** for troubleshooting issues

---

**Note**: This project is designed as a full-stack MERN (MongoDB/Express/React/Node.js) application with PostgreSQL instead of MongoDB. The Eclipse setup provides a comprehensive development environment for both frontend and backend development.
