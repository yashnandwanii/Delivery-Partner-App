import express from 'express';
import jwt from 'jsonwebtoken';
import { body, validationResult } from 'express-validator';
import rateLimit from 'express-rate-limit';
import DeliveryPartner from '../models/DeliveryPartner.js';
import { authenticateToken } from '../middleware/authMiddleware.js';

const router = express.Router();

// Rate limiting for auth endpoints
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // limit each IP to 5 requests per windowMs
    message: {
        success: false,
        message: 'Too many authentication attempts, please try again later.'
    }
});

const registerLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 3, // limit each IP to 3 registration attempts per hour
    message: {
        success: false,
        message: 'Too many registration attempts, please try again later.'
    }
});

// Validation rules
const registerValidation = [
    body('name')
        .trim()
        .isLength({ min: 2, max: 50 })
        .withMessage('Name must be between 2 and 50 characters'),
    body('email')
        .isEmail()
        .normalizeEmail()
        .withMessage('Please provide a valid email'),
    body('phone')
        .matches(/^\+?[\d\s-()]+$/)
        .withMessage('Please provide a valid phone number'),
    body('password')
        .isLength({ min: 6 })
        .withMessage('Password must be at least 6 characters long'),
    body('vehicleType')
        .isIn(['bicycle', 'motorcycle', 'car', 'scooter', 'other'])
        .withMessage('Invalid vehicle type'),
    body('vehicleNumber')
        .trim()
        .isLength({ min: 1 })
        .withMessage('Vehicle number is required'),
    body('licenseNumber')
        .trim()
        .isLength({ min: 1 })
        .withMessage('License number is required')
];

const loginValidation = [
    body('email')
        .isEmail()
        .normalizeEmail()
        .withMessage('Please provide a valid email'),
    body('password')
        .notEmpty()
        .withMessage('Password is required')
];

// Generate JWT token
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRE || '21d'
    });
};

// @desc    Register delivery partner
// @route   POST /api/delivery/auth/register
// @access  Public
router.post('/register', registerLimiter, registerValidation, async (req, res) => {
    try {
        // Check for validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                message: 'Validation failed',
                errors: errors.array()
            });
        }

        const {
            name,
            email,
            phone,
            password,
            vehicleType,
            vehicleNumber,
            licenseNumber,
            address
        } = req.body;

        // Check if delivery partner already exists
        const existingPartner = await DeliveryPartner.findOne({
            $or: [{ email }, { phone }]
        });

        if (existingPartner) {
            return res.status(409).json({
                success: false,
                message: 'Delivery partner already exists with this email or phone'
            });
        }

        // Create new delivery partner
        const deliveryPartner = new DeliveryPartner({
            name,
            email,
            phone,
            password,
            vehicleType,
            vehicleNumber,
            licenseNumber,
            address
        });

        await deliveryPartner.save();

        // Generate token
        const token = generateToken(deliveryPartner._id);

        // Remove password from response
        const partnerResponse = deliveryPartner.toObject();
        delete partnerResponse.password;

        res.status(201).json({
            success: true,
            message: 'Delivery partner registered successfully',
            data: {
                deliveryPartner: partnerResponse,
                token
            }
        });

        console.log(`✅ New delivery partner registered: ${name} (${email})`);
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({
            success: false,
            message: 'Registration failed',
            error: error.message
        });
    }
});

// @desc    Login delivery partner
// @route   POST /api/delivery/auth/login
// @access  Public
router.post('/login', authLimiter, loginValidation, async (req, res) => {
    try {
        // Check for validation errors
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                message: 'Validation failed',
                errors: errors.array()
            });
        }

        const { email, password } = req.body;

        // Find delivery partner by email and include password
        const deliveryPartner = await DeliveryPartner.findOne({ email }).select('+password');

        if (!deliveryPartner) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        // Check if account is active
        if (!deliveryPartner.isActive) {
            return res.status(401).json({
                success: false,
                message: 'Account has been deactivated. Please contact support.'
            });
        }

        // Check password
        const isPasswordMatch = await deliveryPartner.comparePassword(password);

        if (!isPasswordMatch) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        // Update last active time
        deliveryPartner.lastActiveAt = new Date();
        await deliveryPartner.save();

        // Generate token
        const token = generateToken(deliveryPartner._id);

        // Remove password from response
        const partnerResponse = deliveryPartner.toObject();
        delete partnerResponse.password;

        res.json({
            success: true,
            message: 'Login successful',
            data: {
                deliveryPartner: partnerResponse,
                token
            }
        });

        console.log(`✅ Delivery partner logged in: ${deliveryPartner.name} (${email})`);
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({
            success: false,
            message: 'Login failed',
            error: error.message
        });
    }
});

