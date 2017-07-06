
#import "RNHyperTrack.h"
#import <React/RCTLog.h>
#import <React/RCTEventDispatcher.h>

@import HyperTrack;

@implementation RNHyperTrack
  
  
RCT_EXPORT_MODULE();
  
  
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
  
  
RCT_EXPORT_METHOD(initialize :(NSString *)token) {
  RCTLogInfo(@"Initializing HyperTrack with token: %@", token);
  [HyperTrack initialize:token];
  [HyperTrack requestAlwaysAuthorization];
  [HyperTrack setDelegate:self];
}
  

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


RCT_EXPORT_METHOD(completeAction :(NSString *)actionId) {
  [HyperTrack completeAction:actionId];
}


RCT_EXPORT_METHOD(isTracking :(RCTResponseSenderBlock) callback)
{
  callback(@[[NSNumber numberWithBool:[HyperTrack isTracking]]]);
}


@end
