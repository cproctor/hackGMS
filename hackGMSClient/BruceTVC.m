//
//  BruceTVC.m
//  hackGMSClient
//
//  Created by Bruce Arthur on 11/11/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import "BruceTVC.h"

@interface BruceTVC ()

@end

@implementation BruceTVC

-(IBAction)showPreferences:(id)sender
{
    [self presentViewController:_preferencesController animated:YES completion:NULL];
}

- (void)sendMessageTextToServer:(NSString *)message
{
    NSString *username;
    NSString *fullMessage;
    
    username = [[NSUserDefaults standardUserDefaults] stringForKey:userNameKey];
    if (username && [username length]) {
        fullMessage = [NSString stringWithFormat:@"%@: %@", [[NSUserDefaults standardUserDefaults] stringForKey:userNameKey], message];
    } else {
        fullMessage = message;
    }
    [_networkingClient postMessageToServer:fullMessage withObject:self selector:@selector(fetchNewData)];
    [_messageField resignFirstResponder];
    _messageField.text = @"";

}

- (void)arrivedAtGMS
{
    [self sendMessageTextToServer:@"Arrived at GMS"];
}


-(IBAction)sendMessage:(id)sender
{
    [self sendMessageTextToServer:[_messageField text]];
    [_messageField resignFirstResponder];
    _messageField.text = @"";
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

    // Run the preferences UI if we don't have a username configured.
    username = [[NSUserDefaults standardUserDefaults] stringForKey:userNameKey];
    if (username == NULL || [username length] == 0) {
        [self performSelector:@selector(showPreferences:) withObject:nil afterDelay:0.0];
    } else {
        [self fetchNewData];
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:hackGMSCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:hackGMSCellIdentifier];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    // Configure the cell...
    NSDictionary *message = [_messages objectAtIndex:[indexPath indexAtPosition:1]];
    cell.textLabel.text  = [message objectForKey:@"text"];
    cell.detailTextLabel.text = [message objectForKey:kMessageDateAsStringWithRelativeFormat];
    [cell sizeToFit];
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
