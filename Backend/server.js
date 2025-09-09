import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { Server } from 'socket.io';
import { createServer } from 'http';

// Import routes
import authRoutes from './routes/auth.js';
import orderRoutes from './routes/orders.js';
import locationRoutes from './routes/location.js';
import partnerRoutes from './routes/partner.js';

// Import socket handlers
import { initializeSocket } from './config/socket.js';

// Load environment variables
dotenv.config();

const app = express();
const server = createServer(app);

// Initialize Socket.IO
const io = new Server(server, {
    cors: {
        origin: process.env.FRONTEND_URL || "*",
        methods: ["GET", "POST", "PUT", "DELETE"],
        credentials: true
    }
});

// Initialize socket handlers
initializeSocket(io);

// Security middleware
app.use(helmet());
app.use(cors({
    origin: process.env.FRONTEND_URL || "*",
    credentials: true
}));

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
});
app.use('/api', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Make io accessible in routes
app.use((req, res, next) => {
    req.io = io;
    next();
});

// API Routes
app.use('/api/delivery/auth', authRoutes);
app.use('/api/delivery/orders', orderRoutes);
app.use('/api/delivery/location', locationRoutes);
app.use('/api/delivery/partner', partnerRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.status(200).json({
        success: true,
        message: 'Delivery Partner Backend is running',
        timestamp: new Date().toISOString(),
        service: 'delivery-partner-api',
        version: '1.0.0'
    });
});

// Default route
app.get('/', (req, res) => {
    res.json({
        success: true,
        message: 'Welcome to Delivery Partner API',
        endpoints: {
            auth: '/api/delivery/auth',
            orders: '/api/delivery/orders',
            location: '/api/delivery/location',
            partner: '/api/delivery/partner',
            health: '/api/health'
        }
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        message: 'Route not found',
        path: req.originalUrl
    });
});

// Global error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);

    const statusCode = err.statusCode || 500;
    const message = err.message || 'Internal Server Error';

    res.status(statusCode).json({
        success: false,
        message,
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
});

// Database connection
const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/delivery-partner');
        console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
        return true;
    } catch (error) {
        console.error('❌ Database connection failed:', error.message);
        return false;
    }
};

// Start server
const PORT = process.env.PORT || 6014;

const startServer = async () => {
    try {
        // Connect to database
        const dbConnected = await connectDB();
        if (!dbConnected) {
            console.error('❌ Failed to connect to database. Exiting...');
            process.exit(1);
        }

        // Start server
        server.listen(PORT, () => {
            console.log(`🚀 Delivery Partner Server running on port ${PORT}`);
            console.log(`📍 API Base URL: http://localhost:${PORT}/api`);
            console.log(`🔗 Health Check: http://localhost:${PORT}/api/health`);
            console.log(`⚡ Socket.IO Server initialized`);
            console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
        });
    } catch (error) {
        console.error('❌ Failed to start server:', error.message);
        process.exit(1);
    }
};

// Handle graceful shutdown
process.on('SIGTERM', async () => {
    console.log('SIGTERM received. Shutting down gracefully...');
    server.close(() => {
        mongoose.connection.close(false, () => {
            console.log('MongoDB connection closed.');
            process.exit(0);
        });
    });
});

process.on('SIGINT', async () => {
    console.log('SIGINT received. Shutting down gracefully...');
    server.close(async () => {
        await mongoose.connection.close();
        console.log('MongoDB connection closed.');
        process.exit(0);
    });
});

// Start the application
startServer();

export default app;
