import express from 'express';
import { body, validationResult } from 'express-validator';
import DeliveryPartner from '../models/DeliveryPartner.js';
import { authenticateToken } from '../middleware/authMiddleware.js';

const router = express.Router();

// @desc    Update delivery partner location
// @route   POST /api/delivery/location
// @access  Private
router.post('/',
    authenticateToken,
    [
        body('latitude')
            .isFloat({ min: -90, max: 90 })
            .withMessage('Latitude must be between -90 and 90'),
        body('longitude')
            .isFloat({ min: -180, max: 180 })
            .withMessage('Longitude must be between -180 and 180'),
        body('heading')
            .optional()
            .isFloat({ min: 0, max: 360 })
            .withMessage('Heading must be between 0 and 360 degrees'),
        body('speed')
            .optional()
            .isFloat({ min: 0 })
            .withMessage('Speed must be a positive number'),
        body('accuracy')
            .optional()
            .isFloat({ min: 0 })
            .withMessage('Accuracy must be a positive number')
    ],
    async (req, res) => {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { latitude, longitude, heading, speed, accuracy } = req.body;
            const deliveryPartner = req.deliveryPartner;

            // Update location
            await deliveryPartner.updateLocation(longitude, latitude);

            // Emit location update via socket if available
            if (req.io) {
                req.io.emit('delivery:location_update', {
                    deliveryPartnerId: deliveryPartner._id,
                    location: {
                        latitude,
                        longitude,
                        heading,
                        speed,
                        accuracy
                    },
                    timestamp: new Date()
                });
            }

            res.json({
                success: true,
                message: 'Location updated successfully',
                data: {
                    location: {
                        latitude,
                        longitude,
                        heading,
                        speed,
                        accuracy,
                        updatedAt: new Date()
                    }
                }
            });

        } catch (error) {
            console.error('Location update error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to update location',
                error: error.message
            });
        }
    }
);

// @desc    Get current location
// @route   GET /api/delivery/location
// @access  Private
router.get('/', authenticateToken, async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;

        const location = deliveryPartner.currentLocation;

        if (!location || !location.coordinates || location.coordinates.every(coord => coord === 0)) {
            return res.status(404).json({
                success: false,
                message: 'Location not set'
            });
        }

        const [longitude, latitude] = location.coordinates;

        res.json({
            success: true,
            data: {
                location: {
                    latitude,
                    longitude,
                    lastUpdated: deliveryPartner.lastActiveAt
                }
            }
        });

    } catch (error) {
        console.error('Get location error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get location',
            error: error.message
        });
    }
});

// @desc    Update availability status
// @route   POST /api/delivery/location/availability
// @access  Private
router.post('/availability',
    authenticateToken,
    [
        body('isAvailable')
            .isBoolean()
            .withMessage('isAvailable must be a boolean value')
    ],
    async (req, res) => {
        try {
            const errors = validationResult(req);
            if (!errors.isEmpty()) {
                return res.status(400).json({
                    success: false,
                    message: 'Validation failed',
                    errors: errors.array()
                });
            }

            const { isAvailable } = req.body;
            const deliveryPartner = req.deliveryPartner;

            // Update availability
            await deliveryPartner.updateAvailability(isAvailable);

            // Emit availability status change via socket
            if (req.io) {
                req.io.emit('delivery:availability_change', {
                    deliveryPartnerId: deliveryPartner._id,
                    isAvailable,
                    timestamp: new Date()
                });
            }

            res.json({
                success: true,
                message: `Status updated to ${isAvailable ? 'available' : 'unavailable'}`,
                data: {
                    isAvailable,
                    updatedAt: new Date()
                }
            });

            console.log(`🔄 ${deliveryPartner.name} is now ${isAvailable ? 'available' : 'unavailable'}`);

        } catch (error) {
            console.error('Availability update error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to update availability',
                error: error.message
            });
        }
    }
);

export default router;
