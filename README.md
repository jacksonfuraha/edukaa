# IDUKA - Rwanda's Online Marketplace Platform

IDUKA is a comprehensive e-commerce platform designed to connect local merchants and customers across Rwanda through digital commerce. The platform enables sellers to open virtual shops at low cost while providing customers with a convenient way to browse, order, and pay online using mobile money services.

## Features

### Core Features
- **User Authentication**: Secure registration and login with buyer/seller roles
- **Comprehensive Address System**: Full Rwandan address hierarchy (Country, Province, District, Sector, Cell, Village)
- **Product Management**: Sellers can list, manage, and showcase products with images and videos
- **TikTok-Style Video Feed**: Engaging video advertisements with scrollable feed
- **Real-Time Chat**: Integrated messaging system for buyer-seller negotiations
- **Mobile Money Integration**: MTN MoMo and Airtel Money payment support
- **Advanced Search & Filters**: Find products by category, price, condition, and more
- **Rating & Review System**: Customer feedback and product ratings
- **Order Management**: Complete order tracking and management system
- **Responsive Design**: Mobile-first approach for optimal user experience

### Technical Features
- **React Frontend**: Modern, component-based UI with hooks and context
- **Node.js Backend**: RESTful API with Express.js
- **PostgreSQL Database**: Robust relational database with optimized queries
- **Socket.io Integration**: Real-time chat functionality
- **JWT Authentication**: Secure token-based authentication
- **File Upload Support**: Image and video uploads for products
- **API Rate Limiting**: Protection against abuse
- **Input Validation**: Comprehensive data validation and sanitization

## Technology Stack

### Frontend
- React 18.2.0
- React Router 6.15.0
- React Query 3.39.3
- Styled Components 6.0.7
- Framer Motion 10.16.4
- React Icons 4.11.0
- Socket.io Client 4.7.2
- Axios 1.5.0

### Backend
- Node.js
- Express.js 4.18.2
- Socket.io 4.7.2
- PostgreSQL 8.11.3
- JWT 9.0.2
- Bcryptjs 2.4.3
- Multer 1.4.5-lts.1
- Express Validator 7.0.1
- Helmet 7.0.0
- CORS 2.8.5

## Project Structure

```
idukaa/
|-- client/                 # React frontend
|   |-- public/
|   |-- src/
|   |   |-- components/     # Reusable UI components
|   |   |-- contexts/       # React contexts (Auth, Chat)
|   |   |-- pages/          # Page components
|   |   |-- App.js          # Main App component
|   |   |-- index.js        # Entry point
|   |   |-- index.css       # Global styles
|   |   |-- App.css         # App-specific styles
|   |-- package.json
|-- server/                 # Node.js backend
|   |-- database/
|   |   |-- connection.js   # Database connection
|   |   |-- setup.js        # Database setup script
|   |-- middleware/         # Express middleware
|   |-- routes/             # API routes
|   |-- socket/             # Socket.io handlers
|   |-- index.js            # Server entry point
|   |-- uploads/            # File upload directory
|-- .env.example            # Environment variables template
|-- package.json            # Root package.json
|-- README.md               # This file
```

## Installation & Setup

### Prerequisites
- Node.js (v16 or higher)
- PostgreSQL (v12 or higher)
- npm or yarn

### 1. Clone the Repository
```bash
git clone <repository-url>
cd idukaa
```

### 2. Install Dependencies
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

### 3. Database Setup
```bash
# Create PostgreSQL database
createdb iduka_db

# Set up database tables and indexes
npm run setup-db
```

### 4. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit .env file with your configuration
nano .env
```

### 5. Start the Application

#### Development Mode
```bash
# Start both frontend and backend concurrently
npm run dev

# Or start individually:
npm run server  # Backend only
npm run client  # Frontend only
```

#### Production Mode
```bash
# Build frontend
npm run build

# Start production server
npm start
```

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=iduka_db
DB_USER=postgres
DB_PASSWORD=your_password

# JWT Configuration
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRE=7d

# Server Configuration
PORT=5000
NODE_ENV=development

# File Upload Configuration
UPLOAD_PATH=./uploads
MAX_FILE_SIZE=10485760

# Mobile Money Configuration
MTN_MOMO_API_KEY=your_mtn_momo_api_key
MTN_MOMO_SECRET=your_mtn_momo_secret
AIRTEL_MONEY_API_KEY=your_airtel_money_api_key
AIRTEL_MONEY_SECRET=your_airtel_money_secret

# Email Configuration (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_email_password
```

## API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/verify` - Token verification

### Product Endpoints
- `GET /api/products` - Get all products with filters
- `GET /api/products/:id` - Get single product
- `POST /api/products` - Create product (seller only)
- `PUT /api/products/:id` - Update product (seller only)
- `DELETE /api/products/:id` - Delete product (seller only)

### Chat Endpoints
- `GET /api/chat` - Get user's chats
- `GET /api/chat/:id` - Get chat with messages
- `POST /api/chat` - Create new chat
- `POST /api/chat/:id/messages` - Send message

### Video Endpoints
- `GET /api/videos/feed` - Get TikTok-style video feed
- `POST /api/videos/upload` - Upload product video
- `GET /api/videos/product/:productId` - Get product videos

