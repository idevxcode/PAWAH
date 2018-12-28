//
//  HomeVC.h
//  PAWAH
//
//  Created by Jean Dieu on 6/25/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MZTimerLabel.h"

@interface HomeVC : UIViewController <CLLocationManagerDelegate, UIImagePickerControllerDelegate, UIDocumentInteractionControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, MZTimerLabelDelegate>{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    AVAudioSession *session;
    NSMutableDictionary *recordSetting;
    
    MZTimerLabel *timerExample4;
    
    IBOutlet UIButton *btnVideo;
    IBOutlet UIButton *btnPhoto;
    IBOutlet UIButton *btnAudio;
    
    BOOL recording;
}

@property (strong, nonatomic) NSURL *videoURL;
@property (weak, nonatomic) IBOutlet UILabel *lblTimerExample4;

- (IBAction)takePhoto:(UIButton *)sender;
- (IBAction)captureVideo:(UIButton *)sender;
- (IBAction)recAudio:(UIButton *)sender;

@end
