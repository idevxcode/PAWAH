//
//  RecVideoVC.h
//  PAWAH
//
//  Created by Jean Dieu on 6/30/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MZTimerLabel.h"
#import "MKNumberBadgeView.h"

#define CAPTURE_FRAMES_PER_SECOND 20

@interface RecVideoVC : UIViewController <AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate, MZTimerLabelDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UITableViewDataSource, UITableViewDelegate>
{
    BOOL WeAreRecording;
	
	AVCaptureSession *CaptureSession;
	AVCaptureMovieFileOutput *MovieFileOutput;
	AVCaptureDeviceInput *VideoInputDevice;
    AVCaptureSession *session;
    AVCaptureConnection *videoConnection;
    AVCaptureStillImageOutput *stillImageOutput;
    
    IBOutlet UIButton *recVideo;
    IBOutlet UIButton *stopVideo;
    IBOutlet UIButton *btnHide;
    IBOutlet UIButton *takePhoto;
    
    MZTimerLabel *timerExample4;
    
    IBOutlet NSString *locationIni;
    IBOutlet NSString *locationFin;
    
    IBOutlet NSArray *tweets;
    IBOutlet UITableView *tabla;
}

@property(nonatomic, retain) IBOutlet UIView *vImagePreview;
@property(nonatomic, retain) IBOutlet UIImageView *photo;
@property(nonatomic, retain) IBOutlet AVCaptureStillImageOutput *stillImageOutput;

@property (retain) AVCaptureVideoPreviewLayer *PreviewLayer;

@property(nonatomic, retain) IBOutlet UIButton *recVideo;
@property(nonatomic, retain) IBOutlet UIButton *stopVideo;
@property(nonatomic, retain) IBOutlet UIButton *btnHide;
@property(nonatomic, retain) IBOutlet UIButton *takePhoto;

@property (weak, nonatomic) IBOutlet UILabel *lblTimerExample4;

@property (nonatomic, retain) IBOutlet NSString *locationIni;
@property (nonatomic, retain) IBOutlet NSString *locationFin;

@property (retain) IBOutlet MKNumberBadgeView* badgeOne;

@property (nonatomic, retain) IBOutlet UITableView *tabla;
@property (nonatomic, retain) IBOutlet NSArray *tweets;

- (void) CameraSetOutputProperties;
- (AVCaptureDevice *) CameraWithPosition:(AVCaptureDevicePosition) Position;
- (IBAction)StartStopButtonPressed:(id)sender;
- (IBAction)CameraToggleButtonPressed:(id)sender;

- (void)fetchTweets;

@end
