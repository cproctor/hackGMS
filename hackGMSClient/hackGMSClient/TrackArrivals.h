//
//  TrackArrivals.h
//  hackGMSClient
//
//  Created by Bruce Arthur on 11/11/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface TrackArrivals : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLRegion *trackingRegion;
@property (strong, nonatomic) id callbackObject;
@property (nonatomic) SEL callbackSelector;

- (void)startTrackingWithObject:(id)obj selector:(SEL)selector;
- (void)stopTracking;
@end
