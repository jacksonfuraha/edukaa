# IDUKA E-commerce Platform - Deployment Troubleshooting Guide

## Common Deployment Issues & Solutions

### 1. Build Failures

#### Issue: "Module not found" errors
**Symptoms**: Build fails with module import errors
**Causes**: Missing dependencies or incorrect import paths
**Solutions**:
```bash
# Clean install all dependencies
rm -rf node_modules package-lock.json
npm install

# Check for missing dependencies
npm ls

# Install missing packages
npm install missing-package-name
```

#### Issue: "SyntaxError" in build
**Symptoms**: JavaScript syntax errors during build
**Causes**: Incorrect syntax, missing semicolons, or ES6+ issues
**Solutions**:
```bash
# Check JavaScript syntax
npx eslint client/src/

# Fix common syntax issues
# - Check for missing semicolons
# - Verify import/export statements
# - Check for undefined variables
```

### 2. Server Startup Failures

#### Issue: "Port already in use"
**Symptoms**: Server fails to start, port conflict error
**Solutions**:
```bash
# Find process using port 5000
netstat -ano | findstr :5000

# Kill the process (Windows)
taskkill /PID <PID> /F

# Kill the process (Mac/Linux)
kill -9 <PID>

# Use different port
PORT=5001 npm start
```

#### Issue: "Cannot find module" errors
**Symptoms**: Server crashes with module import errors
**Solutions**:
```bash
# Install missing server dependencies
npm install express cors uuid dotenv

# Check package.json dependencies
cat package.json | grep -A 10 "dependencies"
```

### 3. Frontend Build Issues

#### Issue: "React is not defined"
**Symptoms**: React components fail to render
**Solutions**:
```bash
# Check React import in components
import React from 'react';

# Verify React is installed
npm ls react

# Reinstall React if needed
npm uninstall react && npm install react
```

#### Issue: CSS not loading
**Symptoms**: Styles not applied, unstyled components
**Solutions**:
```bash
# Check CSS imports
import './ComponentName.css';

# Verify CSS files exist
ls client/src/pages/*.css

# Check CSS bundling in build
grep -r "css" client/build/
```

### 4. API Connection Issues

#### Issue: "Network Error" or "CORS Error"
**Symptoms**: Frontend cannot connect to backend
**Solutions**:

**Check Backend Status**:
```bash
# Test backend directly
curl http://localhost:5000/api/products

# Check if backend is running
netstat -ano | findstr :5000
```

**Fix CORS Issues**:
```javascript
// In simple-server.js, ensure CORS is properly configured
const cors = require('cors');
app.use(cors({
  origin: ['http://localhost:3000', 'https://yourdomain.com'],
  credentials: true
}));
```

**Frontend API Configuration**:
```javascript
// Check API base URL in axios calls
const API_BASE = process.env.NODE_ENV === 'production' 
  ? 'https://yourdomain.com/api' 
  : 'http://localhost:5000/api';
```

### 5. File Storage Issues

#### Issue: "ENOENT: no such file or directory"
**Symptoms**: Server crashes when trying to read/write files
**Solutions**:
```bash
# Create data directory
mkdir -p data

# Set proper permissions
chmod 755 data

# Check file paths
ls -la data/
```

#### Issue: "JSON parsing error"
**Symptoms**: Cannot read JSON data files
**Solutions**:
```bash
# Validate JSON files
cat data/users.json | python -m json.tool

# Fix corrupted JSON files
echo '[]' > data/users.json
echo '[]' > data/products.json
echo '[]' > data/chats.json
echo '[]' > data/orders.json
echo '[]' > data/videos.json
```

### 6. Environment Variable Issues

#### Issue: "undefined" environment variables
**Symptoms**: Server fails with undefined config values
**Solutions**:
```bash
# Create .env file
cat > .env << EOF
NODE_ENV=development
PORT=5000
EOF

# Load environment variables
npm install dotenv
```

### 7. Deployment Platform Specific Issues

#### Netlify Deployment Issues

**Issue: "Function not found" errors
**Solutions**:
```bash
# Create netlify/functions directory
mkdir -p netlify/functions

# Move server to functions directory
cp simple-server.js netlify/functions/api.js

# Create netlify.toml
cat > netlify.toml << EOF
[build]
  publish = "client/build"
  command = "cd client && npm run build"

[functions]
  directory = "netlify/functions"

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/:splat"
  status = 200
EOF
```

#### Issue: Build timeout
**Solutions**:
```bash
# Optimize build process
echo "NODE_OPTIONS=--max-old-space-size=4096" >> .env

# Reduce build complexity
# - Remove unused dependencies
# - Optimize images
# - Use code splitting
```

