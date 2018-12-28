//
//  VisorVC.h
//  PAWAH
//
//  Created by Jean Dieu on 7/27/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"
#import <MediaPlayer/MediaPlayer.h>

@interface VisorVC : UIViewController <AVAudioPlayerDelegate>
{
    IBOutlet NSString *id_media;
    BOOL isPhoto;
    BOOL isAudio;
    AVPlayer *player;
    AVPlayerLayer *layer;
    NSURL *urlVideo;
}

@property (nonatomic, retain) IBOutlet NSString *id_media;
@property (nonatomic, retain) IBOutlet UILabel *file_name;
@property (nonatomic, retain) IBOutlet UIView *content;
@property (nonatomic, retain) IBOutlet UIButton *play_btn;
@property (nonatomic, retain) AVPlayer *player;
@property (nonatomic, retain) AVPlayerLayer *layer;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *cargando;
@property (nonatomic, retain) NSURL *urlVideo;
@property (nonatomic, retain) AVAudioPlayer *theAudio;

@end
