import { NativeModules } from 'react-native';

const { RNHyperTrack } = NativeModules;

module.exports = {
    // Method to intialize the SDK with publishable key
    initialize(token) {
        RNHyperTrack.initialize(token);
    },

    // get active publishable key
    getPublishableKey(callback) {
        RNHyperTrack.getPublishableKey(callback);
    },

    // get or create a new user
    getOrCreateUser(name, phoneNumber, lookupId, successCallback, errorCallback) {
        RNHyperTrack.getOrCreateUser(name, phoneNumber, lookupId, successCallback, errorCallback);
    },

    // set a user with id
    setUserId(userId) {
        RNHyperTrack.setUserId(userId);
    },

    // get current user id
    getUserId(callback) {
        RNHyperTrack.getUserId(callback);
    },

    // start tracking
    startTracking(successCallback, errorCallback) {
        RNHyperTrack.startTracking(successCallback, errorCallback);
    },

    // start tracking
    stopTracking() {
        RNHyperTrack.stopTracking();
    },

    // get tracking status
    isTracking(callback) {
        RNHyperTrack.isTracking(callback);
    },

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

    // Method to get eta to an expected location
    // Vehicle type can be "car", "bicycle", "van"
    getETA(latitude, longitude, vehicleType, successCallback, errorCallback) {
        RNHyperTrack.getETA(latitude, longitude, vehicleType, successCallback, errorCallback)
    }
}