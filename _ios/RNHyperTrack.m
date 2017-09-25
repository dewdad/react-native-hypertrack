
#import "RNHyperTrack.h"
#import <React/RCTLog.h>
#import <React/RCTEventDispatcher.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
@import HyperTrack;

@implementation RNHyperTrack
  
  
RCT_EXPORT_MODULE();
  
/**
 HyperTrackEvent methods
*/
  
- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}
  

- (NSArray<NSString *> *)supportedEvents {
    return @[@"location.changed"];
}


- (void) didReceiveEvent:(HyperTrackEvent *)event {
  // HyperTrack delegate method
  // Process events
  if (event.location != nil) {
    [self sendEventWithName:@"location.changed" body:@{@"geojson": [event.location.location toJson]}];
  }
}
  

- (void) didFailWithError:(HyperTrackError *)error {
  // HyperTrack delegate method
  // Not handling failure at the moment
}

/**
 Initialization methods
*/
  

RCT_EXPORT_METHOD(initialize :(NSString *)token) {
  RCTLogInfo(@"Initializing HyperTrack with token: %@", token);
  [HyperTrack initialize:token];
  [HyperTrack requestAlwaysAuthorization];
  [HyperTrack setDelegate:self];
}
 

RCT_EXPORT_METHOD(getPublishableKey, getPublishableKeyWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@[[HyperTrack getPublishableKey]]);
}  


/**
 Setup methods
*/


RCT_EXPORT_METHOD(getOrCreateUser :(NSString *)name :(NSString *)phone :(NSString *)lookupId resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  [HyperTrack getOrCreateUser:name _phone:phone :lookupId completionHandler:^(HyperTrackUser * _Nullable user, HyperTrackError * _Nullable error) {
    if (error) {
      reject(@[error]);
    } else {
      if (user) {
        resolve(@[[user toJson]]);
      }
    }
  }];
}


RCT_EXPORT_METHOD(setUserId :(NSString *)userId)
{
  [HyperTrack setUserId:userId];
}


/**
 Location Authorization methods
*/


RCT_EXPORT_METHOD(locationAuthorizationStatus, locationAuthorizationStatusResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  CLAuthorizationStatus locationAuthorizationStatus = [HyperTrack locationAuthorizationStatus];
  switch (locationAuthorizationStatus) {
    default:
    case kCLAuthorizationStatusNotDetermined:
      resolve(@[@"notDetermined"]);
      break;
    case kCLAuthorizationStatusRestricted:
      resolve(@[@"restricted"]);
      break;
    case kCLAuthorizationStatusDenied:
      resolve(@[@"denied"]);
      break;
    case kCLAuthorizationStatusAuthorizedAlways:
      resolve(@[@"authorizedAlways"]);
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      resolve(@[@"authorizedWhenInUse"]);
      break;
  }
}


RCT_EXPORT_METHOD(requestWhenInUseAuthorization:(NSString *)rationaleTitle :(NSString *)rationaleMessage)
{
  [HyperTrack requestWhenInUseAuthorization];
}


RCT_EXPORT_METHOD(requestLocationAuthorization:(NSString *)rationaleTitle :(NSString *)rationaleMessage)
{
  [HyperTrack requestAlwaysAuthorization];
}


/**
 Location Services methods
*/


RCT_EXPORT_METHOD(locationServicesEnabled, locationServicesEnabledResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@[[NSNumber numberWithBool:[HyperTrack locationServicesEnabled]]]);
}


RCT_EXPORT_METHOD(requestLocationServices)
{
  [HyperTrack requestLocationServices];
}


/**
 Motion Authorization methods
*/


RCT_EXPORT_METHOD(canAskMotionPermissions, canAskMotionPermissionsResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@[[NSNumber numberWithBool:[HyperTrack canAskMotionPermissions]]]);
}


RCT_EXPORT_METHOD(requestMotionAuthorization)
{
  [HyperTrack requestMotionAuthorization];
}


/**
 Util methods
*/

RCT_EXPORT_METHOD(isTracking, isTrackingResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@[[NSNumber numberWithBool:[HyperTrack isTracking]]]);
}


RCT_EXPORT_METHOD(getUserId, getUserIdResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@[[HyperTrack getUserId]]);
}


