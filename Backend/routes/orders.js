import express from 'express';
import { body, validationResult, query } from 'express-validator';
import mongoose from 'mongoose';
import DeliveryOrder from '../models/DeliveryOrder.js';
import DeliveryPartner from '../models/DeliveryPartner.js';
import { authenticateToken, requireVerified } from '../middleware/authMiddleware.js';
import { emitToUser, emitToRestaurant } from '../config/socket.js';

const router = express.Router();

// @desc    Get available orders for delivery
// @route   GET /api/delivery/orders/available
// @access  Private
router.get('/available',
    authenticateToken,
    requireVerified,
    [
        query('latitude').optional().isFloat({ min: -90, max: 90 }).withMessage('Invalid latitude'),
        query('longitude').optional().isFloat({ min: -180, max: 180 }).withMessage('Invalid longitude'),
        query('radius').optional().isInt({ min: 1000, max: 50000 }).withMessage('Radius must be between 1000-50000 meters'),
        query('limit').optional().isInt({ min: 1, max: 50 }).withMessage('Limit must be between 1-50')
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
            const { latitude, longitude, radius = 10000, limit = 20 } = req.query;

            let query = {
                orderStatus: 'ready_for_pickup',
                deliveryPartnerId: null
            };

            // If location provided, find nearby orders
            if (latitude && longitude) {
                query['restaurantAddress.coordinates'] = {
                    $near: {
                        $geometry: {
                            type: 'Point',
                            coordinates: [parseFloat(longitude), parseFloat(latitude)]
                        },
                        $maxDistance: parseInt(radius)
                    }
                };
            } else if (deliveryPartner.currentLocation?.coordinates) {
                // Use delivery partner's current location
                const [lng, lat] = deliveryPartner.currentLocation.coordinates;
                query['restaurantAddress.coordinates'] = {
                    $near: {
                        $geometry: {
                            type: 'Point',
                            coordinates: [lng, lat]
                        },
                        $maxDistance: parseInt(radius)
                    }
                };
            }

            const orders = await DeliveryOrder.find(query)
                .populate('restaurantId', 'name phone address profileImage')
                .populate('customerId', 'name phone')
                .limit(parseInt(limit))
                .sort({ createdAt: 1 });

            res.json({
                success: true,
                count: orders.length,
                data: {
                    orders
                }
            });
        } catch (error) {
            console.error('Get available orders error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch available orders',
                error: error.message
            });
        }
    }
);

// @desc    Get delivery partner's orders
// @route   GET /api/delivery/orders/my
// @access  Private
router.get('/my',
    authenticateToken,
    [
        query('status').optional().isIn(['assigned', 'picked_up', 'out_for_delivery', 'delivered', 'cancelled']),
        query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1-100'),
        query('page').optional().isInt({ min: 1 }).withMessage('Page must be greater than 0')
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
            const { status, limit = 20, page = 1 } = req.query;

            let query = { deliveryPartnerId: deliveryPartner._id };

            if (status) {
                query.orderStatus = status;
            }

            const skip = (parseInt(page) - 1) * parseInt(limit);

            const orders = await DeliveryOrder.find(query)
                .populate('restaurantId', 'name phone address profileImage')
                .populate('customerId', 'name phone')
                .sort({ createdAt: -1 })
                .limit(parseInt(limit))
                .skip(skip);

            const totalOrders = await DeliveryOrder.countDocuments(query);

            res.json({
                success: true,
                count: orders.length,
                totalCount: totalOrders,
                currentPage: parseInt(page),
                totalPages: Math.ceil(totalOrders / parseInt(limit)),
                data: {
                    orders
                }
            });
        } catch (error) {
            console.error('Get my orders error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch orders',
                error: error.message
            });
        }
    }
);

