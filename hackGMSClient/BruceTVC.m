//
//  BruceTVC.m
//  hackGMSClient
//
//  Created by Bruce Arthur on 11/11/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import "BruceTVC.h"
#include <AudioToolbox/AudioToolbox.h>


@interface BruceTVC ()

@end

@implementation BruceTVC

-(IBAction)showPreferences:(id)sender
{
    [self presentViewController:_preferencesController animated:YES completion:NULL];
}

- (void)sendMessageTextToServer:(NSString *)message playSoundAfterSuccess:(BOOL)yn
{
    NSString *username;
    
    username = [[NSUserDefaults standardUserDefaults] stringForKey:userNameKey];
    [_networkingClient postMessageToServer:message
                                    author:username
                                withObject:self
                                  selector:yn ? @selector(finishedSendingMessageAndPlaySound) : @selector(finishedSendingMessage)];
    [_messageField resignFirstResponder];
    _messageField.text = @"";
    
    //[self performSelector:@selector(sendMessageTextToServer:playSoundAfterSuccess:) withObject:@"Hi there, this rocks!" afterDelay:135.0];

}

-(void)finishedSendingMessageAndPlaySound
{
    [self playArrivalSound];
    [self fetchNewData];
}

-(void)finishedSendingMessage
{
    [self fetchNewData];
}

-(void)playArrivalSound
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        static SystemSoundID soundFileObject = 0;
        if (!soundFileObject) {
            NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"024971_Trumpet_Charge_Sound_Effect" withExtension:@"caf"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(soundURL), &soundFileObject);
        }
        AudioServicesPlaySystemSound(soundFileObject);
    } else {
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        if (localNotif == nil)
            return;
        localNotif.fireDate = [NSDate date];
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
        localNotif.alertBody = @"Your arrival was posted to hackGMS";
        localNotif.alertAction = nil;
        localNotif.alertTitle = nil;
    
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1;
        localNotif.soundName = @"024971_Trumpet_Charge_Sound_Effect.caf";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
}

- (void)arrivedAtGMS
{
    [self sendMessageTextToServer:@"Arrived at GMS" playSoundAfterSuccess:YES];
}


-(IBAction)sendMessage:(id)sender
{
    NSString *messageFieldText = [_messageField text];
    
    // If the field was empty, don't bother sending anything
    if (messageFieldText != nil && [messageFieldText length] != 0) {
        [self sendMessageTextToServer:messageFieldText playSoundAfterSuccess:NO];
        [_messageField resignFirstResponder];
        _messageField.text = @"";
    }
}

-(void)handleNetworkingError:(NSError *)error
{
    static SystemSoundID errorSoundFileObject = 0;
    
    if (!errorSoundFileObject) {
        NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"Sad_Trombone-Joe_Lamb-665429450" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(soundURL), &errorSoundFileObject);
    }
    AudioServicesPlaySystemSound(errorSoundFileObject);
    [self.refreshControl endRefreshing];

    NSLog(@"networking error %@\n", error);
}


- (void)viewDidLoad {
    NSString *username;
    [super viewDidLoad];
    
    _preferencesController = [[self storyboard] instantiateViewControllerWithIdentifier:@"preferences"];
    if (!_preferencesController) {
        NSLog(@"Unable to find preferencesController, that's not good\n");
    } else {
        [_preferencesController setCallingViewController:self];
    }

    
    self.tableView.tableHeaderView = [self headerView];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(fetchNewData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    _tracker = [[TrackArrivals alloc] init];
    [self startTrackingArrivalsAtGMS:[[NSUserDefaults standardUserDefaults] boolForKey:automaticallyNotifyKey]];

    _networkingClient = [[NetworkingClient alloc] init];
    //_networkingClient.useTestServer = YES;
    _messages = [[NSArray alloc] init];
    
    [_networkingClient setErrorReportingObject:self selector:@selector(handleNetworkingError:)];

    // Run the preferences UI if we don't have a username configured.
    username = [[NSUserDefaults standardUserDefaults] stringForKey:userNameKey];
    if (username == NULL || [username length] == 0) {
        [self performSelector:@selector(showPreferences:) withObject:nil afterDelay:0.0];
    } else {
        [self fetchNewData];
    }
    
    //[self performSelector:@selector(fetchNewData) withObject:nil afterDelay:30.0];
    //[self performSelector:@selector(sendMessageTextToServer:playSoundAfterSuccess:) withObject:@"Hi there, this rocks!" afterDelay:45.0];
    
}

-(void)newMessages:(NSArray *)newMessages
{
    [self.refreshControl endRefreshing];
    _messages = newMessages;
    [[self tableView] reloadData];
}

- (void)fetchNewData

{
    [_networkingClient fetchMessagesWithObject:self selector:@selector(newMessages:)];
    //[self performSelector:@selector(fetchNewData) withObject:nil afterDelay:45.0];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    textField.text = @"";
}

-(void)startTrackingArrivalsAtGMS:(BOOL)yn
{
    if (yn) {
        [_tracker startTrackingWithObject:self selector:@selector(arrivedAtGMS)];
    } else {
        [_tracker stopTracking];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _messages.count;
}

NSString *hackGMSCellIdentifier = @"hackGMS";


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    //NSLog(@"heightForRowAtIndex:%i returned %f\n", [indexPath indexAtPosition:1], cell.frame.size.height);
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect frame;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:hackGMSCellIdentifier];
    NSString *author;
    NSString *dateWithFancyFormatting;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:hackGMSCellIdentifier];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    // Configure the cell...
    NSDictionary *message = [_messages objectAtIndex:[indexPath indexAtPosition:1]];
    author = [message objectForKey:@"author"];
    cell.textLabel.text  = [NSString stringWithFormat:@"%@: %@", author, [message objectForKey:@"text"]];
    dateWithFancyFormatting = [message objectForKey:kMessageDateAsStringWithRelativeFormat];
    cell.detailTextLabel.text = dateWithFancyFormatting;
    frame = cell.frame;
    frame.size.width = tableView.frame.size.width - 1.0;
    [cell setFrame:frame];
    [cell sizeToFit];
    //NSLog(@"cell:%p for row %lu, text %@ sized(%f,%f)\n", cell, (unsigned long)[indexPath indexAtPosition:1], cell.textLabel.text, cell.frame.size.width, cell.frame.size.height);
    return cell;
}

-(void)preferencesFinished
{
    [self fetchNewData];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
