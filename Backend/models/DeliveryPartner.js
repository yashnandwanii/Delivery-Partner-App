import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const deliveryPartnerSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Name is required'],
        trim: true,
        minlength: [2, 'Name must be at least 2 characters long'],
        maxlength: [50, 'Name cannot exceed 50 characters']
    },
    email: {
        type: String,
        required: [true, 'Email is required'],
        unique: true,
        lowercase: true,
        trim: true,
        match: [/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/, 'Please enter a valid email']
    },
    phone: {
        type: String,
        required: [true, 'Phone number is required'],
        unique: true,
        trim: true,
        match: [/^\+?[\d\s-()]+$/, 'Please enter a valid phone number']
    },
    password: {
        type: String,
        required: [true, 'Password is required'],
        minlength: [6, 'Password must be at least 6 characters long'],
        select: false // Don't include password in queries by default
    },
    profileImage: {
        type: String,
        default: null
    },
    vehicleType: {
        type: String,
        required: [true, 'Vehicle type is required'],
        enum: ['bicycle', 'motorcycle', 'car', 'scooter', 'other'],
        default: 'motorcycle'
    },
    vehicleNumber: {
        type: String,
        required: [true, 'Vehicle number is required'],
        trim: true,
        uppercase: true
    },
    licenseNumber: {
        type: String,
        required: [true, 'License number is required'],
        trim: true,
        uppercase: true
    },
    isAvailable: {
        type: Boolean,
        default: true
    },
    isVerified: {
        type: Boolean,
        default: false
    },
    isActive: {
        type: Boolean,
        default: true
    },
    currentLocation: {
        type: {
            type: String,
            enum: ['Point'],
            default: 'Point'
        },
        coordinates: {
            type: [Number], // [longitude, latitude]
            default: [0, 0]
        }
    },
    address: {
        street: { type: String },
        city: { type: String },
        state: { type: String },
        zipCode: { type: String },
        country: { type: String, default: 'India' }
    },
    documents: {
        aadharCard: { type: String },
        panCard: { type: String },
        drivingLicense: { type: String },
        vehicleRC: { type: String }
    },
    bankDetails: {
        accountNumber: { type: String },
        ifscCode: { type: String },
        accountHolderName: { type: String },
        bankName: { type: String }
    },
    earnings: {
        totalEarnings: { type: Number, default: 0 },
        todayEarnings: { type: Number, default: 0 },
        weeklyEarnings: { type: Number, default: 0 },
        monthlyEarnings: { type: Number, default: 0 }
    },
    stats: {
        totalDeliveries: { type: Number, default: 0 },
        completedDeliveries: { type: Number, default: 0 },
        cancelledDeliveries: { type: Number, default: 0 },
        rating: { type: Number, default: 0, min: 0, max: 5 },
        totalRatings: { type: Number, default: 0 }
    },
    workingHours: {
        startTime: { type: String, default: '09:00' },
        endTime: { type: String, default: '21:00' },
        isWorking: { type: Boolean, default: false }
    },
    fcmTokens: [String],
    lastActiveAt: {
        type: Date,
        default: Date.now
    },
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

// Create 2dsphere index for location-based queries
deliveryPartnerSchema.index({ currentLocation: '2dsphere' });
deliveryPartnerSchema.index({ email: 1 });
deliveryPartnerSchema.index({ phone: 1 });
deliveryPartnerSchema.index({ isAvailable: 1, isActive: 1 });

// Virtual for average rating
deliveryPartnerSchema.virtual('averageRating').get(function () {
    if (this.stats.totalRatings === 0) return 0;
    return (this.stats.rating / this.stats.totalRatings).toFixed(1);
});

// Pre-save middleware to hash password
deliveryPartnerSchema.pre('save', async function (next) {
    // Only hash password if it's modified
    if (!this.isModified('password')) return next();

    try {
        const salt = await bcrypt.genSalt(12);
        this.password = await bcrypt.hash(this.password, salt);
        next();
    } catch (error) {
        next(error);
    }
});

// Method to compare password
deliveryPartnerSchema.methods.comparePassword = async function (candidatePassword) {
    try {
        return await bcrypt.compare(candidatePassword, this.password);
    } catch (error) {
        throw new Error('Password comparison failed');
    }
};

// Method to update location
deliveryPartnerSchema.methods.updateLocation = async function (longitude, latitude) {
    this.currentLocation = {
        type: 'Point',
        coordinates: [longitude, latitude]
    };
    this.lastActiveAt = new Date();
    return await this.save();
};

// Method to update availability
deliveryPartnerSchema.methods.updateAvailability = async function (isAvailable) {
    this.isAvailable = isAvailable;
    this.lastActiveAt = new Date();
    return await this.save();
};

// Method to add earnings
deliveryPartnerSchema.methods.addEarnings = async function (amount) {
    this.earnings.totalEarnings += amount;
    this.earnings.todayEarnings += amount;
    this.earnings.weeklyEarnings += amount;
    this.earnings.monthlyEarnings += amount;
    return await this.save();
};

// Method to update stats
deliveryPartnerSchema.methods.updateStats = async function (type, rating = null) {
    this.stats.totalDeliveries += 1;

    if (type === 'completed') {
        this.stats.completedDeliveries += 1;
        if (rating) {
            this.stats.rating += rating;
            this.stats.totalRatings += 1;
        }
    } else if (type === 'cancelled') {
        this.stats.cancelledDeliveries += 1;
    }

    return await this.save();
};

// Static method to find nearby delivery partners
deliveryPartnerSchema.statics.findNearby = function (longitude, latitude, maxDistance = 5000) {
    return this.find({
        isAvailable: true,
        isActive: true,
        isVerified: true,
        currentLocation: {
            $near: {
                $geometry: {
                    type: 'Point',
                    coordinates: [longitude, latitude]
                },
                $maxDistance: maxDistance // in meters
            }
        }
    }).select('-password');
};

// Static method to get delivery partner with basic info
deliveryPartnerSchema.statics.getBasicInfo = function (id) {
    return this.findById(id).select('name email phone profileImage vehicleType vehicleNumber rating isAvailable currentLocation');
};

const DeliveryPartner = mongoose.model('DeliveryPartner', deliveryPartnerSchema);

export default DeliveryPartner;
