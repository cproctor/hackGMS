//
//  NetworkingClient.h
//  hackGMSClient
//
//  Created by Bruce Arthur on 11/11/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *kMessageText;
NSString *kMessageDateAsString;
NSString *kMessageDateAsNSDateKey;
NSString *kMessageDateAsStringWithRelativeFormat;


@interface NetworkingClient : NSObject

@property (strong, nonatomic) id postCallBackObject;
@property (nonatomic) SEL postCallbackSelector;
@property (strong, nonatomic) id fetchCallBackObject;
@property (nonatomic) SEL fetchCallbackSelector;
@property (strong, nonatomic) NSMutableArray *messages;

- (void)postMessageToServer:(NSString *)message author:(NSString *)author withObject:(id)object selector:(SEL)selector;
- (void)fetchMessagesWithObject:(id)obj selector:(SEL)selector;

@end
