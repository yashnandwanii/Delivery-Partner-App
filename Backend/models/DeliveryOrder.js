import mongoose from 'mongoose';

const orderItemSchema = new mongoose.Schema({
    foodId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Food',
        required: true
    },
    name: {
        type: String,
        required: true
    },
    price: {
        type: Number,
        required: true
    },
    quantity: {
        type: Number,
        required: true,
        min: 1
    },
    specialInstructions: {
        type: String,
        default: ''
    }
});

const deliveryOrderSchema = new mongoose.Schema({
    orderId: {
        type: String,
        required: true,
        unique: true
    },
    customerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    restaurantId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Restaurant',
        required: true
    },
    deliveryPartnerId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'DeliveryPartner',
        default: null
    },

    // Order Details
    items: [orderItemSchema],
    orderTotal: {
        type: Number,
        required: true
    },
    deliveryFee: {
        type: Number,
        required: true,
        default: 0
    },
    taxes: {
        type: Number,
        default: 0
    },
    discount: {
        type: Number,
        default: 0
    },
    grandTotal: {
        type: Number,
        required: true
    },

    // Addresses
    restaurantAddress: {
        street: String,
        city: String,
        state: String,
        zipCode: String,
        coordinates: {
            type: [Number], // [longitude, latitude]
            required: true
        }
    },
    deliveryAddress: {
        street: String,
        city: String,
        state: String,
        zipCode: String,
        coordinates: {
            type: [Number], // [longitude, latitude]
            required: true
        },
        apartmentNumber: String,
        landmark: String,
        instructions: String
    },

    // Status and Timing
    orderStatus: {
        type: String,
        enum: [
            'pending',           // Order placed by customer
            'confirmed',         // Restaurant confirmed
            'preparing',         // Restaurant is preparing
            'ready_for_pickup',  // Ready for delivery partner
            'assigned',          // Assigned to delivery partner
            'picked_up',         // Picked up by delivery partner
            'out_for_delivery',  // On the way to customer
            'delivered',         // Successfully delivered
            'cancelled',         // Order cancelled
            'refunded'          // Order refunded
        ],
        default: 'pending'
    },
    deliveryStatus: {
        type: String,
        enum: [
            'not_assigned',
            'assigned',
            'heading_to_restaurant',
            'at_restaurant',
            'picked_up',
            'heading_to_customer',
            'delivered'
        ],
        default: 'not_assigned'
    },

    // Payment
    paymentMethod: {
        type: String,
        enum: ['cash', 'card', 'upi', 'wallet'],
        required: true
    },
    paymentStatus: {
        type: String,
        enum: ['pending', 'paid', 'failed', 'refunded'],
        default: 'pending'
    },
    isPaid: {
        type: Boolean,
        default: false
    },

    // Delivery Details
    estimatedDeliveryTime: {
        type: Date
    },
    actualDeliveryTime: {
        type: Date
    },
    deliveryInstructions: {
        type: String
    },
    contactlessDelivery: {
        type: Boolean,
        default: false
    },

    // Tracking
    timeline: [{
        status: String,
        timestamp: {
            type: Date,
            default: Date.now
        },
        updatedBy: {
            type: String,
            enum: ['customer', 'restaurant', 'delivery_partner', 'system']
        },
        notes: String
    }],

    // Communication
    customerPhone: String,
    restaurantPhone: String,

    // Delivery Partner Earnings
    deliveryEarnings: {
        baseFee: { type: Number, default: 0 },
        distanceBonus: { type: Number, default: 0 },
        timeBonus: { type: Number, default: 0 },
        tip: { type: Number, default: 0 },
        total: { type: Number, default: 0 }
    },

    // Rating and Feedback
    customerRating: {
        rating: { type: Number, min: 1, max: 5 },
        review: String,
        timestamp: Date
    },

    // Distance and Time
    distanceFromRestaurant: Number, // in meters
    distanceToCustomer: Number, // in meters
    estimatedPickupTime: Date,
    actualPickupTime: Date,

    // Special Flags
    isUrgent: {
        type: Boolean,
        default: false
    },
    isReturned: {
        type: Boolean,
        default: false
    },

    // Metadata
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
}, {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
});

// Indexes
deliveryOrderSchema.index({ orderId: 1 });
deliveryOrderSchema.index({ customerId: 1 });
deliveryOrderSchema.index({ restaurantId: 1 });
deliveryOrderSchema.index({ deliveryPartnerId: 1 });
deliveryOrderSchema.index({ orderStatus: 1 });
deliveryOrderSchema.index({ deliveryStatus: 1 });
deliveryOrderSchema.index({ createdAt: -1 });
deliveryOrderSchema.index({ 'restaurantAddress.coordinates': '2dsphere' });
deliveryOrderSchema.index({ 'deliveryAddress.coordinates': '2dsphere' });

// Virtual for delivery duration
deliveryOrderSchema.virtual('deliveryDuration').get(function () {
    if (this.actualDeliveryTime && this.actualPickupTime) {
        return Math.round((this.actualDeliveryTime - this.actualPickupTime) / (1000 * 60)); // in minutes
    }
    return null;
});

// Virtual for total duration
deliveryOrderSchema.virtual('totalDuration').get(function () {
    if (this.actualDeliveryTime && this.createdAt) {
        return Math.round((this.actualDeliveryTime - this.createdAt) / (1000 * 60)); // in minutes
    }
    return null;
});

// Method to add timeline entry
deliveryOrderSchema.methods.addToTimeline = function (status, updatedBy, notes = '') {
    this.timeline.push({
        status,
        updatedBy,
        notes,
        timestamp: new Date()
    });
    return this;
};

// Method to update order status
deliveryOrderSchema.methods.updateStatus = async function (newStatus, updatedBy, notes = '') {
    this.orderStatus = newStatus;
    this.addToTimeline(newStatus, updatedBy, notes);
    this.updatedAt = new Date();

    // Update delivery status based on order status
    if (newStatus === 'assigned') {
        this.deliveryStatus = 'assigned';
    } else if (newStatus === 'picked_up') {
        this.deliveryStatus = 'picked_up';
        this.actualPickupTime = new Date();
    } else if (newStatus === 'out_for_delivery') {
        this.deliveryStatus = 'heading_to_customer';
    } else if (newStatus === 'delivered') {
        this.deliveryStatus = 'delivered';
        this.actualDeliveryTime = new Date();
    }

    return await this.save();
};

// Static method to find nearby orders for delivery partners
deliveryOrderSchema.statics.findAvailableOrders = function (longitude, latitude, maxDistance = 10000) {
    return this.find({
        orderStatus: 'ready_for_pickup',
        deliveryPartnerId: null,
        'restaurantAddress.coordinates': {
            $near: {
                $geometry: {
                    type: 'Point',
                    coordinates: [longitude, latitude]
                },
                $maxDistance: maxDistance
            }
        }
    })
        .populate('restaurantId', 'name phone address')
        .populate('customerId', 'name phone')
        .sort({ createdAt: 1 });
};

// Static method to find orders by delivery partner
deliveryOrderSchema.statics.findByDeliveryPartner = function (deliveryPartnerId, status = null) {
    const query = { deliveryPartnerId };
    if (status) {
        query.orderStatus = status;
    }

    return this.find(query)
        .populate('restaurantId', 'name phone address')
        .populate('customerId', 'name phone')
        .sort({ createdAt: -1 });
};

const DeliveryOrder = mongoose.model('DeliveryOrder', deliveryOrderSchema);

export default DeliveryOrder;
