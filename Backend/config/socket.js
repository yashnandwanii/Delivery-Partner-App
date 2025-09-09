import jwt from 'jsonwebtoken';
import DeliveryPartner from '../models/DeliveryPartner.js';

let io;

export const initializeSocket = (socketIO) => {
    io = socketIO;

    // Middleware for socket authentication
    io.use(async (socket, next) => {
        try {
            const token = socket.handshake.auth.token || socket.handshake.headers.authorization?.replace('Bearer ', '');

            if (!token) {
                return next(new Error('Authentication error: No token provided'));
            }

            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            const deliveryPartner = await DeliveryPartner.findById(decoded.id).select('-password');

            if (!deliveryPartner) {
                return next(new Error('Authentication error: Delivery partner not found'));
            }

            socket.deliveryPartner = deliveryPartner;
            socket.join(`delivery:${deliveryPartner._id}`);

            console.log(`🔌 Delivery Partner connected: ${deliveryPartner.name} (${deliveryPartner._id})`);
            next();
        } catch (error) {
            console.error('Socket authentication error:', error.message);
            next(new Error('Authentication error'));
        }
    });

    io.on('connection', (socket) => {
        const { deliveryPartner } = socket;

        // Join delivery partner room
        socket.join(`delivery:${deliveryPartner._id}`);

        // Handle location updates
        socket.on('location:update', async (data) => {
            try {
                const { latitude, longitude, heading, speed } = data;

                // Update delivery partner location in database
                await DeliveryPartner.findByIdAndUpdate(deliveryPartner._id, {
                    currentLocation: {
                        type: 'Point',
                        coordinates: [longitude, latitude]
                    },
                    lastActiveAt: new Date(),
                    ...(heading !== undefined && { heading }),
                    ...(speed !== undefined && { speed })
                });

                // Broadcast location to relevant parties (customers, restaurants)
                socket.broadcast.emit('delivery:location_update', {
                    deliveryPartnerId: deliveryPartner._id,
                    location: {
                        latitude,
                        longitude,
                        heading,
                        speed
                    },
                    timestamp: new Date()
                });

                console.log(`📍 Location updated for ${deliveryPartner.name}: ${latitude}, ${longitude}`);
            } catch (error) {
                console.error('Error updating location:', error.message);
                socket.emit('error', { message: 'Failed to update location' });
            }
        });

        // Handle availability status changes
        socket.on('status:change', async (data) => {
            try {
                const { isAvailable } = data;

                await DeliveryPartner.findByIdAndUpdate(deliveryPartner._id, {
                    isAvailable,
                    lastActiveAt: new Date()
                });

                socket.broadcast.emit('delivery:status_change', {
                    deliveryPartnerId: deliveryPartner._id,
                    isAvailable,
                    timestamp: new Date()
                });

                console.log(`🔄 Status changed for ${deliveryPartner.name}: ${isAvailable ? 'Available' : 'Unavailable'}`);
            } catch (error) {
                console.error('Error updating status:', error.message);
                socket.emit('error', { message: 'Failed to update status' });
            }
        });

        // Handle order status updates
        socket.on('order:status_update', (data) => {
            const { orderId, status, customerId, restaurantId } = data;

            // Notify customer
            if (customerId) {
                io.to(`user:${customerId}`).emit('order:status_updated', {
                    orderId,
                    status,
                    deliveryPartnerId: deliveryPartner._id,
                    timestamp: new Date()
                });
            }

            // Notify restaurant
            if (restaurantId) {
                io.to(`restaurant:${restaurantId}`).emit('order:status_updated', {
                    orderId,
                    status,
                    deliveryPartnerId: deliveryPartner._id,
                    timestamp: new Date()
                });
            }

            console.log(`📦 Order ${orderId} status updated to: ${status}`);
        });

        // Handle disconnection
        socket.on('disconnect', async () => {
            try {
                await DeliveryPartner.findByIdAndUpdate(deliveryPartner._id, {
                    lastActiveAt: new Date()
                });

                console.log(`🔌 Delivery Partner disconnected: ${deliveryPartner.name}`);
            } catch (error) {
                console.error('Error on disconnect:', error.message);
            }
        });

        // Send welcome message
        socket.emit('connected', {
            message: 'Connected successfully',
            deliveryPartner: {
                id: deliveryPartner._id,
                name: deliveryPartner.name,
                isAvailable: deliveryPartner.isAvailable
            }
        });
    });
};

export const getIO = () => {
    if (!io) {
        throw new Error('Socket.IO not initialized');
    }
    return io;
};

export const emitToDeliveryPartner = (deliveryPartnerId, event, data) => {
    if (io) {
        io.to(`delivery:${deliveryPartnerId}`).emit(event, data);
    }
};

export const emitToUser = (userId, event, data) => {
    if (io) {
        io.to(`user:${userId}`).emit(event, data);
    }
};

export const emitToRestaurant = (restaurantId, event, data) => {
    if (io) {
        io.to(`restaurant:${restaurantId}`).emit(event, data);
    }
};

export default { initializeSocket, getIO, emitToDeliveryPartner, emitToUser, emitToRestaurant };
