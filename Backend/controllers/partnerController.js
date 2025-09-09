import DeliveryPartner from '../models/DeliveryPartner.js';
import { getIO } from '../config/socket.js';

// @desc    Toggle delivery partner availability (Go Online/Offline)
// @route   PUT /api/delivery/partner/status
// @access  Private (Delivery Partner)
export const toggleAvailability = async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;
        const { status } = req.body;

        // Validate status
        if (!['online', 'offline'].includes(status)) {
            return res.status(400).json({
                success: false,
                message: 'Status must be either "online" or "offline"'
            });
        }

        // Update delivery partner availability
        deliveryPartner.isAvailable = status === 'online';
        deliveryPartner.lastActiveAt = new Date();

        // Update working hours status
        if (status === 'online') {
            deliveryPartner.workingHours.isWorking = true;
        } else {
            deliveryPartner.workingHours.isWorking = false;
        }

        await deliveryPartner.save();

        // Emit real-time status update
        const io = getIO();
        io.emit('delivery_partner_status_update', {
            deliveryPartnerId: deliveryPartner._id,
            isAvailable: deliveryPartner.isAvailable,
            status: status,
            timestamp: new Date()
        });

        res.json({
            success: true,
            message: `Successfully went ${status}`,
            data: {
                deliveryPartner: {
                    _id: deliveryPartner._id,
                    name: deliveryPartner.name,
                    isAvailable: deliveryPartner.isAvailable,
                    status: status,
                    lastActiveAt: deliveryPartner.lastActiveAt
                }
            }
        });

        console.log(`🔄 ${deliveryPartner.name} is now ${status}`);

    } catch (error) {
        console.error('Toggle availability error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update status',
            error: error.message
        });
    }
};

// @desc    Update delivery partner location
// @route   POST /api/delivery/location
// @access  Private (Delivery Partner)
export const updateLocation = async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;
        const { latitude, longitude } = req.body;

        if (!latitude || !longitude) {
            return res.status(400).json({
                success: false,
                message: 'Latitude and longitude are required'
            });
        }

        // Update location
        deliveryPartner.currentLocation = {
            type: 'Point',
            coordinates: [longitude, latitude] // GeoJSON format: [lng, lat]
        };
        deliveryPartner.lastActiveAt = new Date();

        await deliveryPartner.save();

        // Emit real-time location update
        const io = getIO();
        io.emit('delivery_partner_location_update', {
            deliveryPartnerId: deliveryPartner._id,
            location: {
                latitude,
                longitude
            },
            timestamp: new Date()
        });

        res.json({
            success: true,
            message: 'Location updated successfully',
            data: {
                location: {
                    latitude,
                    longitude
                }
            }
        });

    } catch (error) {
        console.error('Update location error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to update location',
            error: error.message
        });
    }
};

// @desc    Get delivery partner profile
// @route   GET /api/delivery/partner/profile
// @access  Private (Delivery Partner)
export const getProfile = async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;

        res.json({
            success: true,
            data: {
                deliveryPartner
            }
        });

    } catch (error) {
        console.error('Get profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch profile',
            error: error.message
        });
    }
};

// @desc    Get delivery partner earnings
// @route   GET /api/delivery/partner/earnings
// @access  Private (Delivery Partner)
export const getEarnings = async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;

        // You can add more detailed earnings calculation here
        const earnings = {
            today: deliveryPartner.earnings.todayEarnings,
            weekly: deliveryPartner.earnings.weeklyEarnings,
            monthly: deliveryPartner.earnings.monthlyEarnings,
            total: deliveryPartner.earnings.totalEarnings
        };

        res.json({
            success: true,
            data: {
                earnings,
                stats: deliveryPartner.stats
            }
        });

    } catch (error) {
        console.error('Get earnings error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch earnings',
            error: error.message
        });
    }
};

// @desc    Get delivery partner statistics
// @route   GET /api/delivery/partner/stats
// @access  Private (Delivery Partner)
export const getStats = async (req, res) => {
    try {
        const deliveryPartner = req.deliveryPartner;

        const stats = {
            totalDeliveries: deliveryPartner.stats.totalDeliveries,
            completedDeliveries: deliveryPartner.stats.completedDeliveries,
            cancelledDeliveries: deliveryPartner.stats.cancelledDeliveries,
            rating: deliveryPartner.stats.rating,
            totalRatings: deliveryPartner.stats.totalRatings,
            averageRating: deliveryPartner.averageRating || 0
        };

        res.json({
            success: true,
            data: {
                stats
            }
        });

    } catch (error) {
        console.error('Get stats error:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to fetch statistics',
            error: error.message
        });
    }
};
