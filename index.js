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
    getPublishableKey(callback) {
        RNHyperTrack.getPublishableKey(callback);
    },

    /**
     Setup methods
    */

    // get or create a new user
    getOrCreateUser(name, phoneNumber, lookupId, successCallback, errorCallback) {
        RNHyperTrack.getOrCreateUser(name, phoneNumber, lookupId, successCallback, errorCallback);
    },

    // set a user with id
    setUserId(userId) {
        RNHyperTrack.setUserId(userId);
    },

    /**
     Util methods
    */

    // get current user id
    getUserId(callback) {
        RNHyperTrack.getUserId(callback);
    },

    // get tracking status
    isTracking(callback) {
        RNHyperTrack.isTracking(callback);
    },

    // Method to get eta to an expected location
    // Vehicle type can be "car", "bicycle", "van", "walking", "three-wheeler", "motorcycle"
    getETA(latitude, longitude, vehicleType, successCallback, errorCallback) {
        RNHyperTrack.getETA(latitude, longitude, vehicleType, successCallback, errorCallback)
    },

    // Method to get user's current location
    // Returns currentLocation as a Json, and error if location is 
    // disabled or permission denied
    getCurrentLocation(successCallback, errorCallback) {
        RNHyperTrack.getCurrentLocation(successCallback, errorCallback)
    },

    /**
     Basic integration methods
    */

    // start tracking
    startTracking(successCallback, errorCallback) {
        RNHyperTrack.startTracking(successCallback, errorCallback);
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
    createAndAssignAction(actionParams, successCallback, errorCallback) {
        // actionParams is a dictionary with following keys
        // expected_at: ISO datetime string
        // expected_place_id: uuid of expected place
        // lookup_id: string object for action lookup id
        // type: string object, that can be one of "visit", "pickup", "delivery"
        RNHyperTrack.createAndAssignAction(actionParams, successCallback, errorCallback);
    },

    // Method to assign action
    assignActions(actionIds, successCallback, errorCallback) {
        RNHyperTrack.assignActions(actionIds, successCallback, errorCallback)
    },

    // get details of an action
    getAction(actionId, successCallback, errorCallback) {
        RNHyperTrack.getAction(actionId, successCallback, errorCallback);
    },

    // Method to complete an action
    completeAction(actionId) {
        RNHyperTrack.completeAction(actionId);
    },

    /**
     Location Authorization (or Permission) methods
    */

    locationAuthorizationStatus(callback) {
        RNHyperTrack.locationAuthorizationStatus(callback);
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

    locationServicesEnabled(callback) {
        RNHyperTrack.locationServicesEnabled(callback);
    },

    requestLocationServices() {
        RNHyperTrack.requestLocationServices();
    },

    /**
     Motion Authorization methods (** For iOS only **)
    */

    canAskMotionPermissions(callback) {
        RNHyperTrack.canAskMotionPermissions(callback);
    },

    requstMotionAuthorization() {
        RNHyperTrack.requstMotionAuthorization();
    }
}