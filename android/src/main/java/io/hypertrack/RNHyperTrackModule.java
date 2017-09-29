
package io.hypertrack;

import android.widget.Toast;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.location.Location;
import android.os.Bundle;
import android.support.annotation.NonNull;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.Promise;

import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

import com.hypertrack.lib.HyperTrack;
import com.hypertrack.lib.HyperTrackConstants;
import com.hypertrack.lib.callbacks.HyperTrackCallback;
import com.hypertrack.lib.callbacks.HyperTrackEventCallback;
import com.hypertrack.lib.internal.transmitter.models.HyperTrackEvent;
import com.hypertrack.lib.internal.common.util.DateTimeUtility;
import com.hypertrack.lib.internal.common.models.VehicleType;
import com.hypertrack.lib.models.Place;
import com.hypertrack.lib.models.Action;
import com.hypertrack.lib.models.GeoJSONLocation;
import com.hypertrack.lib.models.ActionParams;
import com.hypertrack.lib.models.ActionParamsBuilder;
import com.hypertrack.lib.models.ErrorResponse;
import com.hypertrack.lib.models.SuccessResponse;
import com.hypertrack.lib.models.User;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import com.google.android.gms.maps.model.LatLng;

public class RNHyperTrackModule extends ReactContextBaseJavaModule implements LifecycleEventListener {

    private final ReactApplicationContext reactContext;

    public RNHyperTrackModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;

        // Set Callback to receive events & errors
        HyperTrack.setCallback(new HyperTrackEventCallback() {
            @Override
            public void onEvent(@NonNull final HyperTrackEvent event) {
                // handle event received here
                if (event.getEventType() == HyperTrackEvent.EventType.LOCATION_CHANGED_EVENT) {
                    sendLocationChangedEvent(event);
                }
            }

            @Override
            public void onError(@NonNull final ErrorResponse errorResponse) {
                // handle event received here
            }
        });
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

    private void sendLocationChangedEvent(final HyperTrackEvent event) {
        // Send this event to js
        GeoJSONLocation geojson = event.getLocation().getGeoJSONLocation();
        String serializedGeojson = new GsonBuilder().create().toJson(geojson);
        WritableMap params = Arguments.createMap();
        params.putString("geojson", serializedGeojson);
        sendEvent("location.changed", params);
    }

    /**
    * Initialization methods
    **/

    @ReactMethod
    public void initialize(String publishableKey) {
        HyperTrack.initialize(getReactApplicationContext(), publishableKey);
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
        HyperTrack.getOrCreateUser(userName, phoneNumber, lookupId, new HyperTrackCallback() {
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

    @Override
    public void onHostDestroy() { }

    @Override
    public void onHostPause() { }

    @Override
    public void onHostResume() { }
}