// @desc    Accept an order
// @route   POST /api/delivery/orders/:orderId/accept
// @access  Private
router.post('/:orderId/accept',
    authenticateToken,
    requireVerified,
    async (req, res) => {
        const session = await mongoose.startSession();
        session.startTransaction();

        try {
            const { orderId } = req.params;
            const deliveryPartner = req.deliveryPartner;

            // Check if delivery partner is available
            if (!deliveryPartner.isAvailable) {
                await session.abortTransaction();
                return res.status(400).json({
                    success: false,
                    message: 'You must be available to accept orders'
                });
            }

            // Find the order
            const order = await DeliveryOrder.findOne({
                orderId: orderId,
                orderStatus: 'ready_for_pickup',
                deliveryPartnerId: null
            }).session(session);

            if (!order) {
                await session.abortTransaction();
                return res.status(404).json({
                    success: false,
                    message: 'Order not found or already assigned'
                });
            }

            // Assign order to delivery partner
            order.deliveryPartnerId = deliveryPartner._id;
            await order.updateStatus('assigned', 'delivery_partner', 'Order accepted by delivery partner');

            // Update delivery partner stats
            deliveryPartner.stats.totalDeliveries += 1;
            await deliveryPartner.save({ session });

            await session.commitTransaction();

            // Populate order details
            await order.populate('restaurantId', 'name phone address profileImage');
            await order.populate('customerId', 'name phone');

            // Emit socket events
            try {
                emitToUser(order.customerId._id, 'order:status_updated', {
                    orderId: order.orderId,
                    status: 'assigned',
                    deliveryPartner: {
                        id: deliveryPartner._id,
                        name: deliveryPartner.name,
                        phone: deliveryPartner.phone,
                        vehicleType: deliveryPartner.vehicleType,
                        vehicleNumber: deliveryPartner.vehicleNumber
                    }
                });

                emitToRestaurant(order.restaurantId._id, 'order:status_updated', {
                    orderId: order.orderId,
                    status: 'assigned',
                    deliveryPartnerId: deliveryPartner._id
                });
            } catch (socketError) {
                console.error('Socket emission error:', socketError);
                // Don't fail the request for socket errors
            }

            res.json({
                success: true,
                message: 'Order accepted successfully',
                data: {
                    order
                }
            });

            console.log(`✅ Order ${orderId} accepted by ${deliveryPartner.name}`);
        } catch (error) {
            await session.abortTransaction();
            console.error('Accept order error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to accept order',
                error: error.message
            });
        } finally {
            session.endSession();
        }
    }
);

// @desc    Mark order as picked up
// @route   POST /api/delivery/orders/:orderId/pickup
// @access  Private
router.post('/:orderId/pickup',
    authenticateToken,
    async (req, res) => {
        try {
            const { orderId } = req.params;
            const deliveryPartner = req.deliveryPartner;

            // Find the order
            const order = await DeliveryOrder.findOne({
                orderId: orderId,
                deliveryPartnerId: deliveryPartner._id,
                orderStatus: 'assigned'
            });

            if (!order) {
                return res.status(404).json({
                    success: false,
                    message: 'Order not found or cannot be picked up'
                });
            }

            // Update order status
            await order.updateStatus('picked_up', 'delivery_partner', 'Order picked up from restaurant');

            // Populate order details
            await order.populate('restaurantId', 'name phone address');
            await order.populate('customerId', 'name phone');

            // Emit socket events
            try {
                emitToUser(order.customerId._id, 'order:status_updated', {
                    orderId: order.orderId,
                    status: 'picked_up',
                    message: 'Your order has been picked up and is on the way!'
                });

                emitToRestaurant(order.restaurantId._id, 'order:status_updated', {
                    orderId: order.orderId,
                    status: 'picked_up'
                });
            } catch (socketError) {
                console.error('Socket emission error:', socketError);
            }

            res.json({
                success: true,
                message: 'Order marked as picked up',
                data: {
                    order
                }
            });

            console.log(`📦 Order ${orderId} picked up by ${deliveryPartner.name}`);
        } catch (error) {
            console.error('Pickup order error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to mark order as picked up',
                error: error.message
            });
        }
    }
);

