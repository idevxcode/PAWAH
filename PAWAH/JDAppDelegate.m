//
//  JDAppDelegate.m
//  PAWAH
//
//  Created by Jean Dieu on 6/24/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "JDAppDelegate.h"
#import "sqlite3.h"

@implementation JDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"tour_view"];
    [defaults setBool:NO forKey:@"tour_exit"];
    
    if([defaults objectForKey:@"ES"]==nil){
        [defaults setBool:YES forKey:@"ES"];
        [defaults setBool:YES forKey:@"HDV"];
        [defaults setBool:YES forKey:@"HDA"];
    }
    
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUploadEventNotification:) name:@"uploadEventNotification" object:nil];
    
    /*
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"FONT %@", family);
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    */
    
    [self copyDatabaseToDocuments];
    
    //NSURL *videoURL = [[NSBundle mainBundle] URLForResource: @"pawah" withExtension:@"sqlite"];
    //NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    //[self post:videoData];
    
    return YES;
}

- (void) handleUploadEventNotification:(NSNotification *)notification {
    NSDictionary *nInfo = notification.userInfo;
    if (nInfo) {
        NSLog(@"upload: %@",(NSString *)[nInfo objectForKey:@"fileUpload"]);
    }
}

- (void)post:(NSData *)fileData
{
    NSLog(@"POSTING");
    
    NSData *postData = fileData;
    NSString * filenames = [NSString stringWithFormat:@"pawah.sqlite"];
    
    NSLog(@"%@", filenames);
    
    NSString *urlString = @"http://server.route/upload_ios/";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[filenames dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\"pawah.sqlite\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:postData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Response : %@",returnString);
    
    if([returnString isEqualToString:@"Success"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"File Saved Successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
    }
    NSLog(@"Finish");
    
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

#pragma Methods

- (void)copyDatabaseToDocuments {
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *filePath = [documentsPath stringByAppendingPathComponent:@"pawah.sqlite"];
    
	if ( ![fileManager fileExistsAtPath:filePath] ) {
        NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pawah.sqlite"];
        [fileManager copyItemAtPath:bundlePath toPath:filePath error:nil];
	}
    
    NSArray *tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
    
    NSLog(@"%@ / %@", [paths description], [[NSProcessInfo processInfo] globallyUniqueString]);
}

-(int)dateDiffrenceFromDate:(NSString *)date1 second:(NSString *)date2 {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *startDate = [formatter dateFromString:date1];
    NSDate *endDate = [formatter dateFromString:date2];
    
    
    unsigned flags = NSDayCalendarUnit;
    NSDateComponents *difference = [[NSCalendar currentCalendar] components:flags fromDate:startDate toDate:endDate options:0];
    
    int dayDiff = (int)[difference day];
    
    return dayDiff;
}

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}


@end
