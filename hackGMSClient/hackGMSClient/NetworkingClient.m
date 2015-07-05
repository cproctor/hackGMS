//
//  NetworkingClient.m
//  hackGMSClient
//
//  Created by Bruce Arthur on 11/11/14.
//  Copyright (c) 2014 Bruce Arthur. All rights reserved.
//

#import "NetworkingClient.h"
#import "PreferencesViewController.h"

NSString *kMessageText = @"text";
NSString *kMessageDateAsString = @"date";
NSString *kMessageDateAsNSDateKey = @"dateAsNSDate";
NSString *kMessageDateAsStringWithRelativeFormat = @"formattedDateString";

NSString *serverURLString = @"http://gms.ninja/api/messages/create";
NSString *testServerURLString = @"http://localhost:5000/api/messages/create";

NSString *URLForMessages = @"http://gms.ninja/api/messages";
NSString *testServerURLForMessages = @"http://localhost:5000/api/messages";

NSString *testServerFormatFetch = @"http://%@:5000/api/messages";
NSString *testServerFormatPost = @"http://%@:5000/api/messages/create";

@implementation NetworkingClient

-(id)init
{
    self = [super init];
    _messages = [[NSMutableArray alloc] init];
    return self;
}

- (void)fetchMessagesWithObject:(id)obj selector:(SEL)selector
{
    NSURL *url;
    _fetchCallBackObject = obj;
    _fetchCallbackSelector = selector;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    

    if ([ud boolForKey:useTestServerKey]) {
        NSString *testServer = [ud stringForKey:testServerHostNameKey];
        if (!testServer || [testServer length] == 0) {
            testServer = @"localhost";
        }
        NSString *urlString = [NSString stringWithFormat:testServerFormatFetch, testServer];
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL URLWithString:URLForMessages];
    }
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [_errorReportingObject performSelectorOnMainThread:_errorReportingSelector withObject:error waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(setMessagesFromJSONData:) withObject:data waitUntilDone:NO];
        }
    }];
    [dataTask resume];
}


static NSString * _readBytes(CFReadStreamRef stream)
{
    CFIndex numBytesRead = 0 ;
    NSMutableData *responseBytes = [NSMutableData data];
    
    do
    {
        UInt8 buf[1024];
        numBytesRead = CFReadStreamRead(stream, buf, sizeof(buf));
        
        
        if(numBytesRead > 0)
            [responseBytes appendBytes:buf length:numBytesRead];
        
        
    } while(numBytesRead > 0);
    
    NSString *responseString = [[NSString alloc] initWithData:responseBytes encoding:kCFStringEncodingUTF8];
    return responseString;
}

static void _ReadClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void* clientCallBackInfo)
{
    NSString *messageToLog;
    NSError *error = nil;
    CFStreamError myErr;
    BOOL cleanUpAndClose = NO;
    
    switch (type) {
        case kCFStreamEventNone:
            messageToLog = @"none";
            break;
        case kCFStreamEventOpenCompleted:
            messageToLog = @"openCompleted";
            break;
        case kCFStreamEventHasBytesAvailable:
            messageToLog = [NSString stringWithFormat:@"hasBytesAvailable, fetched reponse:%@\n", _readBytes(stream)];
            break;
        case kCFStreamEventCanAcceptBytes:
            messageToLog = @"canAcceptBytes";
            break;
        case kCFStreamEventErrorOccurred:
            myErr = CFReadStreamGetError(stream);
            if (myErr.domain == kCFStreamErrorDomainPOSIX) {
                // Interpret myErr.error as a UNIX errno.
                error = [NSError errorWithDomain:NSPOSIXErrorDomain code:myErr.error userInfo:nil];
                messageToLog = [NSString stringWithFormat:@"error opening the stream, UNIX error:%i\n", (int)myErr.error];
            } else if (myErr.domain == kCFStreamErrorDomainMacOSStatus) {
                // Interpret myErr.error as a MacOS error code.
                OSStatus macError = (OSStatus)myErr.error;
                // Check other error domains.
                error = [NSError errorWithDomain:NSOSStatusErrorDomain code:myErr.error userInfo:nil];
                messageToLog = [NSString stringWithFormat:@"error opening the stream, Mac error:%i\n", (int)macError];
            } else {
                messageToLog = @"error";
            }
            cleanUpAndClose = YES;
            break;
        case kCFStreamEventEndEncountered:
            messageToLog = @"endEncountered";
            cleanUpAndClose = YES;
            break;
        default:
            messageToLog = @"unexpected type encountered ?!?!";
            break;
    }
    
    if (cleanUpAndClose) {
        CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
        CFReadStreamClose(stream);
        id callbackObject = (__bridge id)clientCallBackInfo;
        if (error) {
            [callbackObject performSelectorOnMainThread:@selector(sendErrorCallback:) withObject:error waitUntilDone:NO];
        } else {
            [callbackObject performSelectorOnMainThread:@selector(sendFetchCallback) withObject:nil waitUntilDone:NO];
        }
        //[callbackObject performSelectorOnMainThread:@selector(refresh:) withObject:nil waitUntilDone:NO];
        
    }
    
    //NSLog(@"CFReadStreamRef:%p type:%lu on thread:%p\n%@", stream, type, [NSThread currentThread], messageToLog);
    
}

