//
//  BruceTVC.h
//  hackGMSClient
//
//  Created by Bruce Arthur on 11/11/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreferencesViewController.h"
#import "TrackArrivals.h"
#import "NetworkingClient.h"


@interface BruceTVC : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UITextField *messageField;
@property (strong, nonatomic) IBOutlet UIButton *preferencesButton;
@property (strong, nonatomic) PreferencesViewController *preferencesController;
@property (strong, nonatomic) TrackArrivals *tracker;
@property (strong, nonatomic) NetworkingClient *networkingClient;
@property (strong, nonatomic) NSArray *messages;

-(IBAction)sendMessage:(id)sender;
-(IBAction)showPreferences:(id)sender;

-(void)startTrackingArrivalsAtGMS:(BOOL)yn;

-(void)preferencesFinished;
-(void)fetchNewData;


@end
