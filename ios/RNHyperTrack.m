
#import "RNHyperTrack.h"
#import <React/RCTLog.h>

@import HyperTrack;

@implementation RNHyperTrack


RCT_EXPORT_MODULE();


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


RCT_EXPORT_METHOD(initialize:(NSString *)token)
{
    RCTLogInfo(@"Initializing HyperTrack with token: %@", token);
    [HyperTrack initialize:token];
    [HyperTrack requestAlwaysAuthorization];
}


RCT_EXPORT_METHOD(getOrCreateUser:(NSString *)name :(NSString *)phone :(NSString *)lookupId :(RCTResponseSenderBlock) success :(RCTResponseSenderBlock) failure)
{
    [HyperTrack getOrCreateUser:name _phone:phone :lookupId completionHandler:^(HyperTrackUser * _Nullable user, HyperTrackError * _Nullable error) {
        if (error) {
            failure(@[error]);
        } else {
            if (user) {
                success(@[user]);
            }
        }
    }];
}


RCT_EXPORT_METHOD(setUserId:(NSString *)userId)
{
    [HyperTrack setUserId:userId];
}


RCT_EXPORT_METHOD(startTracking :(RCTResponseSenderBlock) success :(RCTResponseSenderBlock) failure)
{
    [HyperTrack startTrackingWithCompletionHandler:^(HyperTrackError * _Nullable error) {
        if (error) {
            failure(@[error]);
        } else {
            success(@[]);
        }
    }];
}


RCT_EXPORT_METHOD(stopTracking)
{
    [HyperTrack stopTracking];
}


RCT_EXPORT_METHOD(isTracking :(RCTResponseSenderBlock) callback)
{
    callback(@[[NSNumber numberWithBool:[HyperTrack isTracking]]]);
}



@end
