import mongoose from 'mongoose';
import DeliveryPartner from '../models/DeliveryPartner.js';
import { getIO } from '../config/socket.js';

// Order Schema for the existing orders collection
const OrderSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, required: true },
    restaurantId: { type: mongoose.Schema.Types.ObjectId, required: true },
    orderItems: [{
        foodId: String,
        foodName: String,
        quantity: Number,
        price: Number,
        additives: [String]
    }],
    orderTotal: Number,
    deliveryFee: Number,
    grandTotal: Number,
    deliveryAddress: {
        street: String,
        city: String,
        zipCode: String,
        coordinates: [Number] // [longitude, latitude]
    },
    restaurantAddress: {
        street: String,
        city: String,
        zipCode: String,
        coordinates: [Number] // [longitude, latitude]
    },
    recipientCoords: [Number], // [longitude, latitude]
    restaurantCoords: [Number], // [longitude, latitude]
    paymentMethod: String,
    paymentStatus: { type: String, default: 'COMPLETED' },
    orderStatus: {
        type: String,
        enum: ['PENDING', 'CONFIRMED', 'COOKING', 'READY_FOR_PICKUP', 'WITH_DELIVERY_PARTNER', 'DELIVERED', 'CANCELLED'],
        default: 'PENDING'
    },
    deliveryPartnerId: { type: mongoose.Schema.Types.ObjectId, ref: 'DeliveryPartner' },
    deliveryPartnerLocation: [Number], // [longitude, latitude]
    estimatedDeliveryTime: Date,
    actualDeliveryTime: Date,
    notes: String,
    createdAt: { type: Date, default: Date.now },
    updatedAt: { type: Date, default: Date.now },
    // Additional fields for delivery tracking
    pickupTime: Date,
    deliveryTime: Date,
    distance: Number, // in kilometers
    earnings: {
        baseEarning: { type: Number, default: 0 },
        distanceBonus: { type: Number, default: 0 },
        timeBonus: { type: Number, default: 0 },
        totalEarning: { type: Number, default: 0 }
    }
}, {
    collection: 'orders',
    timestamps: true
});

const Order = mongoose.model('Order', OrderSchema);

// @desc    Get available orders for delivery partners
// @route   GET /api/delivery/orders/available
// @access  Private (Delivery Partner)
export const getAvailableOrders = async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;

        // Only show orders if delivery partner is online/available
        if (!deliveryPartner.isAvailable) {
            return res.json({
                success: true,
                message: 'Go online to see available orders',
                data: {
                    orders: []
                }
            });
        }

        // Get delivery partner's location for distance calculation
        const partnerLocation = deliveryPartner.currentLocation.coordinates || [0, 0];

        // Find orders that are ready for pickup and don't have a delivery partner
        const availableOrders = await Order.find({
            orderStatus: 'READY_FOR_PICKUP',
            deliveryPartnerId: { $exists: false }
        }).sort({ createdAt: -1 }).limit(20);

        // Calculate distance and earnings for each order
        const ordersWithDistance = availableOrders.map(order => {
            const restaurantCoords = order.restaurantCoords || [0, 0];
            const deliveryCoords = order.recipientCoords || [0, 0];

            // Simple distance calculation (you can use a more accurate formula)
            const distance = calculateDistance(
                partnerLocation[1], partnerLocation[0],
                restaurantCoords[1], restaurantCoords[0]
            ) + calculateDistance(
                restaurantCoords[1], restaurantCoords[0],
                deliveryCoords[1], deliveryCoords[0]
            );

            // Calculate estimated earnings
            const baseEarning = 3.00;
            const distanceBonus = distance * 0.50;
            const timeBonus = 1.00; // Fixed time bonus
            const totalEarning = baseEarning + distanceBonus + timeBonus;

            return {
                ...order.toObject(),
                distance: parseFloat(distance.toFixed(2)),
                estimatedEarnings: parseFloat(totalEarning.toFixed(2)),
                restaurantName: `Restaurant ${order.restaurantId.toString().slice(-4)}`,
                customerName: `Customer ${order.userId.toString().slice(-4)}`
            };
        });

        // Sort by distance (closest first)
        ordersWithDistance.sort((a, b) => a.distance - b.distance);

        res.json({
            success: true,
            data: {
                orders: ordersWithDistance,
                count: ordersWithDistance.length
            }
        });

        console.log(`📦 Delivered ${ordersWithDistance.length} available orders to ${deliveryPartner.name}`);

    } catch (error) {
        console.error('Get available orders error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch available orders',
            error: error.message
        });
    }
};

