
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

import java.util.Map;
import java.util.HashMap;
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

    @ReactMethod
    public void initialize(String publishableKey) {
        HyperTrack.initialize(getReactApplicationContext(), publishableKey);
    }

    @ReactMethod
    public void getPublishableKey(final Callback callback) {
        Context context = getReactApplicationContext();
        callback.invoke(HyperTrack.getPublishableKey(context));
    }

    @ReactMethod
    public void getOrCreateUser(String userName, String phoneNumber, String lookupId, final Callback successCallback, final Callback errorCallback) {
        HyperTrack.getOrCreateUser(userName, phoneNumber, lookupId, new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Return User object in successCallback
                User user = (User) response.getResponseObject();
                String serializedUser = new GsonBuilder().create().toJson(user);
                successCallback.invoke(serializedUser);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                errorCallback.invoke(serializedError);
            }
        });
    }

    @ReactMethod
    public void setUserId(String userId) {
        HyperTrack.setUserId(userId);
    }

    @ReactMethod
    public void getUserId(final Callback callback) {
        callback.invoke(HyperTrack.getUserId());
    }

    @ReactMethod
    public void startTracking(final Callback successCallback, final Callback errorCallback) {
        HyperTrack.startTracking(new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Return User object in successCallback
                String userId = (String) response.getResponseObject();
                successCallback.invoke(userId);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                errorCallback.invoke(serializedError);
            }
        });
    }

    @ReactMethod
    public void isTracking(final Callback callback) {
        callback.invoke(HyperTrack.isTracking());
    }

    @ReactMethod
    public void createAndAssignAction(ReadableMap params, final Callback successCallback, final Callback errorCallback) {
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
                successCallback.invoke(serializedAction);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                errorCallback.invoke(serializedError);
            }
        });
    }

    @ReactMethod
    public void getAction(String actionId, final Callback successCallback, final Callback errorCallback) {
        HyperTrack.getAction(actionId, new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Handle getAction response here
                Action actionResponse = (Action) response.getResponseObject();
                String serializedAction = new GsonBuilder().create().toJson(actionResponse);
                successCallback.invoke(serializedAction);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                // Handle getAction error here
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                errorCallback.invoke(serializedError);
            }
        });
    }

    @ReactMethod
    public void getETA(final double expectedPlaceLat, final double expectedPlaceLng, final String vehicleType, 
            final Callback successCallback, final Callback errorCallback) {
        LatLng expectedLocation = new LatLng(expectedPlaceLat, expectedPlaceLng);
        HyperTrack.getETA(expectedLocation, new VehicleType(vehicleType), new HyperTrackCallback() {
            @Override
            public void onSuccess(@NonNull SuccessResponse response) {
                // Handle getETA API success here
                Double eta = (Double) response.getResponseObject();
                successCallback.invoke(eta);
            }

            @Override
            public void onError(@NonNull ErrorResponse errorResponse) {
                // Handle getETA API error here
                String serializedError = new GsonBuilder().create().toJson(errorResponse);
                errorCallback.invoke(serializedError);
            }
        });
    }

    @ReactMethod
    public void completeAction(String actionId) {
        HyperTrack.completeAction(actionId);
    }

    @ReactMethod
    public void stopTracking() {
        HyperTrack.stopTracking();
    }

    @Override
    public void onHostDestroy() {
        //
    }

    @Override
    public void onHostPause() { }

    @Override
    public void onHostResume() { }

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
}
