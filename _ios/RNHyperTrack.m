
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
  if ([event getLocation] != nil) {
    [self sendEventWithName:@"location.changed" body:@{@"geojson": [[event getLocation].location toJson]}];
  }
}

- (void) didFailWithError:(HTError *)error {
  // HyperTrack delegate method
  // Not handling failure at the moment
}

/**
 Initialization methods
 */


RCT_EXPORT_METHOD(initialize :(NSString *)token) {
  RCTLogInfo(@"Initializing HyperTrack with token: %@", token);
  [HyperTrack initialize:token];
  [HyperTrack setEventsDelegateWithEventDelegate:self];
}


RCT_EXPORT_METHOD(getPublishableKey :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@[[HyperTrack getPublishableKey]]);
}


/**
 Setup methods
 */
-(NSError *)getErrorFromHyperTrackError:(HTError *)hyperTrackError {
  NSDictionary * userInfo = @{@"description":hyperTrackError.errorMessage};
  
  NSError * nsError = [NSError errorWithDomain:@"HyperTrackError"
                                          code:hyperTrackError.errorCode
                                      userInfo:userInfo];

  return  nsError;
}

RCT_EXPORT_METHOD(getOrCreateUser :(NSString *)name :(NSString *)phone :(NSString *)uniqueId resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  [HyperTrack getOrCreateUserWithName:name phone:phone uniqueId:uniqueId
                    completionHandler:^(HTUser * _Nullable user, HTError * _Nullable error) {
                      if (user) {
                        resolve(@[[user toJson]]);
                      } else if (error) {
                        NSError * nsError = [self getErrorFromHyperTrackError:error];
                        reject(@"Error", @"", nsError);
                      }
                    }];
}


/**
 Location Authorization methods
 */


RCT_EXPORT_METHOD(locationAuthorizationStatus :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
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

RCT_EXPORT_METHOD(requestAlwaysLocationAuthorization :(NSString *)rationaleTitle :(NSString *)rationaleMessage)
{
  [HyperTrack requestAlwaysLocationAuthorizationWithCompletionHandler:^(BOOL authorized) {
  }];
}


/**
 Location Services methods
 */


RCT_EXPORT_METHOD(locationServicesEnabled :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
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


RCT_EXPORT_METHOD(motionAuthorizationStatus :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack motionAuthorizationStatusWithCompletionHandler:^(BOOL authorized) {
    resolve(@[[NSNumber numberWithBool:authorized]]);
  }];
}


RCT_EXPORT_METHOD(requestMotionAuthorization)
{
  [HyperTrack requestMotionAuthorization];
}


/**
 Util methods
 */

RCT_EXPORT_METHOD(isTracking :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@[[NSNumber numberWithBool:[HyperTrack isTracking]]]);
}


RCT_EXPORT_METHOD(getUserId :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@[[HyperTrack getUserId]]);
}

RCT_EXPORT_METHOD(getCurrentLocation :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack getCurrentLocationWithCompletionHandler:^(CLLocation * _Nullable currentLocation,
                                                        HTError * _Nullable error) {
    if (error) {
      NSError * nsError = [self getErrorFromHyperTrackError:error];
      reject(@"Error", @"", nsError);
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


RCT_EXPORT_METHOD(resumeTracking :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack resumeTrackingWithCompletionHandler:^(HTError * _Nullable error) {
    if (error) {
      NSError * nsError = [self getErrorFromHyperTrackError:error];
      reject(@"Error", @"", nsError);
    } else {
      // TODO: response object
      resolve(@[]);
    }
  }];
}


RCT_EXPORT_METHOD(pauseTracking)
{
  [HyperTrack pauseTracking];
}


//RCT_EXPORT_METHOD(startMockTracking)
//{
//  [HyperTrack startMockTracking];
//}
//
//
//RCT_EXPORT_METHOD(stopMockTracking)
//{
//  [HyperTrack stopMockTracking];
//}


/**
 Action methods
 */


RCT_EXPORT_METHOD(createAction :(NSDictionary *) params resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  HTActionParams * htActionParams = [[HTActionParams alloc] init];
  
  if ([params objectForKey: @"expected_place_id"]) {
    [htActionParams setExpectedPlaceId:params[@"expected_place_id"]];
  }
  
  if ([params objectForKey: @"expected_at"]) {
    [htActionParams setExpectedAt: params[@"expected_at"]];
  }
  
  if ([params objectForKey: @"type"]) {
    [htActionParams setType: params[@"type"]];
  }
  
  if ([params objectForKey: @"unique_id"]) {
    [htActionParams setUniqueId: params[@"unique_id"]];
  }

  if ([params objectForKey: @"collection_id"]) {
    [htActionParams setCollectionId: params[@"collection_id"]];
  }
  
  if([params objectForKey: @"expected_place"]){
    HTPlace * place = [[HTPlace alloc] initWithDict:[params objectForKey: @"expected_place"]];
    [htActionParams setExpectedPlace: place];
  }
  
  
  [HyperTrack createAction:htActionParams
                                   :^(HTAction * _Nullable action,
                                      HTError * _Nullable error) {
                                     if (error) {
                                       // Handle createAndAssignAction API error here
                                       NSError * nsError = [self getErrorFromHyperTrackError:error];
                                       reject(@"Error", @"", nsError);
                                       return;
                                     }
                                     if (action) {
                                       // Handle createAndAssignAction API success here
                                       resolve(@[[action toJson]]);
                                     }
                                   }];
  
}

RCT_EXPORT_METHOD(getAction :(NSString *)actionId resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack getActionForActionId:actionId completionHandler:^(HTAction * _Nullable action, HTError * _Nullable error) {
    if (error) {
          // Handle error and call failure callback
          NSError * nsError = [self getErrorFromHyperTrackError:error];
          reject(@"Error", @"", nsError);
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

RCT_EXPORT_METHOD(completeActionInSync :(NSString *)actionId  resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack completeActionInSync:actionId completionHandler:^(HTAction * _Nullable action, HTError * _Nullable error) {
        if (error) {
          // Handle error and call failure callback
          NSError * nsError = [self getErrorFromHyperTrackError:error];
          reject(@"Error", @"", nsError);
          return;
        }
        
        if (action) {
          // Send action to success callback
          resolve(@[[action toJson]]);
        }

    }];
}


@end