// @desc    Accept an order
// @route   POST /api/delivery/orders/:orderId/accept
// @access  Private (Delivery Partner)
export const acceptOrder = async (req, res) => {
    try {
        const { orderId } = req.params;
        const deliveryPartner = req.deliveryPartner;

        // Check if delivery partner is available
        if (!deliveryPartner.isAvailable) {
            return res.status(400).json({
                success: false,
                message: 'You must be online to accept orders'
            });
        }

        // Find the order
        const order = await Order.findById(orderId);
        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        // Check if order is available for pickup
        if (order.orderStatus !== 'READY_FOR_PICKUP') {
            return res.status(400).json({
                success: false,
                message: 'Order is not available for pickup'
            });
        }

        // Check if order already has a delivery partner
        if (order.deliveryPartnerId) {
            return res.status(400).json({
                success: false,
                message: 'Order has already been accepted by another partner'
            });
        }

        // Calculate earnings
        const partnerLocation = deliveryPartner.currentLocation.coordinates || [0, 0];
        const restaurantCoords = order.restaurantCoords || [0, 0];
        const deliveryCoords = order.recipientCoords || [0, 0];

        const distance = calculateDistance(
            partnerLocation[1], partnerLocation[0],
            restaurantCoords[1], restaurantCoords[0]
        ) + calculateDistance(
            restaurantCoords[1], restaurantCoords[0],
            deliveryCoords[1], deliveryCoords[0]
        );

        const baseEarning = 3.00;
        const distanceBonus = distance * 0.50;
        const timeBonus = 1.00;
        const totalEarning = baseEarning + distanceBonus + timeBonus;

        // Update order with delivery partner
        order.deliveryPartnerId = deliveryPartner._id;
        order.orderStatus = 'WITH_DELIVERY_PARTNER';
        order.deliveryPartnerLocation = partnerLocation;
        order.distance = distance;
        order.earnings = {
            baseEarning,
            distanceBonus,
            timeBonus,
            totalEarning
        };
        order.estimatedDeliveryTime = new Date(Date.now() + 30 * 60000); // 30 minutes from now

        await order.save();

        // Update delivery partner stats
        deliveryPartner.stats.totalDeliveries += 1;
        await deliveryPartner.save();

        // Emit real-time notification
        const io = getIO();
        io.emit('order_accepted', {
            orderId: order._id,
            deliveryPartnerId: deliveryPartner._id,
            deliveryPartnerName: deliveryPartner.name,
            estimatedDeliveryTime: order.estimatedDeliveryTime
        });

        res.json({
            success: true,
            message: 'Order accepted successfully',
            data: {
                order: {
                    ...order.toObject(),
                    restaurantName: `Restaurant ${order.restaurantId.toString().slice(-4)}`,
                    customerName: `Customer ${order.userId.toString().slice(-4)}`
                }
            }
        });

        console.log(`✅ Order ${orderId} accepted by ${deliveryPartner.name}`);

    } catch (error) {
        console.error('Accept order error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to accept order',
            error: error.message
        });
    }
};

