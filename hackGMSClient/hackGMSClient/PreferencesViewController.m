//
//  PreferencesViewController.m
//  Location Services Test App
//
//  Created by Bruce Arthur on 11/6/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreferencesViewController.h"
#import "BruceTVC.h"

@implementation PreferencesViewController

NSString *userNameKey = @"userNameKey";
NSString *automaticallyNotifyKey = @"automaticallyNotify";
NSString *useTestServerKey = @"useTestServer";
NSString *testServerHostNameKey = @"testServerHostName";

- (void)viewDidLoad
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL useTestServer = [ud boolForKey:useTestServerKey];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSString *userName, *testServerHostName;
    BOOL automaticallyNotify;
    
    userName = [ud stringForKey:userNameKey];
    if (!userName)
        userName = @"";
    
    automaticallyNotify = [ud boolForKey:automaticallyNotifyKey];
    testServerHostName = [ud stringForKey:testServerHostNameKey];
    if (!testServerHostName)
        testServerHostName = @"";
    
    [_userNameField setText:userName];
    [_trackLocation setOn:automaticallyNotify];
    [_useTestServer setOn:useTestServer];
    [_testServerHostNameField setText:testServerHostName];

    [nc addObserver:self selector:@selector(coreLocationDenied) name:CoreLocationNotAuthorized object:nil];
}

- (IBAction)automaticallyNotifyOnArrival:(id)sender
{
    BOOL automaticallyNotify;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    automaticallyNotify = [sender isOn];
    [ud setBool:automaticallyNotify forKey:automaticallyNotifyKey];
    [(BruceTVC *)_callingViewController startTrackingArrivalsAtGMS:automaticallyNotify];
}

- (IBAction)useTestServer:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL useTestServer = [sender isOn];
    [ud setBool:useTestServer forKey:useTestServerKey];
}


- (IBAction)done:(id)sender
{
    [_userNameField resignFirstResponder];
    [_testServerHostNameField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        [(BruceTVC *)_callingViewController preferencesFinished];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if (textField == _userNameField) {
        [ud setObject:[textField text] forKey:userNameKey];
    } else if (textField == _testServerHostNameField) {
        [ud setObject:[textField text] forKey:testServerHostNameKey];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        [_doneButton setEnabled:NO];
    } else {
        [_doneButton setEnabled:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)coreLocationDenied
{
    [_trackLocation setOn:NO];
    [self automaticallyNotifyOnArrival:_trackLocation];
}


@end
