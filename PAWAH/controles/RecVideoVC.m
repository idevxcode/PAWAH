//
//  RecVideoVC.m
//  PAWAH
//
//  Created by Jean Dieu on 6/30/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "RecVideoVC.h"
#import "sqlite3.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface RecVideoVC ()

@end

@implementation RecVideoVC

@synthesize PreviewLayer, tabla, tweets;

@synthesize recVideo, stopVideo, takePhoto, btnHide, locationIni, locationFin, stillImageOutput;
@synthesize badgeOne;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [self.view addGestureRecognizer:panRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationDetected:)];
    [self.view addGestureRecognizer:rotationRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    tapRecognizer.numberOfTapsRequired = 5;
    [self.view addGestureRecognizer:tapRecognizer];
    
    panRecognizer.delegate = self;
    pinchRecognizer.delegate = self;
    rotationRecognizer.delegate = self;
    
    WeAreRecording = NO;
    
    [tabla setHidden:YES];
    [stopVideo setHidden:YES];
    
    session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetMedium;
    
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	NSError *error = nil;
	VideoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!VideoInputDevice) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
    
	[session addInput:VideoInputDevice];
	//[session startRunning];
    
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
	AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
	if (audioInput)
	{
		[session addInput:audioInput];
	}
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];
    
    [session addOutput:stillImageOutput];
    
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:session]];
	
	[[self PreviewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	
    videoConnection = nil;
	for (AVCaptureConnection *connection in stillImageOutput.connections)
	{
		for (AVCaptureInputPort *port in [connection inputPorts])
		{
			if ([[port mediaType] isEqual:AVMediaTypeVideo] )
			{
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { break; }
	}
	
	//ADD MOVIE FILE OUTPUT
	NSLog(@"Adding movie file output");
	MovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
	
	Float64 TotalSeconds = 60;			//Total seconds
	int32_t preferredTimeScale = 30;	//Frames per second
	CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);	//<<SET MAX DURATION
	MovieFileOutput.maxRecordedDuration = maxDuration;
	
	MovieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;						//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
	
	if ([session canAddOutput:MovieFileOutput])
		[session addOutput:MovieFileOutput];
    
	//SET THE CONNECTION PROPERTIES (output properties)
	//[self CameraSetOutputProperties];			//(We call a method as it also has to be done after changing camera)
    
	//----- SET THE IMAGE QUALITY / RESOLUTION -----
	//Options:
	//	AVCaptureSessionPresetHigh - Highest recording quality (varies per device)
	//	AVCaptureSessionPresetMedium - Suitable for WiFi sharing (actual values may change)
	//	AVCaptureSessionPresetLow - Suitable for 3G sharing (actual values may change)
	//	AVCaptureSessionPreset640x480 - 640x480 VGA (check its supported before setting it)
	//	AVCaptureSessionPreset1280x720 - 1280x720 720p HD (check its supported before setting it)
	//	AVCaptureSessionPresetPhoto - Full photo resolution (not supported for video output)
	NSLog(@"Setting image quality");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([[defaults objectForKey:@"HDV"] boolValue]){
        NSLog(@"HDV_ON");
        [session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
            [session setSessionPreset:AVCaptureSessionPreset1920x1080];
    }else{
        NSLog(@"HDV_OFF");
        [session setSessionPreset:AVCaptureSessionPresetMedium];
        if ([session canSetSessionPreset:AVCaptureSessionPreset640x480])
            [session setSessionPreset:AVCaptureSessionPreset640x480];
    }
	
	//----- DISPLAY THE PREVIEW LAYER -----
	//Display it full screen under out view controller existing controls
	NSLog(@"Display the preview layer");
	CGRect layerRect = [[[self view] layer] bounds];
	[PreviewLayer setBounds:layerRect];
	[PreviewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                          CGRectGetMidY(layerRect))];
	//[[[self view] layer] addSublayer:[[self CaptureManager] previewLayer]];
	//We use this instead so it goes on a layer behind our UI controls (avoids us having to manually bring each control to the front):
	UIView *CameraView = [[UIView alloc] init];
	[[self view] addSubview:CameraView];
	[self.view sendSubviewToBack:CameraView];
	
	[[CameraView layer] addSublayer:PreviewLayer];
	
	timerExample4 = [[MZTimerLabel alloc] initWithLabel:_lblTimerExample4 andTimerType:MZTimerLabelTypeStopWatch];
    [timerExample4 setStopWatchTime:0];
    timerExample4.timeFormat = @"HH:mm:ss SS";
    [timerExample4 setFont:[UIFont fontWithName:@"Rockwell" size:[timerExample4.font pointSize]]];
    
	//----- START THE CAPTURE SESSION RUNNING -----
	[session startRunning];
    
    self.badgeOne = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(self.takePhoto.frame.size.width - 22,
                                                                         -20,
                                                                         44,
                                                                         40)];
    [self.takePhoto addSubview:self.badgeOne];
    
    [tabla setHidden:YES];
    [self fetchTweets];
}

#pragma mark - Gesture Recognizers

- (void)panDetected:(UIPanGestureRecognizer *)panRecognizer
{
    
}

- (void)pinchDetected:(UIPinchGestureRecognizer *)pinchRecognizer
{
    //[self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"recVideo_exit");}];
}

- (void)rotationDetected:(UIRotationGestureRecognizer *)rotationRecognizer
{
    
}

- (void)tapDetected:(UITapGestureRecognizer *)tapRecognizer
{
    if (![tabla isHidden]) {
        [self CameraToggleButtonPressed:nil];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void) CameraSetOutputProperties
{
	//SET THE CONNECTION PROPERTIES (output properties)
	AVCaptureConnection *CaptureConnection = [MovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
	
	//Set landscape (if required)
	if ([CaptureConnection isVideoOrientationSupported])
	{
		AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationLandscapeRight;
        //<<<<<SET VIDEO ORIENTATION IF LANDSCAPE
		[CaptureConnection setVideoOrientation:orientation];
	}
	
    /*
     //Set frame rate (if requried)
     CMTimeShow(CaptureConnection.videoMinFrameDuration);
     CMTimeShow(CaptureConnection.videoMaxFrameDuration);
     
     if (CaptureConnection.supportsVideoMinFrameDuration)
     CaptureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
     if (CaptureConnection.supportsVideoMaxFrameDuration)
     CaptureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
     
     CMTimeShow(CaptureConnection.videoMinFrameDuration);
     CMTimeShow(CaptureConnection.videoMaxFrameDuration);
     */
}

- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position
{
	NSArray *Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *Device in Devices)
	{
		if ([Device position] == Position)
		{
			return Device;
		}
	}
	return nil;
}

- (IBAction)exitRec:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"recVideo_exit");}];
}

