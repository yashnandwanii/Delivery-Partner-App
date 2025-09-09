# Delivery Partner Backend Setup Guide

## 🚀 Quick Start

### Prerequisites
- Node.js (v18 or higher)
- MongoDB (v5.0 or higher)
- npm or yarn

### Installation Steps

1. **Install MongoDB** (if not already installed):
   ```bash
   # On macOS
   brew tap mongodb/brew
   brew install mongodb-community
   
   # On Ubuntu/Debian
   sudo apt-get install mongodb
   
   # On Windows
   # Download from https://www.mongodb.com/try/download/community
   ```

2. **Start MongoDB**:
   ```bash
   # On macOS
   brew services start mongodb/brew/mongodb-community
   
   # On Linux/Windows
   mongod --dbpath /path/to/your/data/directory
   ```

3. **Install Dependencies**:
   ```bash
   cd Backend
   npm install
   ```

4. **Environment Setup**:
   ```bash
   # Copy environment template
   cp .env.example .env
   
   # Edit .env file with your configurations
   nano .env
   ```

5. **Start the Server**:
   ```bash
   npm start
   ```

## 📁 Project Structure

```
Backend/
├── config/
│   └── socket.js          # Socket.IO configuration
├── controllers/           # Business logic controllers
├── middleware/
│   └── authMiddleware.js  # JWT authentication
├── models/
│   ├── DeliveryPartner.js # Delivery partner schema
│   └── DeliveryOrder.js   # Order management schema
├── routes/
│   ├── auth.js           # Authentication routes
│   ├── orders.js         # Order management routes
│   ├── location.js       # GPS tracking routes
│   └── partner.js        # Profile & earnings routes
├── .env                  # Environment variables
├── package.json          # Dependencies
├── server.js             # Main application entry
└── test-api.js           # API testing script
```

## 🔌 API Endpoints

### Authentication (`/api/delivery/auth`)
- `POST /register` - Register new delivery partner
- `POST /login` - Login delivery partner
- `POST /refresh` - Refresh JWT token
- `GET /profile` - Get authenticated user profile

### Orders (`/api/delivery/orders`)
- `GET /available` - Get available orders (location-based)
- `GET /my` - Get delivery partner's order history
- `POST /:orderId/accept` - Accept an order
- `POST /:orderId/pickup` - Mark order as picked up
- `POST /:orderId/deliver` - Mark order as delivered
- `GET /:orderId` - Get order details

### Location (`/api/delivery/location`)
- `POST /` - Update current location
- `GET /` - Get current location
- `POST /availability` - Update availability status

### Partner (`/api/delivery/partner`)
- `GET /profile` - Get delivery partner profile
- `PUT /profile` - Update profile information
- `GET /earnings` - Get earnings dashboard
- `GET /stats` - Get delivery statistics
- `POST /toggle-availability` - Toggle online/offline status

## 🔧 Configuration

### Environment Variables (.env)
```bash
# Server Configuration
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/delivery_partner_db

# JWT Configuration
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=21d

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000

# Socket.IO Configuration
SOCKET_CORS_ORIGIN=*
```

## 🧪 Testing

### Manual API Testing
```bash
# Run the test script
node test-api.js

# Or test individual endpoints
curl -X GET http://localhost:5000/api/health
```

### Using Postman/Thunder Client

1. **Register a delivery partner**:
   ```
   POST http://localhost:5000/api/delivery/auth/register
   Content-Type: application/json
   
   {
     "name": "John Doe",
     "email": "john@example.com",
     "password": "password123",
     "phone": "+1234567890",
     "vehicleType": "bike",
     "vehicleNumber": "ABC123"
   }
   ```

2. **Login**:
   ```
   POST http://localhost:5000/api/delivery/auth/login
   Content-Type: application/json
   
   {
     "email": "john@example.com",
     "password": "password123"
   }
   ```

3. **Update location** (requires Bearer token):
   ```
   POST http://localhost:5000/api/delivery/location
   Authorization: Bearer <your_jwt_token>
   Content-Type: application/json
   
   {
     "latitude": 37.7749,
     "longitude": -122.4194,
     "heading": 45,
     "speed": 25
   }
   ```

## 🔄 Real-time Features

### Socket.IO Events

**Client can listen for:**
- `delivery:new_order` - New order available
- `delivery:order_cancelled` - Order was cancelled
- `order:status_update` - Order status changed
- `delivery:location_request` - Customer requests location

**Client can emit:**
- `delivery:location_update` - Send location update
- `delivery:status_change` - Update availability
- `order:accept` - Accept an order
- `order:update` - Update order status

### Example Socket.IO Client (Flutter)
```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('delivery:new_order', (data) {
      // Handle new order notification
      print('New order: ${data}');
    });
  }
}
```

## 🚀 Production Deployment

### Docker Deployment
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
```

### Environment Variables for Production
```bash
NODE_ENV=production
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/delivery_db
JWT_SECRET=very_secure_random_string_for_production
FRONTEND_URL=https://your-app.com
```

### Reverse Proxy (Nginx)
```nginx
server {
    listen 80;
    server_name your-api.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 📊 Features Included

### ✅ Authentication & Security
- JWT-based authentication
- Password hashing with bcrypt
- Rate limiting (100 requests/15min)
- CORS configuration
- Input validation & sanitization

### ✅ Order Management
- Real-time order assignment
- Location-based order filtering
- Order lifecycle tracking
- Earnings calculation
- Transaction-safe order operations

### ✅ Location Services
- Real-time GPS tracking
- Geospatial queries (nearby orders)
- Location history
- Availability status management

### ✅ Dashboard Features
- Earnings analytics (daily/weekly/monthly)
- Performance statistics
- Order history with pagination
- Profile management

### ✅ Real-time Communication
- Socket.IO integration
- Live order updates
- Location broadcasting
- Customer notifications

### ✅ Production Ready
- Error handling & logging
- Health check endpoints
- Graceful shutdown
- Environment configuration
- Database indexing for performance

## 🔧 Troubleshooting

### Common Issues

1. **MongoDB Connection Error**:
   ```
   Error: connect ECONNREFUSED 127.0.0.1:27017
   ```
   **Solution**: Start MongoDB service
   ```bash
   brew services start mongodb/brew/mongodb-community
   ```

2. **JWT Token Invalid**:
   ```
   Error: Invalid token
   ```
   **Solution**: Check JWT_SECRET in .env file

3. **CORS Error**:
   ```
   Error: Access to fetch blocked by CORS
   ```
   **Solution**: Update FRONTEND_URL in .env

4. **Port Already in Use**:
   ```
   Error: listen EADDRINUSE :::5000
   ```
   **Solution**: Change PORT in .env or kill existing process

## 📝 Development Notes

- Use `npm run dev` for development with nodemon
- All routes are protected except auth endpoints
- Database indexes are automatically created
- Socket.IO namespace: `/delivery`
- API versioning: `/api/v1/...` (ready for future versions)

## 🤝 Integration with Flutter App

The Flutter app should connect to:
- **API Base URL**: `http://localhost:5000/api/delivery`
- **Socket.IO URL**: `http://localhost:5000`
- **WebSocket Events**: See real-time features section

### Sample Flutter HTTP Service
```dart
class ApiService {
  static const String baseUrl = 'http://localhost:5000/api/delivery';
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    return json.decode(response.body);
  }
}
```

---

**🎉 Your delivery partner backend is now fully functional with production-ready features!**