// @desc    Mark order as picked up
// @route   POST /api/delivery/orders/:orderId/pickup
// @access  Private (Delivery Partner)
export const markOrderPickedUp = async (req, res) => {
    try {
        const { orderId } = req.params;
        const deliveryPartner = req.deliveryPartner;

        const order = await Order.findOne({
            _id: orderId,
            deliveryPartnerId: deliveryPartner._id
        });

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found or not assigned to you'
            });
        }

        if (order.orderStatus !== 'WITH_DELIVERY_PARTNER') {
            return res.status(400).json({
                success: false,
                message: 'Order is not ready for pickup confirmation'
            });
        }

        // Update order status
        order.orderStatus = 'WITH_DELIVERY_PARTNER';
        order.pickupTime = new Date();
        order.updatedAt = new Date();

        await order.save();

        // Emit real-time notification
        const io = getIO();
        io.emit('order_picked_up', {
            orderId: order._id,
            pickupTime: order.pickupTime,
            deliveryPartnerId: deliveryPartner._id
        });

        res.json({
            success: true,
            message: 'Order marked as picked up',
            data: { order }
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
};

// @desc    Mark order as delivered
// @route   POST /api/delivery/orders/:orderId/deliver
// @access  Private (Delivery Partner)
export const markOrderDelivered = async (req, res) => {
    try {
        const { orderId } = req.params;
        const deliveryPartner = req.deliveryPartner;

        const order = await Order.findOne({
            _id: orderId,
            deliveryPartnerId: deliveryPartner._id
        });

        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found or not assigned to you'
            });
        }

        if (order.orderStatus !== 'WITH_DELIVERY_PARTNER') {
            return res.status(400).json({
                success: false,
                message: 'Order is not ready for delivery confirmation'
            });
        }

        // Update order status
        order.orderStatus = 'DELIVERED';
        order.deliveryTime = new Date();
        order.actualDeliveryTime = new Date();
        order.updatedAt = new Date();

        await order.save();

        // Update delivery partner earnings and stats
        deliveryPartner.earnings.totalEarnings += order.earnings.totalEarning;
        deliveryPartner.earnings.todayEarnings += order.earnings.totalEarning;
        deliveryPartner.earnings.weeklyEarnings += order.earnings.totalEarning;
        deliveryPartner.earnings.monthlyEarnings += order.earnings.totalEarning;
        deliveryPartner.stats.completedDeliveries += 1;

        await deliveryPartner.save();

        // Emit real-time notification
        const io = getIO();
        io.emit('order_delivered', {
            orderId: order._id,
            deliveryTime: order.deliveryTime,
            deliveryPartnerId: deliveryPartner._id,
            earnings: order.earnings.totalEarning
        });

        res.json({
            success: true,
            message: 'Order delivered successfully',
            data: {
                order,
                earnings: order.earnings.totalEarning,
                newTotalEarnings: deliveryPartner.earnings.totalEarnings
            }
        });

        console.log(`🎉 Order ${orderId} delivered by ${deliveryPartner.name}. Earned: $${order.earnings.totalEarning}`);

    } catch (error) {
        console.error('Deliver order error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to mark order as delivered',
            error: error.message
        });
    }
};

// @desc    Get delivery partner's current orders
// @route   GET /api/delivery/orders/my-orders
// @access  Private (Delivery Partner)
export const getMyOrders = async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;

        const myOrders = await Order.find({
            deliveryPartnerId: deliveryPartner._id
        }).sort({ createdAt: -1 }).limit(50);

        const ordersWithDetails = myOrders.map(order => ({
            ...order.toObject(),
            restaurantName: `Restaurant ${order.restaurantId.toString().slice(-4)}`,
            customerName: `Customer ${order.userId.toString().slice(-4)}`
        }));

        res.json({
            success: true,
            data: {
                orders: ordersWithDetails,
                count: ordersWithDetails.length
            }
        });

    } catch (error) {
        console.error('Get my orders error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch your orders',
            error: error.message
        });
    }
};

// Helper function to calculate distance between two coordinates
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Radius of the Earth in kilometers
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const d = R * c; // Distance in kilometers
    return d;
}

// @desc    Update order status (for restaurants/admin)
// @route   PUT /api/delivery/orders/:orderId/status
// @access  Private (Admin/Restaurant)
export const updateOrderStatus = async (req, res) => {
    try {
        const { orderId } = req.params;
        const { status } = req.body;

        const validStatuses = ['PENDING', 'CONFIRMED', 'COOKING', 'READY_FOR_PICKUP', 'WITH_DELIVERY_PARTNER', 'DELIVERED', 'CANCELLED'];

        if (!validStatuses.includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid order status'
            });
        }

        const order = await Order.findById(orderId);
        if (!order) {
            return res.status(404).json({
                success: false,
                message: 'Order not found'
            });
        }

        order.orderStatus = status;
        order.updatedAt = new Date();

        await order.save();

        // Emit real-time notification
        const io = getIO();
        io.emit('order_status_update', {
            orderId: order._id,
            newStatus: status,
            updatedAt: order.updatedAt
        });

        res.json({
            success: true,
            message: 'Order status updated successfully',
            data: { order }
        });

        console.log(`📊 Order ${orderId} status updated to ${status}`);

    } catch (error) {
        console.error('Update order status error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update order status',
            error: error.message
        });
    }
};