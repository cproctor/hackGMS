//
//  TrackArrivals.m
//  hackGMSClient
//
//  Created by Bruce Arthur on 11/11/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import "TrackArrivals.h"

@implementation TrackArrivals

CLLocationCoordinate2D GirlsMiddleSchoolLocation = {37.4352, -122.11035};
CLLocationDistance RoughRadiusForRegion = 100.0;
CLLocationDistance PreciseRadius = 25.0;


- (id)init
{
    self = [super init];
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDelegate:self];
    
    _roughTrackingRegion = [[CLCircularRegion alloc] initWithCenter:GirlsMiddleSchoolLocation
                                                             radius:RoughRadiusForRegion
                                                         identifier:@"GirlsMiddleSchoolRough"];
    _centerOfBackParkingLot = [[CLLocation alloc] initWithLatitude:GirlsMiddleSchoolLocation.latitude longitude:GirlsMiddleSchoolLocation.longitude];
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
    //NSLog(@"did enter region %@\n", region);
    [self startPreciseTracking];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if ([location distanceFromLocation:_centerOfBackParkingLot] <= PreciseRadius) {
            //NSLog(@"Arrived inside the precise area.\n");
            [_callbackObject performSelectorOnMainThread:_callbackSelector withObject:nil waitUntilDone:NO];
            [self stopPreciseTracking];
            break;
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    // Stop precise tracking on exit of the rough region
    //NSLog(@"did exit region %@\n", region);
    [self stopPreciseTracking];
}

- (void) locationManager:(CLLocationManager *)locationManager didChangeAuthorizationStatus:(CLAuthorizationStatus)newStatus
{
    if (newStatus == kCLAuthorizationStatusAuthorizedAlways) {
        [self startLocationServices];
    } else {
        NSLog(@"CoreLocation status came in as %i, and that isn't going to work.\n", newStatus);
    }
}

-(void)startPreciseTracking
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
            //NSLog(@"CoreLocation is authorized. Status = %i\n", currentStatus);
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"CLLocation is authorized only when the app is in use, that means notifications only go out when this is the front most app, and that's not very useful.\n");
            break;
    }
    
    if (currentStatus == kCLAuthorizationStatusAuthorizedAlways) {
        [_locationManager startUpdatingLocation];
    } else {
        NSLog(@"Unable startUpdatingLocation because CLAuthorizationStatus = %u\n", currentStatus);
    }
}

-(void)stopPreciseTracking
{
    //NSLog(@"Stopped precise location tracking.\n");
    [_locationManager stopUpdatingLocation];
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
            //NSLog(@"CoreLocation is authorized. Status = %i\n", currentStatus);
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"CLLocation is authorized only when the app is in use, that means notifications only go out when this is the front most app, and that's not very useful.\n");
            break;
    }
    
    if (currentStatus == kCLAuthorizationStatusAuthorizedAlways) {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            //NSLog(@"Starting precise location tracking.\n");
            [_locationManager startMonitoringSignificantLocationChanges];
            [_locationManager startMonitoringForRegion:_roughTrackingRegion];
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
    [self stopPreciseTracking];
    [_locationManager stopMonitoringForRegion:_roughTrackingRegion];
    [_locationManager stopMonitoringSignificantLocationChanges];
}

@end