// @desc    Mark order as delivered
// @route   POST /api/delivery/orders/:orderId/deliver
// @access  Private
router.post('/:orderId/deliver',
    authenticateToken,
    [
        body('deliveryProof').optional().isString(),
        body('customerSignature').optional().isString(),
        body('notes').optional().isString().isLength({ max: 500 })
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

            const { orderId } = req.params;
            const { deliveryProof, customerSignature, notes } = req.body;
            const deliveryPartner = req.deliveryPartner;

            // Find the order
            const order = await DeliveryOrder.findOne({
                orderId: orderId,
                deliveryPartnerId: deliveryPartner._id,
                orderStatus: 'picked_up'
            });

            if (!order) {
                return res.status(404).json({
                    success: false,
                    message: 'Order not found or cannot be delivered'
                });
            }

            // Update order status
            await order.updateStatus('delivered', 'delivery_partner', notes || 'Order delivered successfully');

            // Update delivery partner stats
            deliveryPartner.stats.completedDeliveries += 1;

            // Add earnings (calculate based on order details)
            const earnings = calculateDeliveryEarnings(order);
            order.deliveryEarnings = earnings;
            await deliveryPartner.addEarnings(earnings.total);

            await order.save();

            // Populate order details
            await order.populate('restaurantId', 'name phone address');
            await order.populate('customerId', 'name phone');

            // Emit socket events
            try {
                emitToUser(order.customerId._id, 'order:delivered', {
                    orderId: order.orderId,
                    message: 'Your order has been delivered successfully!',
                    deliveredAt: order.actualDeliveryTime
                });

                emitToRestaurant(order.restaurantId._id, 'order:status_updated', {
                    orderId: order.orderId,
                    status: 'delivered'
                });
            } catch (socketError) {
                console.error('Socket emission error:', socketError);
            }

            res.json({
                success: true,
                message: 'Order delivered successfully',
                data: {
                    order,
                    earnings
                }
            });

            console.log(`✅ Order ${orderId} delivered by ${deliveryPartner.name}`);
        } catch (error) {
            console.error('Deliver order error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to mark order as delivered',
                error: error.message
            });
        }
    }
);

// @desc    Get order details
// @route   GET /api/delivery/orders/:orderId
// @access  Private
router.get('/:orderId',
    authenticateToken,
    async (req, res) => {
        try {
            const { orderId } = req.params;
            const deliveryPartner = req.deliveryPartner;

            const order = await DeliveryOrder.findOne({
                orderId: orderId,
                deliveryPartnerId: deliveryPartner._id
            })
                .populate('restaurantId', 'name phone address profileImage')
                .populate('customerId', 'name phone');

            if (!order) {
                return res.status(404).json({
                    success: false,
                    message: 'Order not found'
                });
            }

            res.json({
                success: true,
                data: {
                    order
                }
            });
        } catch (error) {
            console.error('Get order details error:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch order details',
                error: error.message
            });
        }
    }
);

// Helper function to calculate delivery earnings
function calculateDeliveryEarnings(order) {
    const baseFee = 30; // Base delivery fee
    const perKmRate = 8; // Rate per kilometer
    const timeBonus = order.deliveryDuration && order.deliveryDuration < 30 ? 10 : 0; // Quick delivery bonus

    // Calculate distance-based earnings
    const totalDistance = (order.distanceFromRestaurant || 2000) + (order.distanceToCustomer || 2000);
    const distanceInKm = totalDistance / 1000;
    const distanceBonus = Math.round(distanceInKm * perKmRate);

    const earnings = {
        baseFee,
        distanceBonus,
        timeBonus,
        tip: 0, // Tips can be added later
        total: baseFee + distanceBonus + timeBonus
    };

    return earnings;
}

export default router;
