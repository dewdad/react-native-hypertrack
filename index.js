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

    // create a new user
    createUser(name, successCallback, errorCallback) {
        RNHyperTrack.createUser(name, successCallback, errorCallback);
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
        // actionParams is a dictionary with keys
        RNHyperTrack.createAndAssignAction(actionParams, successCallback, errorCallback);
    },

    // Method to complete an action
    completeAction(actionId) {
        RNHyperTrack.completeAction(actionId);
    }
}