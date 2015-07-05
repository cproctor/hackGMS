//
//  PreferencesViewController.h
//  Location Services Test App
//
//  Created by Bruce Arthur on 11/6/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *userNameKey;
extern NSString *automaticallyNotifyKey;
extern NSString *useTestServerKey;
extern NSString *testServerHostNameKey;

@interface PreferencesViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *userNameField;
@property (strong, nonatomic) IBOutlet UISwitch *trackLocation;
@property (strong, nonatomic) IBOutlet UISwitch *useTestServer;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UITextField *testServerHostNameField;

@property (strong, nonatomic) UIViewController *callingViewController;

- (IBAction)automaticallyNotifyOnArrival:(id)sender;
- (IBAction)useTestServer:(id)sender;
- (IBAction)done:(id)sender;

@end

