//
//  VisorVC.m
//  PAWAH
//
//  Created by Jean Dieu on 7/27/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "VisorVC.h"
#import "sqlite3.h"
#import "AVFoundation/AVFoundation.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface VisorVC ()

@end

@implementation VisorVC

@synthesize id_media, player, layer, urlVideo, theAudio;

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
    
    isPhoto = NO;
    isAudio = NO;
    
    [_cargando stopAnimating];
    
    [_play_btn setHidden:YES];
    
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            [label setFont:[UIFont fontWithName:@"AvenirNext-Bold" size:15]];
            [label sizeToFit];
        }
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"pawah.sqlite"];
    
    sqlite3 *database;
    
    if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT id, url, location_ini, location_fin, tipo, fecha, uploaded FROM id_registros WHERE id=%@ ORDER BY tipo DESC", id_media] UTF8String];
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                [_file_name setText:[NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 1)]];
                
                if([[NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 4)] isEqualToString:@"FOTO"]){
                    
                    isPhoto = YES;
                    
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 1)]]];
                    
                    UIImageView *foto = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.content.frame.size.width, self.content.frame.size.height)];
                    [foto setImage:[UIImage imageWithData:data]];
                    [foto setContentMode:UIViewContentModeScaleToFill];
                    [self.content addSubview:foto];
                }else{
                    
                    urlVideo = [NSURL fileURLWithPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 1)]]];
                    
                    player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[documentsPath stringByAppendingPathComponent:[NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 1)]]]];
                    
                    layer = [AVPlayerLayer layer];
                    
                    [layer setPlayer:player];
                    [layer setFrame:CGRectMake(0, 0, self.content.frame.size.width, self.content.frame.size.height)];
                    [layer setBackgroundColor:[UIColor redColor].CGColor];
                    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                    
                    [player addObserver:self forKeyPath:@"rate" options:0 context:nil];
                    
                    [self.content.layer addSublayer:layer];
                    //[player play];
                    
                    if([[NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 4)] isEqualToString:@"AUDIO"]){
                        
                        isAudio = YES;
                        
                        theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:urlVideo error:NULL];
                        [theAudio setDelegate:self];
                        theAudio.volume = 1.0;
                        
                        UIImageView *foto = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"galeria_img_archivosaudio"]];
                        [foto setFrame:CGRectMake(0, 0, self.content.frame.size.width, self.content.frame.size.height)];
                        [foto setContentMode:UIViewContentModeScaleAspectFill];
                        [self.content addSubview:foto];
                    }
                }
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag
{
    [_play_btn setHidden:NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        if ([player rate]) {
            [_play_btn setHidden:YES];
        }
        else {
            [_play_btn setHidden:NO];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    player = nil;
    layer = nil;
}

#pragma IBActions

- (IBAction)playMedia:(id)sender
{
    MPMoviePlayerViewController *playerC = [[MPMoviePlayerViewController alloc] initWithContentURL:urlVideo];
    playerC.view.frame = self.view.bounds;
    [self presentMoviePlayerViewControllerAnimated:playerC];
    playerC.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    playerC.moviePlayer.shouldAutoplay = YES;
    [playerC.moviePlayer prepareToPlay];
    playerC.moviePlayer.fullscreen=YES;
    playerC = nil;
}

- (IBAction)exit:(id)sender
{
    if(sender!=nil){
        [player pause];
        [player removeObserver:self forKeyPath:@"rate"];
        [layer removeFromSuperlayer];
    }
    
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"visor_exit");}];
}

- (IBAction)sendAlbum:(id)sender
{
    [_cargando startAnimating];
    
    NSString *imageName = [NSString stringWithFormat:@"%@", _file_name.text];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectoryPath  stringByAppendingPathComponent:imageName];
    
    NSLog(@"%@", dataPath);
    
    NSURL *outputFileURL = [NSURL URLWithString:dataPath];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:dataPath];
    
    if(isPhoto){
        UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data],nil,nil,nil);
        [_cargando stopAnimating];
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                initWithTitle:@"PAWAH"
                                message:@"Archivo guardado con éxito"
                                delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
        [errorAlert show];
    }else{
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                        completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 [_cargando stopAnimating];
                 if (error)
                 {
                     
                 }else{
                     UIAlertView *errorAlert = [[UIAlertView alloc]
                                                initWithTitle:@"PAWAH"
                                                message:@"Archivo guardado con éxito"
                                                delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
                     [errorAlert show];
                 }
             }];
        }
    }
}

- (IBAction)deleteID:(UIButton *)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"pawah.sqlite"];
    
    sqlite3 *database;
    if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        const char *sqlUpdate = "delete from id_registros WHERE id=?";
        
        sqlite3_stmt *compiledStatement_update;
        
        if(sqlite3_prepare_v2(database, sqlUpdate, -1, &compiledStatement_update, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(compiledStatement_update, 1, [id_media UTF8String], -1, SQLITE_TRANSIENT);
        }
        
        if(sqlite3_step(compiledStatement_update) == SQLITE_DONE) {
            [player pause];
            [player removeObserver:self forKeyPath:@"rate"];
            [layer removeFromSuperlayer];
            NSLog(@"delete_ok...");
            NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", _file_name.text]];
            unlink([pathToMovie UTF8String]);
            [self exit:nil];
        }
    }
    sqlite3_close(database);
}

@end
