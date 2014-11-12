//
//  TrackArrivals.m
//  hackGMSClient
//
//  Created by Bruce Arthur on 11/11/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import "TrackArrivals.h"

@implementation TrackArrivals

CLLocationCoordinate2D GirlsMiddleSchoolLocation = {37.435376, -122.109867};
CLLocationDistance RadiusForRegion = 50.0;

- (id)init
{
    self = [super init];
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    
    _trackingRegion = [[CLCircularRegion alloc] initWithCenter:GirlsMiddleSchoolLocation
                                                        radius:RadiusForRegion
                                                    identifier:@"GirlsMiddleSchool"];
    
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"CLLocationManager called with an error:%@", error);
}

- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error
{
    NSLog(@"CLLocationManager called with an error for region:%@, error:%@\n", region, error);
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    NSLog(@"did enter region %@\n", region);
    [_callbackObject performSelectorOnMainThread:_callbackSelector withObject:nil waitUntilDone:NO];
}

- (void) locationManager:(CLLocationManager *)locationManager didChangeAuthorizationStatus:(CLAuthorizationStatus)newStatus
{
    if (newStatus == kCLAuthorizationStatusAuthorizedAlways) {
        [self startLocationServices];
    } else {
        NSLog(@"CoreLocation status came in as %i, and that isn't going to work.\n", newStatus);
    }
}


- (void)startLocationServices
{
    CLAuthorizationStatus currentStatus = [CLLocationManager authorizationStatus];
    switch (currentStatus) {
        case kCLAuthorizationStatusNotDetermined:
            [_locationManager requestAlwaysAuthorization];
            currentStatus = [CLLocationManager authorizationStatus];
            break;
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            NSLog(@"CoreLocation is not authorized, so tracking will not work. Status = %i\n",currentStatus);
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"CoreLocation is authorized. Status = %i\n", currentStatus);
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"CLLocation is authorized only when the app is in use, that means notifications only go out when this is the front most app, and that's not very useful.\n");
            break;
    }
    
    if (currentStatus == kCLAuthorizationStatusAuthorizedAlways) {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            [_locationManager startMonitoringSignificantLocationChanges];
            [_locationManager startMonitoringForRegion:_trackingRegion];
        } else {
            NSLog(@"[CoreLocation significantChangeMonitoringAvailable] returned NO, probably not a supported device (no cell radio, or not configured).\n");
        }
    } else {
        NSLog(@"Unable start significant changes monitoring because CLAuthorizationStatus = %u\n", currentStatus);
    }
}

- (void)startTrackingWithObject:(id)obj selector:(SEL)selector
{
    _callbackObject = obj;
    _callbackSelector = selector;
    [self startLocationServices];
}


- (void)stopTracking
{
    [_locationManager stopMonitoringForRegion:_trackingRegion];
    [_locationManager stopMonitoringSignificantLocationChanges];
}

@end
