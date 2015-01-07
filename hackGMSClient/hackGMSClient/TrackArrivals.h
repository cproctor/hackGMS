//
//  TrackArrivals.h
//  hackGMSClient
//
//  Created by Bruce Arthur on 11/11/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NSString *CoreLocationNotAuthorized;

@interface TrackArrivals : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLRegion *roughTrackingRegion;
@property (strong, nonatomic) CLLocation *centerOfBackParkingLot;
@property (strong, nonatomic) id callbackObject;
@property (nonatomic) SEL callbackSelector;
@property (nonatomic) BOOL insidePreciseRegion;

- (void)startTrackingWithObject:(id)obj selector:(SEL)selector;
- (void)stopTracking;
@end
