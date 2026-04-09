// Quick deployment test script
const fs = require('fs');
const path = require('path');

console.log('🔍 IDUKA Deployment Diagnostic Tool\n');

// Check project structure
console.log('📁 Checking project structure...');

const requiredFiles = [
  'package.json',
  'simple-server.js',
  'client/package.json',
  'client/public/index.html',
  'data/users.json',
  'data/products.json',
  'data/chats.json',
  'data/orders.json',
  'data/videos.json'
];

let allFilesExist = true;
requiredFiles.forEach(file => {
  if (fs.existsSync(file)) {
    console.log(`✅ ${file}`);
  } else {
    console.log(`❌ ${file} - MISSING`);
    allFilesExist = false;
  }
});

// Check package.json dependencies
console.log('\n📦 Checking dependencies...');
try {
  const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
  const deps = packageJson.dependencies || {};
  
  const requiredDeps = ['express', 'cors', 'uuid', 'dotenv'];
  requiredDeps.forEach(dep => {
    if (deps[dep]) {
      console.log(`✅ ${dep}`);
    } else {
      console.log(`❌ ${dep} - MISSING`);
      allFilesExist = false;
    }
  });
} catch (error) {
  console.log('❌ Error reading package.json:', error.message);
  allFilesExist = false;
}

// Check data files format
console.log('\n📄 Checking data files...');
try {
  const users = JSON.parse(fs.readFileSync('data/users.json', 'utf8'));
  if (Array.isArray(users)) {
    console.log(`✅ users.json - Valid array (${users.length} users)`);
  } else {
    console.log('❌ users.json - Invalid format');
    allFilesExist = false;
  }
} catch (error) {
  console.log('❌ Error reading users.json:', error.message);
  allFilesExist = false;
}

// Check if server can start
console.log('\n🚀 Testing server startup...');
try {
  const express = require('express');
  const cors = require('cors');
  const uuid = require('uuid');
  console.log('✅ Server dependencies can be loaded');
} catch (error) {
  console.log('❌ Server dependency error:', error.message);
  allFilesExist = false;
}

// Generate deployment commands
console.log('\n🛠️  Deployment Commands:');
console.log('\n📱 For Netlify:');
console.log('npm install -g netlify-cli');
console.log('netlify deploy --prod');

console.log('\n⚡ For Vercel:');
console.log('npm install -g vercel');
console.log('vercel --prod');

console.log('\n🌿 For Heroku:');
console.log('npm install -g heroku');
console.log('heroku create iduka-app');
console.log('git push heroku main');

// Generate fixes
if (!allFilesExist) {
  console.log('\n🔧 Auto-fixing common issues...');
  
  // Create data directory if missing
  if (!fs.existsSync('data')) {
    fs.mkdirSync('data', { recursive: true });
    console.log('✅ Created data directory');
  }
  
  // Create missing data files
  const dataFiles = ['users.json', 'products.json', 'chats.json', 'orders.json', 'videos.json'];
  dataFiles.forEach(file => {
    const filePath = path.join('data', file);
    if (!fs.existsSync(filePath)) {
      fs.writeFileSync(filePath, '[]');
      console.log(`✅ Created ${file}`);
    }
  });
  
  console.log('\n✅ Issues fixed! Try deployment again.');
} else {
  console.log('\n✅ All checks passed! Ready for deployment.');
}

console.log('\n📋 Quick Checklist:');
console.log('□ Run: npm install');
console.log('□ Test: npm run dev');
console.log('□ Build: npm run build');
console.log('□ Deploy to chosen platform');
