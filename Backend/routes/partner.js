import express from 'express';
import { body, validationResult } from 'express-validator';
import DeliveryPartner from '../models/DeliveryPartner.js';
import DeliveryOrder from '../models/DeliveryOrder.js';
import { authenticateToken } from '../middleware/authMiddleware.js';
import {
    toggleAvailability,
    updateLocation,
    getProfile,
    getEarnings,
    getStats
} from '../controllers/partnerController.js';

const router = express.Router();

// Test route
router.get('/test', (req, res) => {
    res.json({
        success: true,
        message: 'Partner routes working!',
        timestamp: new Date().toISOString()
    });
});

// @route   PUT /api/delivery/partner/status
// @desc    Toggle delivery partner availability (Go Online/Offline)
// @access  Private (Delivery Partner)
router.put('/status', authenticateToken, toggleAvailability);

// @route   POST /api/delivery/partner/location
// @desc    Update delivery partner location
// @access  Private (Delivery Partner)
router.post('/location', authenticateToken, updateLocation);

// @route   GET /api/delivery/partner/earnings
// @desc    Get delivery partner earnings
// @access  Private (Delivery Partner)
router.get('/earnings', authenticateToken, getEarnings);

// @route   GET /api/delivery/partner/stats
// @desc    Get delivery partner statistics
// @access  Private (Delivery Partner)
router.get('/stats', authenticateToken, getStats);

// @desc    Get delivery partner profile
// @route   GET /api/delivery/partner/profile
// @access  Private
router.get('/profile', authenticateToken, getProfile);

// @desc    Update delivery partner profile
// @route   PUT /api/delivery/partner/profile
// @access  Private
router.put('/profile',
    authenticateToken,
    [
        body('name')
            .optional()
            .isLength({ min: 2 })
            .withMessage('Name must be at least 2 characters'),
        body('phone')
            .optional()
            .isMobilePhone()
            .withMessage('Please provide a valid phone number'),
        body('vehicleType')
            .optional()
            .isIn(['bike', 'scooter', 'bicycle', 'car'])
            .withMessage('Vehicle type must be bike, scooter, bicycle, or car'),
        body('vehicleNumber')
            .optional()
            .isLength({ min: 3 })
            .withMessage('Vehicle number must be at least 3 characters')
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

            const deliveryPartner = req.deliveryPartner;
            const { name, phone, vehicleType, vehicleNumber } = req.body;

            // Update fields if provided
            if (name) deliveryPartner.name = name;
            if (phone) deliveryPartner.phone = phone;
            if (vehicleType) deliveryPartner.vehicleType = vehicleType;
            if (vehicleNumber) deliveryPartner.vehicleNumber = vehicleNumber;

            await deliveryPartner.save();

            res.json({
                success: true,
                message: 'Profile updated successfully',
                data: {
                    profile: {
                        id: deliveryPartner._id,
                        name: deliveryPartner.name,
                        phone: deliveryPartner.phone,
                        vehicleType: deliveryPartner.vehicleType,
                        vehicleNumber: deliveryPartner.vehicleNumber
                    }
                }
            });

        } catch (error) {
            console.error('Update profile error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to update profile',
                error: error.message
            });
        }
    }
);

// @desc    Get earnings dashboard
// @route   GET /api/delivery/partner/earnings
// @access  Private
router.get('/earnings', authenticateToken, async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;
        const { period = 'week' } = req.query; // day, week, month, year

        let dateFilter = {};
        const now = new Date();

        switch (period) {
            case 'day':
                dateFilter = {
                    createdAt: {
                        $gte: new Date(now.setHours(0, 0, 0, 0)),
                        $lte: new Date(now.setHours(23, 59, 59, 999))
                    }
                };
                break;
            case 'week':
                const weekStart = new Date(now.setDate(now.getDate() - now.getDay()));
                weekStart.setHours(0, 0, 0, 0);
                dateFilter = {
                    createdAt: { $gte: weekStart }
                };
                break;
            case 'month':
                const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
                dateFilter = {
                    createdAt: { $gte: monthStart }
                };
                break;
            case 'year':
                const yearStart = new Date(now.getFullYear(), 0, 1);
                dateFilter = {
                    createdAt: { $gte: yearStart }
                };
                break;
        }

        // Get orders for the period
        const orders = await DeliveryOrder.find({
            deliveryPartnerId: deliveryPartner._id,
            status: 'delivered',
            ...dateFilter
        }).sort({ createdAt: -1 });

        // Calculate earnings summary
        const totalEarnings = orders.reduce((sum, order) => sum + (order.deliveryFee || 0), 0);
        const totalOrders = orders.length;
        const avgEarningPerOrder = totalOrders > 0 ? totalEarnings / totalOrders : 0;

        // Daily breakdown for charts
        const dailyEarnings = {};
        orders.forEach(order => {
            const date = new Date(order.createdAt).toDateString();
            if (!dailyEarnings[date]) {
                dailyEarnings[date] = { earnings: 0, orders: 0 };
            }
            dailyEarnings[date].earnings += order.deliveryFee || 0;
            dailyEarnings[date].orders += 1;
        });

        const chartData = Object.entries(dailyEarnings).map(([date, data]) => ({
            date,
            earnings: data.earnings,
            orders: data.orders
        }));

        res.json({
            success: true,
            data: {
                summary: {
                    period,
                    totalEarnings,
                    totalOrders,
                    avgEarningPerOrder: parseFloat(avgEarningPerOrder.toFixed(2)),
                    lifetimeEarnings: deliveryPartner.totalEarnings,
                    lifetimeOrders: deliveryPartner.totalOrders
                },
                chartData,
                recentOrders: orders.slice(0, 10).map(order => ({
                    id: order._id,
                    orderNumber: order.orderNumber,
                    earnings: order.deliveryFee,
                    distance: order.distance,
                    duration: order.duration,
                    completedAt: order.deliveredAt,
                    customer: {
                        name: order.customer?.name,
                        address: order.deliveryAddress?.formattedAddress
                    }
                }))
            }
        });

    } catch (error) {
        console.error('Get earnings error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get earnings data',
            error: error.message
        });
    }
});

