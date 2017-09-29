import { NativeModules } from 'react-native';

const { RNHyperTrack } = NativeModules;

module.exports = {

    /**
     Initialization methods
    */
    // Method to intialize the SDK with publishable key
    initialize(token) {
        RNHyperTrack.initialize(token);
    },

    // get active publishable key
    getPublishableKey() {
        return RNHyperTrack.getPublishableKey();
    },

    /**
     Setup methods
    */
    // get or create a new user
    getOrCreateUser(name, phoneNumber, lookupId) {
        return RNHyperTrack.getOrCreateUser(name, phoneNumber, lookupId);
    },

    // set a user with id
    setUserId(userId) {
        RNHyperTrack.setUserId(userId);
    },

    /**
     Util methods
    */
    // get current user id
    getUserId() {
        return RNHyperTrack.getUserId();
    },

    // get tracking status
    isTracking() {
        return RNHyperTrack.isTracking();
    },

    // Method to get eta to an expected location
    // Vehicle type can be "car", "bicycle", "van", "walking", "three-wheeler", "motorcycle"
    getETA(latitude, longitude, vehicleType) {
        return RNHyperTrack.getETA(latitude, longitude, vehicleType)
    },

    // Method to get user's current location
    // Returns currentLocation as a Json, and error if location is 
    // disabled or permission denied
    getCurrentLocation() {
        return RNHyperTrack.getCurrentLocation()
    },

    /**
     Basic integration methods
    */
    // start tracking
    startTracking() {
        return RNHyperTrack.startTracking();
    },

    // stop tracking
    stopTracking() {
        RNHyperTrack.stopTracking();
    },

    // start mock tracking
    startMockTracking() {
        RNHyperTrack.startMockTracking();
    },

    // stop mock tracking
    stopMockTracking() {
        RNHyperTrack.stopMockTracking();
    },

    /**
     Action methods
    */
    // create and assign action
    createAndAssignAction(actionParams) {
        // actionParams is a dictionary with following keys
        // expected_at: ISO datetime string
        // expected_place_id: uuid of expected place
        // lookup_id: string object for action lookup id
        // type: string object, that can be one of "visit", "pickup", "delivery"
        return RNHyperTrack.createAndAssignAction(actionParams);
    },

    // Method to assign action
    assignActions(actionIds) {
        return RNHyperTrack.assignActions(actionIds)
    },

    // get details of an action
    getAction(actionId) {
        return RNHyperTrack.getAction(actionId);
    },

    // Method to complete an action
    completeAction(actionId) {
        RNHyperTrack.completeAction(actionId);
    },

    /**
     Location Authorization (or Permission) methods
    */
    locationAuthorizationStatus() {
        return RNHyperTrack.locationAuthorizationStatus();
    },

    requestLocationWhenInUseAuthorization(rationaleTitle, rationaleMessage) {
        RNHyperTrack.requestWhenInUseAuthorization(rationaleTitle, rationaleMessage);
    },

    requestLocationAuthorization(rationaleTitle, rationaleMessage) {
        RNHyperTrack.requestLocationAuthorization(rationaleTitle, rationaleMessage);
    },

    /**
     Location services methods
    */
    locationServicesEnabled() {
        return RNHyperTrack.locationServicesEnabled();
    },

    requestLocationServices() {
        RNHyperTrack.requestLocationServices();
    },

    /**
     Motion Authorization methods (** For iOS only **)
    */
    canAskMotionPermissions() {
        RNHyperTrack.canAskMotionPermissions();
    },

    requestMotionAuthorization() {
        RNHyperTrack.requestMotionAuthorization();
    }
}