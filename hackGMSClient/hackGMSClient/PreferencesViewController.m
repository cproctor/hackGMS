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

- (void)viewDidLoad
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    BOOL useTestServer = [ud boolForKey:useTestServerKey];
    
    _userName = [ud stringForKey:userNameKey];
    if (!_userName)
        _userName = @"";
    
    _automaticallyNotify = [ud boolForKey:automaticallyNotifyKey];
    
    [_userNameField setText:_userName];
    [_trackLocation setOn:_automaticallyNotify];
    [_useTestServer setOn:useTestServer];

}

- (IBAction)automaticallyNotifyOnArrival:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _automaticallyNotify = [sender isOn];
    [ud setBool:_automaticallyNotify forKey:automaticallyNotifyKey];
    [(BruceTVC *)_callingViewController startTrackingArrivalsAtGMS:_automaticallyNotify];
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
    [self dismissViewControllerAnimated:YES completion:^{
        [(BruceTVC *)_callingViewController preferencesFinished];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    [ud setObject:[textField text] forKey:userNameKey];
    
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


@end
