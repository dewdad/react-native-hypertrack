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
    getUser(id) {
        return RNHyperTrack.getUser(id);
    },
    
    // get or create a new user
    getOrCreateUser(name, phoneNumber, uniqueId) {
        return RNHyperTrack.getOrCreateUser(name, phoneNumber, uniqueId);
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
    resumeTracking() {
        return RNHyperTrack.resumeTracking();
    },

    // stop tracking
    pauseTracking() {
        RNHyperTrack.pauseTracking();
    },

    // start mock tracking
    createMockAction(params) {
        RNHyperTrack.createMockAction(params);
    },

    // stop mock tracking
    completeMockAction(actionId) {
        RNHyperTrack.completeMockAction(actionId);
    },

    /**
     Action methods
    */
    // create and assign action
    createAction(actionParams) {
        // actionParams is a dictionary with following keys
        // expected_at: ISO datetime string
        // expected_place_id: uuid of expected place
        // expected_place: Place dictionary
        // lookup_id: string object for action lookup id
        // type: string object, that can be one of "visit", "pickup", "delivery"
        return RNHyperTrack.createAction(actionParams);
    },

    // get details of an action
    getAction(actionId) {
        return RNHyperTrack.getAction(actionId);
    },

    getActionForUniqueId(uniqueId) {
        return RNHyperTrack.getActionForUniqueId(uniqueId);
    },

    getActionForCollectionId(collectionId) {
        return RNHyperTrack.getActionForCollectionId(collectionId);
    },

    getActionForShortCode(shortCode) {
        return RNHyperTrack.getActionForShortCode(shortCode);
    },

    // Method to complete an action
    completeAction(actionId) {
        RNHyperTrack.completeAction(actionId);
    },

    //Method to complete action synchronously
    completeActionInSync(actionId){
        return RNHyperTrack.completeActionInSync(actionId);
    },

    //Method to complete action synchronously
    completeActionInSyncWithUniqueId(uniqueId){
        return RNHyperTrack.completeActionInSyncWithUniqueId(uniqueId);
    },

    /**
     Location Authorization (or Permission) methods
    */
    locationAuthorizationStatus() {
        return RNHyperTrack.locationAuthorizationStatus();
    },

    requestAlwaysLocationAuthorization(rationaleTitle, rationaleMessage) {
        RNHyperTrack.requestAlwaysLocationAuthorization(rationaleTitle, rationaleMessage);
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
    motionAuthorizationStatus() {
        RNHyperTrack.motionAuthorizationStatus();
    },

    requestMotionAuthorization() {
        RNHyperTrack.requestMotionAuthorization();
    },

    isActivityAvailable() {
        RNHyperTrack.isActivityAvailable();
    }

    updateUser(name, phoneNumber, uniqueId, image) {
        return RNHyperTrack.updateUser(name, phoneNumber, uniqueId, image);
    },

    getPlaceline(date, userId) {
        return RNHyperTrack.getPlaceline(date, userId);
    },

    getPendingActions() {
        return RNHyperTrack.getPendingActions();
    },

    /*
    iOS remote notification methods
    */
    registerForNotifications() {
        return RNHyperTrack.registerForNotifications();
    },

    didRegisterForRemoteNotificationsWithDeviceToken(token) {
        return RNHyperTrack.didRegisterForRemoteNotificationsWithDeviceToken(token);
    },

    didFailToRegisterForRemoteNotificationsWithError(error) {
        return RNHyperTrack.didFailToRegisterForRemoteNotificationsWithError(error);
    },

    didReceiveRemoteNotificationWithUserInfo(dict) {
        return RNHyperTrack.didReceiveRemoteNotificationWithUserInfo(dict);
    },

    isHyperTrackNotification(dict) {
        return RNHyperTrack.isHyperTrackNotification(dict);
    },

    getPendingActions() {
        return RNHyperTrack.getPendingActions();
    }
}