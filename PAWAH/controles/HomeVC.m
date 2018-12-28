//
//  HomeVC.m
//  PAWAH
//
//  Created by Jean Dieu on 6/25/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "HomeVC.h"
#import "AjustesVC.h"
#import "GaleriaVC.h"
#import "RecVideoVC.h"
#import "ComoUsarVC.h"
#import "DerechosVC.h"
#import "sqlite3.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HomeVC ()
{
    CLLocationManager *locationManager;
    IBOutlet CLLocation *userLoc;
}

@end

@implementation HomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    recording = NO;
    
    userLoc = [[CLLocation alloc] init];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    timerExample4 = [[MZTimerLabel alloc] initWithLabel:_lblTimerExample4 andTimerType:MZTimerLabelTypeStopWatch];
    [timerExample4 setStopWatchTime:0];
    timerExample4.timeFormat = @"HH:mm:ss SS";
    [timerExample4 setFont:[UIFont fontWithName:@"Rockwell" size:[timerExample4.font pointSize]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [timerExample4 reset];
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error"
                               message:@"Localización no disponible"
                               delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        userLoc = currentLocation;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:[NSString stringWithFormat:@"%.20f", userLoc.coordinate.latitude] forKey:@"userLat"];
        [defaults setValue:[NSString stringWithFormat:@"%.20f", userLoc.coordinate.longitude] forKey:@"userLon"];
        [defaults synchronize];
        
        NSLog(@"didUpdateToLocation: %@", userLoc);
        
        [locationManager stopUpdatingLocation];
    }
}

#pragma IBActions

- (IBAction)recAudio:(UIButton *)sender
{
    if(!recording){
        [btnAudio setImage:[UIImage imageNamed:@"modomicrofono_btn_on"] forState:UIControlStateNormal];
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat:@"%@.m4a", [self genRandStringLength:20]],
                                   nil];
        
        NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        NSLog(@"%@", [pathComponents objectAtIndex:1]);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:@"pawah.sqlite"];
        
        sqlite3 *database;
        
        if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
            
            const char *sqlInsert = "INSERT INTO id_registros (url, location_ini, location_fin, tipo, fecha) VALUES (?, ?, ?, ?, ?)";
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:NSDateFormatterShortStyle];
            [dateFormat setTimeStyle:NSDateFormatterNoStyle];
            [dateFormat setDateFormat:@"dd/MM/yyyy"];
            
            NSString *dateToday = [dateFormat stringFromDate:[NSDate date]];
            
            sqlite3_stmt *compiledStatement;
            
            if(sqlite3_prepare_v2(database, sqlInsert, -1, &compiledStatement, NULL) == SQLITE_OK)
            {
                sqlite3_bind_text(compiledStatement, 1, [[pathComponents objectAtIndex:1] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 2, [[NSString stringWithFormat:@"%.20f,%.20f", userLoc.coordinate.latitude, userLoc.coordinate.longitude] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 3, [[NSString stringWithFormat:@"%.20f,%.20f", userLoc.coordinate.latitude, userLoc.coordinate.longitude] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 4, [@"AUDIO" UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 5, [dateToday UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
                sqlite3_finalize(compiledStatement);
            }
        }
        
        sqlite3_close(database);
        
        session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if([[defaults objectForKey:@"HDA"] boolValue]){
            NSLog(@"HDA_ON");
            /*
            [recordSetting setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
            [recordSetting setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
            [recordSetting setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
            [recordSetting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
            */
            [recordSetting setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
        }else{
            NSLog(@"HDA_OFF");
            /*
            [recordSetting setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
            [recordSetting setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
            [recordSetting setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
            [recordSetting setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
            */
            [recordSetting setObject:[NSNumber numberWithInt: AVAudioQualityMedium] forKey: AVEncoderAudioQualityKey];
        }
        
        recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        [recorder prepareToRecord];
        
        [session setActive:YES error:nil];
        
        [timerExample4 reset];
        [timerExample4 start];
        
        // Start recording
        recording = YES;
        [recorder record];
        [btnVideo setEnabled:NO];
        [btnPhoto setEnabled:NO];
    }else{
        [btnAudio setImage:[UIImage imageNamed:@"home_btn_microfono"] forState:UIControlStateNormal];
        
        [timerExample4 pause];
        
        recording = NO;
        [recorder stop];
        
        session = [AVAudioSession sharedInstance];
        [session setActive:NO error:nil];
    }
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    [btnVideo setEnabled:YES];
    [btnPhoto setEnabled:YES];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
    //player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
    //[player setDelegate:self];
    //[player play];
}

- (IBAction)takePhoto:(UIButton *)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)captureVideo:(UIButton *)sender {
    /*
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        [self presentViewController:picker animated:YES completion:NULL];
    }
    */
    
    RecVideoVC *recVideoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RecVideo"];
    recVideoViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    recVideoViewController.locationIni = [NSString stringWithFormat:@"%.20f,%.20f", userLoc.coordinate.latitude, userLoc.coordinate.longitude];
    recVideoViewController.locationFin = [NSString stringWithFormat:@"%.20f,%.20f", userLoc.coordinate.latitude, userLoc.coordinate.longitude];
    [self presentViewController:recVideoViewController animated:YES completion:^(void){
        NSLog(@"recVideo_view");
    }];
}

- (IBAction)showRights:(id)sender
{
    DerechosVC *derechosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Derechos"];
    [self presentViewController:derechosVC animated:YES completion:^(void){NSLog(@"show_derechos");}];
}

- (IBAction)showHowUse:(id)sender
{
    ComoUsarVC *comoUsarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ComoUsar"];
    [self presentViewController:comoUsarVC animated:YES completion:^(void){NSLog(@"show_comoUsar");}];
}

- (IBAction)showGallery:(id)sender
{
    GaleriaVC *galeriaVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Galeria"];
    [self presentViewController:galeriaVC animated:YES completion:^(void){NSLog(@"show_galeria");}];
}

- (IBAction)showSettings:(id)sender
{
    AjustesVC *ajustesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Ajustes"];
    [self presentViewController:ajustesVC animated:YES completion:^(void){NSLog(@"show_ajustes");}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.videoURL = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (NSString *)genRandStringLength:(int)len
{
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

@end
