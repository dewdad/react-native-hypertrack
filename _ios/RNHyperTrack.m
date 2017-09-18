
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
 

RCT_EXPORT_METHOD(getPublishableKey :(RCTResponseSenderBlock) callback)
{
  callback(@[[HyperTrack getPublishableKey]]);
}  


/**
 Setup methods
*/


RCT_EXPORT_METHOD(getOrCreateUser :(NSString *)name :(NSString *)phone :(NSString *)lookupId :(RCTResponseSenderBlock) success :(RCTResponseSenderBlock) failure) {
  [HyperTrack getOrCreateUser:name _phone:phone :lookupId completionHandler:^(HyperTrackUser * _Nullable user, HyperTrackError * _Nullable error) {
    if (error) {
      failure(@[error]);
    } else {
      if (user) {
        success(@[[user toJson]]);
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


RCT_EXPORT_METHOD(locationAuthorizationStatus :(RCTResponseSenderBlock) callback)
{
  CLAuthorizationStatus locationAuthorizationStatus = [HyperTrack locationAuthorizationStatus];
  switch (locationAuthorizationStatus) {
    default:
    case kCLAuthorizationStatusNotDetermined:
      callback(@[@"notDetermined"]);
      break;
    case kCLAuthorizationStatusRestricted:
      callback(@[@"restricted"]);
      break;
    case kCLAuthorizationStatusDenied:
      callback(@[@"denied"]);
      break;
    case kCLAuthorizationStatusAuthorizedAlways:
      callback(@[@"authorizedAlways"]);
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      callback(@[@"authorizedWhenInUse"]);
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


RCT_EXPORT_METHOD(locationServicesEnabled :(RCTResponseSenderBlock) callback)
{
  callback(@[[NSNumber numberWithBool:[HyperTrack locationServicesEnabled]]]);
}


RCT_EXPORT_METHOD(requestLocationServices)
{
  [HyperTrack requestLocationServices];
}


/**
 Motion Authorization methods
*/


RCT_EXPORT_METHOD(canAskMotionPermissions :(RCTResponseSenderBlock) callback)
{
  callback(@[[NSNumber numberWithBool:[HyperTrack canAskMotionPermissions]]]);
}


RCT_EXPORT_METHOD(requestMotionAuthorization)
{
  [HyperTrack requestMotionAuthorization];
}


/**
 Util methods
*/

RCT_EXPORT_METHOD(isTracking :(RCTResponseSenderBlock) callback)
{
  callback(@[[NSNumber numberWithBool:[HyperTrack isTracking]]]);
}


RCT_EXPORT_METHOD(getUserId :(RCTResponseSenderBlock) callback)
{
  callback(@[[HyperTrack getUserId]]);
}


RCT_EXPORT_METHOD(getETA :(nonnull NSNumber *)latitude :(nonnull NSNumber *)longitude :(NSString *)vehicle :(RCTResponseSenderBlock) success :(RCTResponseSenderBlock) failure)
{
  CLLocationCoordinate2D coord;
  coord.longitude = (CLLocationDegrees)[longitude doubleValue];
  coord.latitude = (CLLocationDegrees)[latitude doubleValue];
  
  [HyperTrack getETAWithExpectedPlaceCoordinates:coord
                                     vehicleType:vehicle
                               completionHandler:^(NSNumber * _Nullable eta,
                                                   HyperTrackError * _Nullable error) {
                                 if (error) {
                                   failure(@[error]);
                                   return;
                                 }
                                 
                                 success(@[eta]);
                               }];
}


RCT_EXPORT_METHOD(getCurrentLocation :(RCTResponseSenderBlock) success :(RCTResponseSenderBlock) failure)
{
  [HyperTrack getCurrentLocationWithCompletionHandler:^(CLLocation * _Nullable currentLocation,
                                                   HyperTrackError * _Nullable error) {
    if (error) {
      failure(@[[error toJson]]);
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
                                 
    success(@[locationMap]);
  }];
}


/**
 Basic integration methods
*/


RCT_EXPORT_METHOD(startTracking :(RCTResponseSenderBlock) success :(RCTResponseSenderBlock) failure)
{
  [HyperTrack startTrackingWithCompletionHandler:^(HyperTrackError * _Nullable error) {
    if (error) {
      failure(@[error]);
    } else {
      // TODO: response object
      success(@[]);
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


RCT_EXPORT_METHOD(createAndAssignAction :(NSDictionary *) params :(RCTResponseSenderBlock) success :(RCTResponseSenderBlock) failure)
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
                                       failure(@[error]);
                                       return;
                                     }
                                     
                                     if (action) {
                                       // Handle createAndAssignAction API success here
                                       success(@[[action toJson]]);
                                     }
                                   }];
  
}


RCT_EXPORT_METHOD(assignActions :(NSArray *)actionIds :(RCTResponseSenderBlock) success :(RCTResponseSenderBlock) failure)
{
  [HyperTrack assignActionsWithActionIds:actionIds :^(HyperTrackUser * _Nullable user, HyperTrackError * _Nullable error) {
    
    if (error) {
      failure(@[error]);
      return;
    }
    
    if (user) {
      success(@[[user toJson]]);
    }
    
  }];
}


RCT_EXPORT_METHOD(getAction :(NSString *)actionId :(RCTResponseSenderBlock) success :(RCTResponseSenderBlock) failure)
{
  [HyperTrack getAction:actionId
      completionHandler:^(HyperTrackAction * _Nullable action,
                          HyperTrackError * _Nullable error) {
        if (error) {
          // Handle error and call failure callback
          failure(@[error]);
          return;
        }
        
        if (action) {
          // Send action to success callback
          success(@[[action toJson]]);
        }
      }];
}


RCT_EXPORT_METHOD(completeAction :(NSString *)actionId) {
  [HyperTrack completeAction:actionId];
}


@end