-(void)sendErrorCallback:(NSError *)error
{
    [_errorReportingObject performSelector:_errorReportingSelector withObject:error afterDelay:0.0];
}


- (void)sendFetchCallback
{
    [_postCallBackObject performSelectorOnMainThread:_postCallbackSelector withObject:nil waitUntilDone:NO];
}

- (void)postMessageToServer:(NSString *)message author:(NSString *)author withObject:(id)object selector:(SEL)selector;
{
    NSData *JSONData;
    NSError *error;
    CFURLRef serverURL;
    CFDataRef mySerializationRequest;
    NSString *URLstring;
    CFStreamClientContext clientContext;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    
    _postCallBackObject = object;
    _postCallbackSelector = selector;
    
    if ([ud boolForKey:useTestServerKey]) {
        NSString *testServer = [ud stringForKey:testServerHostNameKey];
        if (!testServer || [testServer length] == 0) {
            testServer = @"localhost";
        }
        URLstring = [NSString stringWithFormat:testServerFormatPost, testServer];
    } else {
        URLstring = serverURLString;
    }
    
    serverURL = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)URLstring, NULL);
    
    
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDictionary *JSONDict = [NSDictionary dictionaryWithObjectsAndKeys:message, @"text", [rfc3339DateFormatter stringFromDate:[NSDate date]], @"date", author, @"author", nil];
    
    //NSDictionary *JSONDict = [NSDictionary dictionaryWithObject:message forKey:@"text"];
    JSONData = [NSJSONSerialization dataWithJSONObject:JSONDict options:0 error:&error];
    
    CFHTTPMessageRef postMessage;
    postMessage = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)@"POST", serverURL, kCFHTTPVersion1_1);
    CFHTTPMessageSetBody(postMessage, (__bridge CFDataRef)JSONData);
    CFHTTPMessageSetHeaderFieldValue(postMessage, (CFStringRef)@"UserAgent", (CFStringRef)@"hackGMS-iOS-version-1");
    CFHTTPMessageSetHeaderFieldValue(postMessage, (CFStringRef)@"Content-type", (CFStringRef)@"application/json");
    
    mySerializationRequest = CFHTTPMessageCopySerializedMessage(postMessage);
    
    clientContext.version = 0;
    clientContext.info = (__bridge void *)(self);
    clientContext.retain = NULL;
    clientContext.release = NULL;
    clientContext.copyDescription = NULL;
    
    
    CFReadStreamRef myReadStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, postMessage);
    CFReadStreamScheduleWithRunLoop(myReadStream, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    CFReadStreamSetClient(myReadStream, kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventCanAcceptBytes | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered, _ReadClientCallBack, &clientContext);
    
    if (!CFReadStreamOpen(myReadStream)) {
        CFStreamError myErr = CFReadStreamGetError(myReadStream);
        NSError *error;
        // An error has occurred.
        if (myErr.domain == kCFStreamErrorDomainPOSIX) {
            // Interpret myErr.error as a UNIX errno.
            error = [NSError errorWithDomain:NSPOSIXErrorDomain code:myErr.error userInfo:nil];
            NSLog(@"error opening the stream, UNIX error:%i\n", (int)myErr.error);
        } else if (myErr.domain == kCFStreamErrorDomainMacOSStatus) {
            // Interpret myErr.error as a MacOS error code.
            OSStatus macError = (OSStatus)myErr.error;
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:myErr.error userInfo:nil];
            // Check other error domains.
            NSLog(@"error opening the stream, Mac error:%i\n", (int)macError);
        }
        [_errorReportingObject performSelector:_errorReportingSelector withObject:error afterDelay:0.0];
    }
}

- (NSString *)formattedDateForNSDate:(NSDate *)date
{
    static NSDateFormatter *formatter = nil;
    
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setLocale:enUSPOSIXLocale];
        [formatter setDoesRelativeDateFormatting:YES];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return [formatter stringFromDate:date];
}


- (void)setMessagesFromJSONData:(NSData *)data
{
    NSError *JSONError;
    NSArray *JSONMessagesArray;
    NSMutableArray *newMessagesArray = [[NSMutableArray alloc] init];
    
    JSONMessagesArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&JSONError];
    
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    for (NSMutableDictionary *dict in JSONMessagesArray) {
        NSString *dateAsString = [dict objectForKey:@"date"];
        NSDate *date;
        NSString *formattedDateString;
        NSMutableDictionary *newDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        
        date = [rfc3339DateFormatter dateFromString:dateAsString];
        if (date) {
            [newDict setObject:date forKey:kMessageDateAsNSDateKey];
            formattedDateString = [self formattedDateForNSDate:date];
            [newDict setObject:formattedDateString forKey:kMessageDateAsStringWithRelativeFormat];
            [newMessagesArray addObject:newDict];
        } else {
            NSLog(@"unable to build a date from string:%@, ignoring messaage:%@\n", dateAsString, [dict objectForKey:kMessageText]);
        }
    }
    
    _messages = newMessagesArray;
    
    [_fetchCallBackObject performSelectorOnMainThread:_fetchCallbackSelector withObject:[NSArray arrayWithArray:_messages] waitUntilDone:NO];
}

- (void)setErrorReportingObject:(id)obj selector:(SEL)selector
{
    _errorReportingObject = obj;
    _errorReportingSelector = selector;
}

@end