// @desc    Get delivery partner stats
// @route   GET /api/delivery/partner/stats
// @access  Private
router.get('/stats', authenticateToken, async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;

        // Get today's stats
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const todayOrders = await DeliveryOrder.countDocuments({
            deliveryPartnerId: deliveryPartner._id,
            createdAt: { $gte: today },
            status: 'delivered'
        });

        const todayEarnings = await DeliveryOrder.aggregate([
            {
                $match: {
                    deliveryPartnerId: deliveryPartner._id,
                    createdAt: { $gte: today },
                    status: 'delivered'
                }
            },
            {
                $group: {
                    _id: null,
                    total: { $sum: '$deliveryFee' }
                }
            }
        ]);

        // Get active order
        const activeOrder = await DeliveryOrder.findOne({
            deliveryPartnerId: deliveryPartner._id,
            status: { $in: ['assigned', 'picked_up'] }
        }).populate('restaurant customer');

        // Weekly performance
        const weekStart = new Date();
        weekStart.setDate(weekStart.getDate() - 7);

        const weeklyStats = await DeliveryOrder.aggregate([
            {
                $match: {
                    deliveryPartnerId: deliveryPartner._id,
                    createdAt: { $gte: weekStart }
                }
            },
            {
                $group: {
                    _id: '$status',
                    count: { $sum: 1 }
                }
            }
        ]);

        const weeklyStatusCounts = {};
        weeklyStats.forEach(stat => {
            weeklyStatusCounts[stat._id] = stat.count;
        });

        const completionRate = weeklyStatusCounts.delivered && (weeklyStatusCounts.delivered + (weeklyStatusCounts.cancelled || 0)) > 0
            ? (weeklyStatusCounts.delivered / (weeklyStatusCounts.delivered + (weeklyStatusCounts.cancelled || 0))) * 100
            : 100;

        res.json({
            success: true,
            data: {
                today: {
                    orders: todayOrders,
                    earnings: todayEarnings[0]?.total || 0
                },
                overall: {
                    totalOrders: deliveryPartner.totalOrders,
                    totalEarnings: deliveryPartner.totalEarnings,
                    rating: deliveryPartner.rating,
                    completionRate: parseFloat(completionRate.toFixed(1))
                },
                activeOrder: activeOrder ? {
                    id: activeOrder._id,
                    orderNumber: activeOrder.orderNumber,
                    status: activeOrder.status,
                    restaurant: activeOrder.restaurant?.name,
                    customer: activeOrder.customer?.name,
                    pickupAddress: activeOrder.pickupAddress?.formattedAddress,
                    deliveryAddress: activeOrder.deliveryAddress?.formattedAddress,
                    estimatedEarnings: activeOrder.deliveryFee
                } : null,
                isAvailable: deliveryPartner.isAvailable,
                lastActiveAt: deliveryPartner.lastActiveAt
            }
        });

    } catch (error) {
        console.error('Get stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to get stats',
            error: error.message
        });
    }
});

// @desc    Toggle availability
// @route   POST /api/delivery/partner/toggle-availability
// @access  Private
router.post('/toggle-availability', authenticateToken, async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;

        // Check if has active orders
        const activeOrder = await DeliveryOrder.findOne({
            deliveryPartnerId: deliveryPartner._id,
            status: { $in: ['assigned', 'picked_up'] }
        });

        if (activeOrder && deliveryPartner.isAvailable) {
            return res.status(400).json({
                success: false,
                message: 'Cannot go offline while having active orders'
            });
        }

        const newAvailability = !deliveryPartner.isAvailable;
        await deliveryPartner.updateAvailability(newAvailability);

        // Emit availability change
        if (req.io) {
            req.io.emit('delivery:availability_change', {
                deliveryPartnerId: deliveryPartner._id,
                isAvailable: newAvailability,
                timestamp: new Date()
            });
        }

        res.json({
            success: true,
            message: `You are now ${newAvailability ? 'available' : 'offline'}`,
            data: {
                isAvailable: newAvailability,
                updatedAt: new Date()
            }
        });

        console.log(`🔄 ${deliveryPartner.name} toggled availability to ${newAvailability ? 'available' : 'offline'}`);

    } catch (error) {
        console.error('Toggle availability error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to toggle availability',
            error: error.message
        });
    }
});

export default router;