RCT_EXPORT_METHOD(getETA :(nonnull NSNumber *)latitude :(nonnull NSNumber *)longitude :(NSString *)vehicle resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  CLLocationCoordinate2D coord;
  coord.longitude = (CLLocationDegrees)[longitude doubleValue];
  coord.latitude = (CLLocationDegrees)[latitude doubleValue];
  
  [HyperTrack getETAWithExpectedPlaceCoordinates:coord
                                     vehicleType:vehicle
                               completionHandler:^(NSNumber * _Nullable eta,
                                                   HyperTrackError * _Nullable error) {
                                 if (error) {
                                   reject(@[error]);
                                   return;
                                 }
                                 
                                 resolve(@[eta]);
                               }];
}


RCT_EXPORT_METHOD(getCurrentLocation, getCurrentLocationResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack getCurrentLocationWithCompletionHandler:^(CLLocation * _Nullable currentLocation,
                                                   HyperTrackError * _Nullable error) {
    if (error) {
      reject(@[[error toJson]]);
      return;
    }

    NSMutableDictionary *locationMap = [[NSMutableDictionary alloc] init];
    [locationMap setValue:[NSNumber numberWithDouble:currentLocation.coordinate.latitude] forKey:@"latitude"];
    [locationMap setValue:[NSNumber numberWithDouble:currentLocation.coordinate.longitude] forKey:@"longitude"];
    [locationMap setValue:[NSNumber numberWithDouble:currentLocation.altitude] forKey:@"altitude"];
    [locationMap setValue:[NSNumber numberWithDouble:currentLocation.horizontalAccuracy] forKey:@"accuracy"];
    [locationMap setValue:[NSNumber numberWithDouble:currentLocation.verticalAccuracy] forKey:@"verticalAccuracy"];
    [locationMap setValue:[NSNumber numberWithDouble:currentLocation.course] forKey:@"bearing"];
    [locationMap setValue:[NSNumber numberWithDouble:currentLocation.speed] forKey:@"speed"];
                                 
    resolve(@[locationMap]);
  }];
}


/**
 Basic integration methods
*/


RCT_EXPORT_METHOD(startTracking, startTrackingResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack startTrackingWithCompletionHandler:^(HyperTrackError * _Nullable error) {
    if (error) {
      reject(@[error]);
    } else {
      // TODO: response object
      resolve(@[]);
    }
  }];
}


RCT_EXPORT_METHOD(stopTracking)
{
  [HyperTrack stopTracking];
}


RCT_EXPORT_METHOD(startMockTracking)
{
  [HyperTrack startMockTracking];
}


RCT_EXPORT_METHOD(stopMockTracking)
{
  [HyperTrack stopMockTracking];
}


/**
 Action methods
*/


RCT_EXPORT_METHOD(createAndAssignAction :(NSDictionary *) params resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  HyperTrackActionParams * htActionParams = [[HyperTrackActionParams alloc] init];
  
  if ([params objectForKey: @"expected_place_id"]) {
    [htActionParams setExpectedPlaceId: params[@"expected_place_id"]];
  }
  
  if ([params objectForKey: @"expected_at"]) {
    [htActionParams setExpectedAt: params[@"expected_at"]];
  }
  
  if ([params objectForKey: @"type"]) {
    [htActionParams setType: params[@"type"]];
  }
  
  if ([params objectForKey: @"lookup_id"]) {
    [htActionParams setLookupId: params[@"lookup_id"]];
  }
  
  [HyperTrack createAndAssignAction:htActionParams
                                   :^(HyperTrackAction * _Nullable action,
                                      HyperTrackError * _Nullable error) {
                                     if (error) {
                                       // Handle createAndAssignAction API error here
                                       reject(@[error]);
                                       return;
                                     }
                                     
                                     if (action) {
                                       // Handle createAndAssignAction API success here
                                       resolve(@[[action toJson]]);
                                     }
                                   }];
  
}


RCT_EXPORT_METHOD(assignActions :(NSArray *)actionIds resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack assignActionsWithActionIds:actionIds :^(HyperTrackUser * _Nullable user, HyperTrackError * _Nullable error) {
    
    if (error) {
      reject(@[error]);
      return;
    }
    
    if (user) {
      resolve(@[[user toJson]]);
    }
    
  }];
}


RCT_EXPORT_METHOD(getAction :(NSString *)actionId resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack getAction:actionId
      completionHandler:^(HyperTrackAction * _Nullable action,
                          HyperTrackError * _Nullable error) {
        if (error) {
          // Handle error and call failure callback
          reject(@[error]);
          return;
        }
        
        if (action) {
          // Send action to success callback
          resolve(@[[action toJson]]);
        }
      }];
}


RCT_EXPORT_METHOD(completeAction :(NSString *)actionId) {
  [HyperTrack completeAction:actionId];
}


@end
