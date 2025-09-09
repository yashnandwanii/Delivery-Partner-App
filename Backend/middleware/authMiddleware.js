import jwt from 'jsonwebtoken';
import DeliveryPartner from '../models/DeliveryPartner.js';

export const authenticateToken = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        const token = authHeader && authHeader.startsWith('Bearer ')
            ? authHeader.slice(7)
            : req.headers['x-access-token'] || req.query.token;

        if (!token) {
            return res.status(401).json({
                success: false,
                message: 'Access token is required'
            });
        }

        // Verify token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Find delivery partner
        const deliveryPartner = await DeliveryPartner.findById(decoded.id).select('-password');

        if (!deliveryPartner) {
            return res.status(401).json({
                success: false,
                message: 'Invalid token - delivery partner not found'
            });
        }

        if (!deliveryPartner.isActive) {
            return res.status(401).json({
                success: false,
                message: 'Account has been deactivated'
            });
        }

        // Attach delivery partner to request object
        req.deliveryPartner = deliveryPartner;
        req.user = deliveryPartner; // For compatibility

        next();
    } catch (error) {
        console.error('Authentication error:', error);

        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({
                success: false,
                message: 'Token has expired'
            });
        }

        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({
                success: false,
                message: 'Invalid token'
            });
        }

        return res.status(500).json({
            success: false,
            message: 'Token verification failed'
        });
    }
};

export const requireVerified = (req, res, next) => {
    if (!req.deliveryPartner.isVerified) {
        return res.status(403).json({
            success: false,
            message: 'Account verification required'
        });
    }
    next();
};

export const requireAvailable = (req, res, next) => {
    if (!req.deliveryPartner.isAvailable) {
        return res.status(403).json({
            success: false,
            message: 'You must be available to perform this action'
        });
    }
    next();
};

// Optional auth - doesn't fail if no token provided
export const optionalAuth = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        const token = authHeader && authHeader.startsWith('Bearer ')
            ? authHeader.slice(7)
            : req.headers['x-access-token'] || req.query.token;

        if (!token) {
            return next(); // No token provided, continue without auth
        }

        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const deliveryPartner = await DeliveryPartner.findById(decoded.id).select('-password');

        if (deliveryPartner && deliveryPartner.isActive) {
            req.deliveryPartner = deliveryPartner;
            req.user = deliveryPartner;
        }

        next();
    } catch (error) {
        // Ignore auth errors for optional auth
        next();
    }
};

export default {
    authenticateToken,
    requireVerified,
    requireAvailable,
    optionalAuth
};
