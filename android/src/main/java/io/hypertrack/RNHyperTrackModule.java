
package io.hypertrack;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.location.Location;
import android.support.annotation.NonNull;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.android.gms.maps.model.LatLng;
import com.google.gson.GsonBuilder;
import com.hypertrack.lib.HyperTrack;
import com.hypertrack.lib.HyperTrackConstants;
import com.hypertrack.lib.callbacks.HyperTrackCallback;
import com.hypertrack.lib.internal.common.models.VehicleType;
import com.hypertrack.lib.internal.common.util.DateTimeUtility;
import com.hypertrack.lib.internal.transmitter.models.UserActivity;
import com.hypertrack.lib.models.Action;
import com.hypertrack.lib.models.ActionParamsBuilder;
import com.hypertrack.lib.models.ErrorResponse;
import com.hypertrack.lib.models.GeoJSONLocation;
import com.hypertrack.lib.models.HyperTrackLocation;
import com.hypertrack.lib.models.Place;
import com.hypertrack.lib.models.SuccessResponse;
import com.hypertrack.lib.models.User;
import com.hypertrack.lib.models.UserParams;

import java.util.ArrayList;
import java.util.List;

public class RNHyperTrackModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    private static final String TAG = RNHyperTrackModule.class.getSimpleName();
    private final ReactApplicationContext reactContext;

    public RNHyperTrackModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        reactContext.addLifecycleEventListener(this);
    }

    @Override
    public String getName() {
        return "RNHyperTrack";
    }

    /**
     * HyperTrackEvent methods
     **/

    private void sendEvent(String eventName, WritableMap params) {
        getReactApplicationContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    private void sendLocationChangedEvent(HyperTrackLocation hyperTrackLocation) {
        // Send this event to js
        GeoJSONLocation geojson = hyperTrackLocation.getGeoJSONLocation();
        String serializedGeojson = new GsonBuilder().create().toJson(geojson);
        WritableMap params = Arguments.createMap();
        params.putString("geojson", serializedGeojson);
        Log.d(TAG, "sendLocationChangedEvent: " + serializedGeojson);
        sendEvent("location.changed", params);
    }

    private void sendCurrentActivityEvent(UserActivity userActivity) {
        String serializedUserActivityJson = new GsonBuilder().create().toJson(userActivity);
        WritableMap params = Arguments.createMap();
        params.putString("activity", serializedUserActivityJson);
        Log.d(TAG, "sendCurrentActivityEvent: " + serializedUserActivityJson);
        sendEvent("activity.changed", params);
    }

    /**
     * Initialization methods
     **/

    @ReactMethod
    public void initialize(String publishableKey) {
        HyperTrack.initialize(getReactApplicationContext(), publishableKey);
        HyperTrack.enableDebugLogging(Log.ASSERT);
    }

    @ReactMethod
    public void getPublishableKey(final Promise promise) {
        Context context = getReactApplicationContext();
        // callback.invoke(HyperTrack.getPublishableKey(context));
        promise.resolve(HyperTrack.getPublishableKey(context));
    }

    /**
     * Setup methods
     **/

    @ReactMethod
    public void getOrCreateUser(String userName, String phoneNumber, String lookupId, final Promise promise) {
        UserParams userParams = new UserParams();
        userParams.setName(userName).setPhone(phoneNumber).setLookupId(lookupId);
        HyperTrack.getOrCreateUser(userParams, new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Return User object in successCallback
                User user = (User) response.getResponseObject();
                String serializedUser = new GsonBuilder().create().toJson(user);
                // successCallback.invoke(serializedUser);
                promise.resolve(serializedUser);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                // errorCallback.invoke(serializedError);
                promise.reject(serializedError);
            }
        });
    }

    @ReactMethod
    public void setUserId(String userId) {
        HyperTrack.setUserId(userId);
    }

    /**
     * Location permission methods
     **/

    @ReactMethod
    public void locationAuthorizationStatus(final Promise promise) {
        // callback.invoke(HyperTrack.checkLocationPermission(reactContext));
        promise.resolve(HyperTrack.checkLocationPermission(reactContext));
    }

    @ReactMethod
    public void requestWhenInUseAuthorization(String rationaleTitle, String rationaleMessage) {
        HyperTrack.requestPermissions(getCurrentActivity(), rationaleTitle, rationaleMessage);
    }

    @ReactMethod
    public void requestLocationAuthorization(String rationaleTitle, String rationaleMessage) {
        HyperTrack.requestPermissions(getCurrentActivity(), rationaleTitle, rationaleMessage);
    }

    /**
     * Location services methods
     **/

    @ReactMethod
    public void locationServicesEnabled(final Promise promise) {
        // callback.invoke(HyperTrack.checkLocationServices(reactContext));
        promise.resolve(HyperTrack.checkLocationServices(reactContext));
    }

    @ReactMethod
    public void requestLocationServices() {
        HyperTrack.requestLocationServices(getCurrentActivity());
    }

    /**
     * Util methods
     **/

    @ReactMethod
    public void getUserId(Promise promise) {
        // callback.invoke(HyperTrack.getUserId());
        promise.resolve(HyperTrack.getUserId());
    }

    @ReactMethod
    public void isTracking(Promise promise) {
        // callback.invoke(HyperTrack.isTracking());
        promise.resolve(HyperTrack.isTracking());
    }

    @ReactMethod
    public void getETA(final double expectedPlaceLat, final double expectedPlaceLng, final String vehicleType, final Promise promise) {
        LatLng expectedLocation = new LatLng(expectedPlaceLat, expectedPlaceLng);
        VehicleType vType = VehicleType.valueOf(vehicleType.toUpperCase());

        HyperTrack.getETA(expectedLocation, vType, new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Handle getETA API success here
                Double eta = (Double) response.getResponseObject();
                // successCallback.invoke(eta);
                promise.resolve(eta);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                // Handle getETA API error here
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                // errorCallback.invoke(serializedError);
                promise.reject(serializedError);
            }
        });
    }

    @ReactMethod
    public void getCurrentLocation(final Promise promise) {
        HyperTrack.getCurrentLocation(new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Handle getCurrentLocation API success here
                Location location = (Location) response.getResponseObject();

                WritableMap locationMap = Arguments.createMap();
                locationMap.putDouble("latitude", location.getLatitude());
                locationMap.putDouble("longitude", location.getLongitude());
                locationMap.putString("provider", location.getProvider());
                locationMap.putDouble("speed", (double) location.getSpeed());
                locationMap.putDouble("accuracy", (double) location.getAccuracy());
                locationMap.putDouble("bearing", (double) location.getBearing());
                locationMap.putDouble("altitude", location.getAltitude());

                // successCallback.invoke(locationMap);
                promise.resolve(locationMap);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                // Handle getETA API error here
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                // errorCallback.invoke(serializedError);
                promise.reject(serializedError);
            }
        });
    }

    /**
     * Basic integration methods
     **/

    @ReactMethod
    public void startTracking(final Promise promise) {
        HyperTrack.startTracking(new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Return User object in successCallback
                String userId = (String) response.getResponseObject();
                // successCallback.invoke(userId);
                promise.resolve(userId);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                // errorCallback.invoke(serializedError);
                promise.reject(serializedError);
            }
        });
    }

    @ReactMethod
    public void stopTracking() {
        HyperTrack.stopTracking();
    }

    @ReactMethod
    public void startMockTracking(final Promise promise) {
        HyperTrack.startMockTracking(
                new HyperTrackCallback() {
                    @Override
                    public void onSuccess(@NonNull SuccessResponse response) {

                    }

                    @Override
                    public void onError(@NonNull ErrorResponse errorResponse) {

                    }
                }
        );
    }

    @ReactMethod
    public void stopMockTracking() {
        HyperTrack.stopMockTracking();
    }

    /**
     * Action methods
     **/

    @ReactMethod
    public void createAndAssignAction(ReadableMap params, final Promise promise) {
        ActionParamsBuilder actionParamsBuilder = new ActionParamsBuilder();

        if (params.hasKey("expected_place_id")) {
            actionParamsBuilder.setExpectedPlaceId(params.getString("expected_place_id"));
        }

        if (params.hasKey("lookup_id")) {
            actionParamsBuilder.setLookupId(params.getString("lookup_id"));
        }

        if (params.hasKey("type")) {
            actionParamsBuilder.setType(params.getString("type"));
        }

        if (params.hasKey("expected_at")) {
            actionParamsBuilder.setExpectedAt(DateTimeUtility.getFormattedDate(params.getString("expected_at")));
        }

        if (params.hasKey("collection_id")) {
            actionParamsBuilder.setCollectionId(params.getString("collection_id"));
        }

        if (params.hasKey("expected_place")) {
            Place place = getPlaceObject(params.getMap("expected_place"));

            actionParamsBuilder.setExpectedPlace(place);
        }

        HyperTrack.createAndAssignAction(actionParamsBuilder.build(), new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Return Action object in successCallback
                Action action = (Action) response.getResponseObject();
                String serializedAction = new GsonBuilder().create().toJson(action);
                // successCallback.invoke(serializedAction);
                promise.resolve(serializedAction);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                // errorCallback.invoke(serializedError);
                promise.reject(serializedError);
            }
        });
    }

    private Place getPlaceObject(ReadableMap expectedPlaceParams) {
        Place place = new Place();
        if (expectedPlaceParams.hasKey("name"))
            place.setName(expectedPlaceParams.getString("name"));
        if (expectedPlaceParams.hasKey("address"))
            place.setAddress(expectedPlaceParams.getString("address"));
        if (expectedPlaceParams.hasKey("locality"))
            place.setLocality(expectedPlaceParams.getString("locality"));
        if (expectedPlaceParams.hasKey("landmark"))
            place.setLandmark(expectedPlaceParams.getString("landmark"));
        if (expectedPlaceParams.hasKey("zip_code"))
            place.setZipCode(expectedPlaceParams.getString("zip_code"));
        if (expectedPlaceParams.hasKey("city"))
            place.setCity(expectedPlaceParams.getString("city"));
        if (expectedPlaceParams.hasKey("state"))
            place.setState(expectedPlaceParams.getString("state"));
        if (expectedPlaceParams.hasKey("country"))
            place.setCountry(expectedPlaceParams.getString("country"));
        if (expectedPlaceParams.hasKey("location")) {
            LatLng latLng = getGeoJsonObject(expectedPlaceParams.getMap("location"));
            place.setLocation(new GeoJSONLocation(latLng));
        }
        return place;
    }

    private LatLng getGeoJsonObject(ReadableMap location) {
        if (location.hasKey("coordinates")) {
            ReadableArray coordinates = location.getArray("coordinates");
            LatLng latLng = new LatLng(coordinates.getDouble(0), coordinates.getDouble(1));
            return latLng;
        } else return null;
    }

    @ReactMethod
    public void assignActions(final ReadableArray actionIds, final Promise promise) {
        List<String> actionIdsStrings = new ArrayList<String>();

        for (int i = 0; i < actionIds.size(); i++) {
            actionIdsStrings.add(actionIds.getString(i));
        }

        HyperTrack.assignActions(actionIdsStrings, new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Return User object in successCallback
                User user = (User) response.getResponseObject();
                String serializedUser = new GsonBuilder().create().toJson(user);
                // successCallback.invoke(serializedUser);
                promise.resolve(serializedUser);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                // Handle getETA API error here
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                // errorCallback.invoke(serializedError);
                promise.reject(serializedError);
            }
        });
    }

    @ReactMethod
    public void getAction(String actionId, final Promise promise) {
        HyperTrack.getAction(actionId, new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Handle getAction response here
                Action actionResponse = (Action) response.getResponseObject();
                String serializedAction = new GsonBuilder().create().toJson(actionResponse);
                // successCallback.invoke(serializedAction);
                promise.resolve(serializedAction);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                // Handle getAction error here
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                // errorCallback.invoke(serializedError);
                promise.reject(serializedError);
            }
        });
    }

    @ReactMethod
    public void completeAction(String actionId) {
        HyperTrack.completeAction(actionId);
    }

    @ReactMethod
    public void completeActionInSync(String actionId, final Promise promise) {
        HyperTrack.completeActionInSync(actionId, new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Handle getAction response here
                Action actionResponse = (Action) response.getResponseObject();
                String serializedAction = new GsonBuilder().create().toJson(actionResponse);
                // successCallback.invoke(serializedAction);
                promise.resolve(serializedAction);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                // Handle getAction error here
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                // errorCallback.invoke(serializedError);
                promise.reject(serializedError);
            }
        });
    }

    @ReactMethod
    public void completeActionWithLookupId(String lookupId) {
        HyperTrack.completeActionWithLookupId(lookupId);
    }

    @ReactMethod
    public void completeActionWithLookupIdInSync(String lookupId, final Promise promise) {
        HyperTrack.completeActionWithLookupIdInSync(lookupId, new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Handle getAction response here
                Action actionResponse = (Action) response.getResponseObject();
                String serializedAction = new GsonBuilder().create().toJson(actionResponse);
                // successCallback.invoke(serializedAction);
                promise.resolve(serializedAction);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                // Handle getAction error here
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                // errorCallback.invoke(serializedError);
                promise.reject(serializedError);
            }
        });
    }

    @Override
    public void onHostDestroy() {
        Log.d(TAG, "onHostDestroy: ");
    }


    @Override
    public void onHostPause() {
        Log.d(TAG, "onHostPause: ");
        unRegisterBroadcastReceiver();
    }

    @Override
    public void onHostResume() {
        Log.d(TAG, "onHostResume: ");
        registerBroadcastReceiver();
    }

    private void registerBroadcastReceiver() {
        Log.d(TAG, "registerBroadcastReceiver: ");
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(HyperTrackConstants.HT_USER_CURRENT_ACTIVITY_INTENT);
        intentFilter.addAction(HyperTrackConstants.HT_USER_CURRENT_LOCATION_INTENT);
        LocalBroadcastManager.getInstance(reactContext).registerReceiver(mMessageReceiver, intentFilter);
    }

    private void unRegisterBroadcastReceiver() {
        Log.d(TAG, "unRegisterBroadcastReceiver: ");
        LocalBroadcastManager.getInstance(reactContext).unregisterReceiver(mMessageReceiver);
    }

    private BroadcastReceiver mMessageReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent != null && intent.getAction() != null) {
                if (intent.getAction().equals(HyperTrackConstants.HT_USER_CURRENT_ACTIVITY_INTENT)) {
                    UserActivity userActivity = (UserActivity) intent.getSerializableExtra(HyperTrackConstants.HT_USER_CURRENT_ACTIVITY_KEY);
                    sendCurrentActivityEvent(userActivity);
                }
                if (intent.getAction().equals(HyperTrackConstants.HT_USER_CURRENT_LOCATION_INTENT)) {
                    HyperTrackLocation hyperTrackLocation = (HyperTrackLocation) intent.getSerializableExtra(HyperTrackConstants.HT_USER_CURRENT_LOCATION_KEY);
                    sendLocationChangedEvent(hyperTrackLocation);
                }
            }
        }
    };

}