- (IBAction)CameraToggleButtonPressed:(id)sender
{
    if(![tabla isHidden]){
        [tabla setHidden:YES];
    }else{
        [tabla setHidden:NO];
    }
    
    if(WeAreRecording){
        [self StartStopButtonPressed:nil];
    }
    
    //Only do if device has multiple cameras
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1)
        {
            NSLog(@"Toggle camera");
            NSError *error;
            //AVCaptureDeviceInput *videoInput = [self videoInput];
            AVCaptureDeviceInput *NewVideoInput;
            AVCaptureDevicePosition position = [[VideoInputDevice device] position];
            
            if (position == AVCaptureDevicePositionBack)
            {
                NSLog(@"HDV_OFF");
                [session setSessionPreset:AVCaptureSessionPresetMedium];
                if ([session canSetSessionPreset:AVCaptureSessionPreset640x480])
                    [session setSessionPreset:AVCaptureSessionPreset640x480];
                
                NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionFront] error:&error];
            }
            else if (position == AVCaptureDevicePositionFront)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if([[defaults objectForKey:@"HDV"] boolValue]){
                    NSLog(@"HDV_ON");
                    [session setSessionPreset:AVCaptureSessionPresetHigh];
                    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
                        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
                }else{
                    NSLog(@"HDV_OFF");
                    [session setSessionPreset:AVCaptureSessionPresetMedium];
                    if ([session canSetSessionPreset:AVCaptureSessionPreset640x480])
                        [session setSessionPreset:AVCaptureSessionPreset640x480];
                }
                
                NewVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionBack] error:&error];
            }
            
            if (NewVideoInput != nil)
            {
                //We can now change the inputs and output configuration.  Use commitConfiguration to end
                [session beginConfiguration];
                [session removeInput:VideoInputDevice];
                if ([session canAddInput:NewVideoInput])
                {
                    VideoInputDevice = NewVideoInput;
                    [session addInput:VideoInputDevice];
                }
                else
                {
                    [session addInput:VideoInputDevice];
                }
                
                //Set the connection properties again
                //[self CameraSetOutputProperties];
                
                videoConnection = nil;
                for (AVCaptureConnection *connection in stillImageOutput.connections)
                {
                    for (AVCaptureInputPort *port in [connection inputPorts])
                    {
                        if ([[port mediaType] isEqual:AVMediaTypeVideo] )
                        {
                            videoConnection = connection;
                            break;
                        }
                    }
                    if (videoConnection) { break; }
                }
                
                [session commitConfiguration];
                [self StartStopButtonPressed:nil];
            }
        }
    });
}