### Payment Endpoints
- `POST /api/payments/order` - Create order
- `POST /api/payments/momo/initiate` - Initiate MTN MoMo payment
- `POST /api/payments/airtel/initiate` - Initiate Airtel Money payment
- `GET /api/payments/status/:reference` - Check payment status

## Database Schema

### Users Table
- `id` (UUID, Primary Key)
- `username` (VARCHAR, Unique)
- `email` (VARCHAR, Unique)
- `password_hash` (VARCHAR)
- `full_name` (VARCHAR)
- `phone` (VARCHAR)
- `user_type` (ENUM: 'buyer', 'seller')
- `profile_image` (TEXT)
- `is_verified` (BOOLEAN)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### Products Table
- `id` (UUID, Primary Key)
- `seller_id` (UUID, Foreign Key)
- `title` (VARCHAR)
- `description` (TEXT)
- `price` (DECIMAL)
- `category` (VARCHAR)
- `condition` (ENUM: 'new', 'used', 'refurbished')
- `stock_quantity` (INTEGER)
- `images` (TEXT[])
- `video_url` (TEXT)
- `is_active` (BOOLEAN)
- `views` (INTEGER)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### Addresses Table
- `id` (UUID, Primary Key)
- `user_id` (UUID, Foreign Key)
- `country` (VARCHAR)
- `province` (VARCHAR)
- `district` (VARCHAR)
- `sector` (VARCHAR)
- `cell` (VARCHAR)
- `village` (VARCHAR)
- `street_address` (TEXT)
- `is_default` (BOOLEAN)
- `created_at` (TIMESTAMP)

### Chats Table
- `id` (UUID, Primary Key)
- `buyer_id` (UUID, Foreign Key)
- `seller_id` (UUID, Foreign Key)
- `product_id` (UUID, Foreign Key)
- `last_message` (TEXT)
- `last_message_time` (TIMESTAMP)
- `is_active` (BOOLEAN)
- `created_at` (TIMESTAMP)

### Chat Messages Table
- `id` (UUID, Primary Key)
- `chat_id` (UUID, Foreign Key)
- `sender_id` (UUID, Foreign Key)
- `message` (TEXT)
- `message_type` (ENUM: 'text', 'image', 'file')
- `file_url` (TEXT)
- `is_read` (BOOLEAN)
- `created_at` (TIMESTAMP)

### Product Videos Table
- `id` (UUID, Primary Key)
- `product_id` (UUID, Foreign Key)
- `video_url` (TEXT)
- `thumbnail` (TEXT)
- `duration` (INTEGER)
- `caption` (TEXT)
- `is_active` (BOOLEAN)
- `created_at` (TIMESTAMP)

### Orders Table
- `id` (UUID, Primary Key)
- `buyer_id` (UUID, Foreign Key)
- `seller_id` (UUID, Foreign Key)
- `product_id` (UUID, Foreign Key)
- `quantity` (INTEGER)
- `total_price` (DECIMAL)
- `status` (ENUM: 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled')
- `payment_method` (VARCHAR)
- `payment_status` (ENUM: 'pending', 'paid', 'failed', 'refunded')
- `shipping_address` (TEXT)
- `tracking_number` (TEXT)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

## Deployment

### Production Deployment

1. **Build the Frontend**
```bash
cd client
npm run build
```

2. **Set Up Production Database**
```bash
# Create production database
createdb iduka_production

# Run database setup
NODE_ENV=production npm run setup-db
```

3. **Configure Production Environment**
```bash
# Set production environment variables
export NODE_ENV=production
export DB_HOST=your_production_db_host
export DB_NAME=iduka_production
# ... other production variables
```

4. **Start Production Server**
```bash
npm start
```

### Docker Deployment

Create a `Dockerfile` for containerized deployment:

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY client/package*.json ./client/

# Install dependencies
RUN npm ci --only=production
RUN cd client && npm ci --only=production

# Copy source code
COPY . .

# Build frontend
RUN cd client && npm run build

# Create uploads directory
RUN mkdir -p uploads/videos

# Expose port
EXPOSE 5000

# Start the application
CMD ["npm", "start"]
```

## Security Features

- JWT-based authentication with secure token generation
- Password hashing with bcryptjs
- Input validation and sanitization
- SQL injection prevention with parameterized queries
- Rate limiting to prevent abuse
- CORS configuration for cross-origin requests
- Helmet.js for security headers
- File upload restrictions and validation

## Performance Optimizations

- Database indexing for frequently queried fields
- React Query for efficient data fetching and caching
- Lazy loading for images and videos
- Code splitting for better bundle management
- Optimized database queries with proper joins
- Pagination for large datasets
- Image compression and optimization

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

## Future Enhancements

- Push notifications for new messages and orders
- Advanced analytics dashboard for sellers
- Multi-language support (English, Kinyarwanda, French)
- Product recommendation engine
- Enhanced mobile app development
- Integration with more payment providers
- Advanced search with AI-powered recommendations
- Seller verification system
- Dispute resolution system
- Delivery tracking integration

---

**IDUKA** - Empowering Rwandan businesses through digital commerce
