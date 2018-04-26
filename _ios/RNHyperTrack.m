
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

-(HTActionParams *) mapDictionaryToHTActionParams:(NSDictionary *) params {
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
  return htActionParams;
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

-(NSError *)getInvalidParamsError {
  return [[NSError alloc] initWithDomain:@"HyperTrackError" code:131 userInfo:@{@"description": @"Invalid Parameters supplied"}];
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
  HTActionParams * htActionParams = [self mapDictionaryToHTActionParams:params];
  
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

RCT_EXPORT_METHOD(createMockAction :(NSDictionary *) params resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  HTActionParams * htActionParams = [self mapDictionaryToHTActionParams:params];
  HTLocationCoordinate *origin = [[HTLocationCoordinate alloc] initWithLat:0 lng:0 ];
  
  if ([params objectForKey: @"location"]) {
    NSDictionary *dict = [params objectForKey: @"location"];
    if ([dict objectForKey: @"coordinates"]) {
      NSArray *array = (NSArray *)[dict objectForKey: @"coordinates"];
      if ([array count] == 2) {
        origin = [[HTLocationCoordinate alloc] initWithLat:[array.lastObject doubleValue] lng:[array.firstObject doubleValue] ];
      }
    }
  }
  
  [HyperTrack createMockAction:origin :NULL :htActionParams completionHandler:^(HTAction * _Nullable action, HTError * _Nullable error) {
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

RCT_EXPORT_METHOD(completeMockAction :(NSString *)actionId resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack completeMockActionWithActionId:actionId completionHandler:^(HTAction * _Nullable action, HTError * _Nullable error) {
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

RCT_EXPORT_METHOD(getActionForUniqueId :(NSString *)uniqueId resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack getActionsForUniqueId:uniqueId :^(NSArray<HTAction *> * _Nullable actions, HTError * _Nullable error) {
    if (error) {
      // Handle error and call failure callback
      NSError * nsError = [self getErrorFromHyperTrackError:error];
      reject(@"Error", @"", nsError);
      return;
    }
    if (actions) {
      if ([actions count] == 0) {
        NSError *nsError = [self getInvalidParamsError];
        reject(@"Error", @"", nsError);
      } else {
        // Send action to success callback
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (HTAction *action in actions) {
          [array addObject:[action toJson]];
        }
        resolve(array);
      }
    }
  }];
}

RCT_EXPORT_METHOD(getActionForCollectionId :(NSString *)collectionId resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack getActionsForCollectionId:collectionId completionHandler:^(NSArray<HTAction *> * _Nullable actions, HTError * _Nullable error) {
    if (error) {
      // Handle error and call failure callback
      NSError * nsError = [self getErrorFromHyperTrackError:error];
      reject(@"Error", @"", nsError);
      return;
    }
    
    if (actions) {
      if ([actions count] == 0) {
        NSError *nsError = [self getInvalidParamsError];
        reject(@"Error", @"", nsError);
      } else {
        // Send action to success callback
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (HTAction *action in actions) {
          [array addObject:[action toJson]];
        }
        resolve(array);
      }
    }
  }];
}

RCT_EXPORT_METHOD(getActionForShortCode :(NSString *)shortCode resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack getActionsForShortCode:shortCode :^(NSArray<HTAction *> * _Nullable actions, HTError * _Nullable error) {
    if (error) {
      // Handle error and call failure callback
      NSError * nsError = [self getErrorFromHyperTrackError:error];
      reject(@"Error", @"", nsError);
      return;
    }
    
    if (actions) {
      if ([actions count] == 0) {
        NSError *nsError = [self getInvalidParamsError];
        reject(@"Error", @"", nsError);
      } else {
        // Send action to success callback
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (HTAction *action in actions) {
          [array addObject:[action toJson]];
        }
        resolve(array);
      }
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
  
RCT_EXPORT_METHOD(completeActionInSyncWithUniqueId :(NSString *)uniqueId  resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  [HyperTrack completeActionWithUniqueIdInSync:uniqueId completionHandler:^(HTAction * _Nullable action, HTError * _Nullable error) {
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

RCT_EXPORT_METHOD(updateUser :(NSString *)name :(NSString *)phone :(NSString *)uniqueId :(UIImage *)photo resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
[HyperTrack updateUserWithName:name phone:phone uniqueId:uniqueId photo:photo
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
 Remote notifications methods
 */

  
RCT_EXPORT_METHOD(registerForNotifications)
{
  [HyperTrack registerForNotifications];
}

RCT_EXPORT_METHOD(didRegisterForRemoteNotificationsWithDeviceToken :(NSData *) deviceToken)
{
  [HyperTrack didRegisterForRemoteNotificationsWithDeviceTokenWithDeviceToken:deviceToken];
}

RCT_EXPORT_METHOD(didFailToRegisterForRemoteNotificationsWithError :(NSError *) error)
{
  [HyperTrack didFailToRegisterForRemoteNotificationsWithErrorWithError:error];
}

RCT_EXPORT_METHOD(didReceiveRemoteNotificationWithUserInfo :(NSDictionary *) userInfo)
{
  [HyperTrack didReceiveRemoteNotificationWithUserInfo:userInfo];
}

RCT_EXPORT_METHOD(isHyperTrackNotification: (NSDictionary *) userInfo :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
  resolve(@[[NSNumber numberWithBool:[HyperTrack isHyperTrackNotificationWithUserInfo:userInfo]]]);
}

RCT_EXPORT_METHOD(getPlaceline: (NSString *) date :(NSString *)userId :(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  [HyperTrack getPlacelineWithDate:date userId:userId completionHandler:^(HTPlaceline * _Nullable placeline, HTError * _Nullable error) {
       if (placeline) {
         resolve(@[[placeline toJson]]);
       } else if (error) {
         NSError * nsError = [self getErrorFromHyperTrackError:error];
         reject(@"Error", @"", nsError);
       }
     }];
}

RCT_EXPORT_METHOD(getPendingActions: (RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  [HyperTrack getPendingActionsWithCompletionHandler:^(NSArray<HTAction *> * _Nullable actions, HTError * _Nullable error) {
    if (error) {
      NSError * nsError = [self getErrorFromHyperTrackError:error];
      reject(@"Error", @"", nsError);
      return;
    }
    if (actions) {
      NSMutableArray *array = [[NSMutableArray alloc] init];
      for (HTAction *action in actions) {
        [array addObject:[action toJson]];
      }
      resolve(array);
    }
  }];
}


@end