#### Vercel Deployment Issues

**Issue: "Serverless function timeout"
**Solutions**:
```json
// In vercel.json, increase timeout
{
  "version": 2,
  "functions": {
    "simple-server.js": {
      "maxDuration": 30
    }
  }
}
```

#### Heroku Deployment Issues

**Issue: "Application Error" H10
**Solutions**:
```bash
# Check logs
heroku logs --tail

# Fix port binding
# Ensure server listens to process.env.PORT

# Add Procfile
echo "web: node simple-server.js" > Procfile

# Set buildpack
heroku buildpacks:set heroku/nodejs
```

### 8. Quick Diagnostic Checklist

#### Pre-Deployment Checklist
```bash
# 1. Test locally
npm run dev

# 2. Check dependencies
npm ls

# 3. Verify build
npm run build

# 4. Test API endpoints
curl http://localhost:5000/api/products

# 5. Check data files
ls -la data/
```

#### Common Error Patterns
- **Missing semicolons** in JavaScript files
- **Incorrect import paths** for components
- **Port conflicts** between services
- **CORS misconfiguration** between frontend and backend
- **Environment variables** not properly set
- **File permissions** on data directory
- **JSON syntax errors** in data files

### 9. Step-by-Step Debugging Process

#### Step 1: Check Local Development
```bash
# Start both frontend and backend
npm run dev

# Test in browser
# Open http://localhost:3000
# Check browser console for errors
```

#### Step 2: Test Backend API
```bash
# Test individual endpoints
curl http://localhost:5000/api/products
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}'
```

#### Step 3: Check Build Process
```bash
# Clean build
rm -rf client/build

# Rebuild
cd client && npm run build

# Check build output
ls -la client/build/
```

#### Step 4: Validate Configuration
```bash
# Check package.json scripts
cat package.json | grep -A 5 "scripts"

# Verify dependencies
npm outdated

# Check for security vulnerabilities
npm audit
```

### 10. Platform-Specific Debugging

#### Netlify Debugging
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Local testing
netlify dev

# Check function logs
netlify functions:logs
```

#### Vercel Debugging
```bash
# Local testing
vercel dev

# Check deployment logs
vercel logs

# Inspect build
vercel inspect
```

#### Heroku Debugging
```bash
# Check application status
heroku ps

# View recent logs
heroku logs --tail --num 50

# Run commands remotely
heroku run node -e "console.log('Testing')"
```

### 11. Performance Issues

#### Issue: Slow loading times
**Solutions**:
```javascript
// Implement lazy loading
const LazyComponent = React.lazy(() => import('./Component'));

// Optimize images
const optimizedImage = new Image();
optimizedImage.src = imageUrl;
optimizedImage.loading = 'lazy';

// Use React.memo
const MemoizedComponent = React.memo(Component);
```

#### Issue: Memory leaks
**Solutions**:
```javascript
// Cleanup useEffect
useEffect(() => {
  // Setup code
  
  return () => {
    // Cleanup code
    clearInterval(interval);
    cancelAnimationFrame(animationId);
  };
}, []);

// Remove event listeners
window.removeEventListener('resize', handleResize);
```

### 12. Security Issues

#### Issue: CORS errors
**Solutions**:
```javascript
// Proper CORS configuration
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://yourdomain.com'] 
    : ['http://localhost:3000'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
```

#### Issue: Authentication issues
**Solutions**:
```javascript
// Secure token storage
const storeToken = (token) => {
  if (process.env.NODE_ENV === 'production') {
    // Use secure storage in production
    localStorage.setItem('token', token);
  } else {
    localStorage.setItem('token', token);
  }
};
```

### 13. Getting Help

#### Community Resources
- **Stack Overflow**: Tag questions with `iduka`, `netlify`, `vercel`
- **GitHub Issues**: Check existing issues and create new ones
- **Discord**: Join relevant development communities
- **Documentation**: Read platform-specific docs

#### Debug Information to Collect
When asking for help, provide:
1. **Error messages** (exact text)
2. **Platform** (Netlify, Vercel, Heroku)
3. **Build logs** (full output)
4. **Browser console** errors
5. **Steps taken** so far

#### Quick Fixes to Try
```bash
# Clear all caches
npm cache clean --force
rm -rf node_modules package-lock.json
npm install

# Reset data files
echo '[]' > data/users.json
echo '[]' > data/products.json

# Try minimal deployment
# Comment out complex features
# Deploy basic version first
```

---

**Remember**: Most deployment issues are caused by simple configuration errors or missing dependencies. Start with the basics and gradually add complexity.