- (IBAction)StartStopButtonPressed:(id)sender
{
	if (!WeAreRecording)
	{
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   [NSString stringWithFormat:@"%@.mov", [self genRandStringLength:20]],
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
                sqlite3_bind_text(compiledStatement, 2, [locationIni UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 3, [locationFin UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 4, [@"VIDEO" UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 5, [dateToday UTF8String], -1, SQLITE_TRANSIENT);
            }
            
            if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
                sqlite3_finalize(compiledStatement);
            }
        }
        
        sqlite3_close(database);
        
        [recVideo setHidden:YES];
        [stopVideo setHidden:NO];
        
		//----- START RECORDING -----
		NSLog(@"START RECORDING");
        [timerExample4 reset];
        [timerExample4 start];
		WeAreRecording = YES;
		
		//Start recording
		[MovieFileOutput startRecordingToOutputFileURL:outputFileURL recordingDelegate:self];
	}
	else
	{
        [recVideo setHidden:NO];
        [stopVideo setHidden:YES];
        
		//----- STOP RECORDING -----
		NSLog(@"STOP RECORDING");
        [timerExample4 pause];
		WeAreRecording = NO;
        
		[MovieFileOutput stopRecording];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"uploadEventNotification" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"codigo", @"file.mp4", nil]];
	}
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
	  fromConnections:(NSArray *)connections
				error:(NSError *)error
{
	NSLog(@"didFinishRecordingToOutputFileAtURL - enter");
	
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
	{
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
		{
            RecordedSuccessfully = [value boolValue];
        }
    }
	if (RecordedSuccessfully)
	{
		//----- RECORDED SUCESSFULLY -----
        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
        
        /*
		ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
		if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
		{
			[library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
										completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 if (error)
                 {
                     
                 }else{
                     NSLog(@"end_rec");
                 }
             }];
		}
        */
	}
}

UIImage *imageFromSampleBuffer(CMSampleBufferRef sampleBuffer)
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer,0);
	
    // Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
	
    // Create a device-dependent RGB color space.
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
		if (colorSpace == NULL) {
            // Handle the error appropriately.
            return nil;
        }
    }
	
    // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
	
    // Create a Quartz direct-access data provider that uses data we supply.
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipFirst |
                                       kCGBitmapByteOrder32Little, dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
	
    // Create and return an image object to represent the Quartz image.
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
	
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	
    return image;
}

- (IBAction)getPic:(UIButton *)sender
{
    [sender setEnabled:NO];
    
	NSLog(@"about to request a capture from: %@", stillImageOutput);
	[stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
		 CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
		 if (exifAttachments)
		 {
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
		 }
         else
             NSLog(@"no attachments");
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         NSString *imageName = [NSString stringWithFormat:@"%@.png", [self genRandStringLength:20]];
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
         NSString *documentsDirectoryPath = [paths objectAtIndex:0];
         NSString *dataPath = [documentsDirectoryPath  stringByAppendingPathComponent:imageName];

         [imageData writeToFile:dataPath atomically:YES];
         
         NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:@"pawah.sqlite"];
         
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
                 sqlite3_bind_text(compiledStatement, 1, [imageName UTF8String], -1, SQLITE_TRANSIENT);
                 sqlite3_bind_text(compiledStatement, 2, [locationIni UTF8String], -1, SQLITE_TRANSIENT);
                 sqlite3_bind_text(compiledStatement, 3, [locationFin UTF8String], -1, SQLITE_TRANSIENT);
                 sqlite3_bind_text(compiledStatement, 4, [@"FOTO" UTF8String], -1, SQLITE_TRANSIENT);
                 sqlite3_bind_text(compiledStatement, 5, [dateToday UTF8String], -1, SQLITE_TRANSIENT);
             }
             
             if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
                 sqlite3_finalize(compiledStatement);
             }
             
             [sender setEnabled:YES];
             
             self.badgeOne.value++;
         }
         
         sqlite3_close(database);
	 }];
}

- (NSString *)genRandStringLength:(int)len {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchTweets
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        [NSURL URLWithString: @"https://server/tweets.php"]]; //Fake tweetLine
        
        NSError* error;
        
        tweets = [NSJSONSerialization JSONObjectWithData:data
                                                 options:kNilOptions
                                                   error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%lu", (unsigned long)[tweets count]);
            [tabla reloadData];
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TweetCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tweet = [tweets objectAtIndex:indexPath.row];
    NSString *text = [tweet objectForKey:@"text"];
    NSString *name = [[tweet objectForKey:@"user"] objectForKey:@"name"];
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"by %@", name];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