// @desc    Get current delivery partner profile
// @route   GET /api/delivery/auth/me
// @access  Private
router.get('/me', authenticateToken, async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;

        res.json({
            success: true,
            data: {
                deliveryPartner
            }
        });
    } catch (error) {
        console.error('Profile fetch error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch profile',
            error: error.message
        });
    }
});

// @desc    Update delivery partner profile
// @route   PUT /api/delivery/auth/profile
// @access  Private
router.put('/profile', authenticateToken, [
    body('name').optional().trim().isLength({ min: 2, max: 50 }),
    body('phone').optional().matches(/^\+?[\d\s-()]+$/),
    body('vehicleType').optional().isIn(['bicycle', 'motorcycle', 'car', 'scooter', 'other']),
    body('vehicleNumber').optional().trim().isLength({ min: 1 })
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                message: 'Validation failed',
                errors: errors.array()
            });
        }

        const deliveryPartner = req.deliveryPartner;
        const updates = req.body;

        // Remove fields that shouldn't be updated directly
        delete updates.password;
        delete updates.email;
        delete updates.isVerified;
        delete updates.isActive;

        // Update delivery partner
        Object.assign(deliveryPartner, updates);
        await deliveryPartner.save();

        res.json({
            success: true,
            message: 'Profile updated successfully',
            data: {
                deliveryPartner
            }
        });
    } catch (error) {
        console.error('Profile update error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update profile',
            error: error.message
        });
    }
});

// @desc    Change password
// @route   PUT /api/delivery/auth/change-password
// @access  Private
router.put('/change-password', authenticateToken, [
    body('currentPassword').notEmpty().withMessage('Current password is required'),
    body('newPassword').isLength({ min: 6 }).withMessage('New password must be at least 6 characters long')
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                message: 'Validation failed',
                errors: errors.array()
            });
        }

        const { currentPassword, newPassword } = req.body;

        // Get delivery partner with password
        const deliveryPartner = await DeliveryPartner.findById(req.deliveryPartner._id).select('+password');

        // Verify current password
        const isCurrentPasswordValid = await deliveryPartner.comparePassword(currentPassword);
        if (!isCurrentPasswordValid) {
            return res.status(400).json({
                success: false,
                message: 'Current password is incorrect'
            });
        }

        // Update password
        deliveryPartner.password = newPassword;
        await deliveryPartner.save();

        res.json({
            success: true,
            message: 'Password changed successfully'
        });
    } catch (error) {
        console.error('Password change error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to change password',
            error: error.message
        });
    }
});

// @desc    Update FCM token
// @route   POST /api/delivery/auth/fcm-token
// @access  Private
router.post('/fcm-token', authenticateToken, [
    body('fcmToken').notEmpty().withMessage('FCM token is required')
], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({
                success: false,
                message: 'Validation failed',
                errors: errors.array()
            });
        }

        const { fcmToken } = req.body;
        const deliveryPartner = req.deliveryPartner;

        // Add FCM token if not already exists
        if (!deliveryPartner.fcmTokens.includes(fcmToken)) {
            deliveryPartner.fcmTokens.push(fcmToken);
            await deliveryPartner.save();
        }

        res.json({
            success: true,
            message: 'FCM token updated successfully'
        });
    } catch (error) {
        console.error('FCM token update error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update FCM token',
            error: error.message
        });
    }
});

export default router;
