//
//  GaleriaVC.m
//  PAWAH
//
//  Created by Jean Dieu on 7/22/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "GaleriaVC.h"
#import "sqlite3.h"
#import "VisorVC.h"
#import <AVFoundation/AVFoundation.h>

@interface GaleriaVC ()

@end

@implementation GaleriaVC

@synthesize files;

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"pawah.sqlite"];
    
    sqlite3 *database;
    
    files = [[NSMutableArray alloc] initWithCapacity:0];
    
    if(sqlite3_open([filePath UTF8String], &database) == SQLITE_OK) {
        sqlite3_stmt *compiledStatement;
        const char *sqlStatement = [[NSString stringWithFormat:@"SELECT id, url, location_ini, location_fin, tipo, fecha, uploaded FROM id_registros ORDER BY tipo DESC"] UTF8String];
        if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                [files addObject:[[NSMutableArray alloc] initWithObjects:[NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 0)], [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 1)], [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 2)], [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 3)], [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 4)], [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 5)], [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 6)], nil]];
            }
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
    for(UIView *subview in [_contAudios subviews]) {
        [subview removeFromSuperview];
    }
    
    for(UIView *subview in [_contFotos subviews]) {
        [subview removeFromSuperview];
    }
    
    for(UIView *subview in [_contVideos subviews]) {
        [subview removeFromSuperview];
    }
    
    for(int i=0; i<(int)[files count]; i++){
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 26, 76, 76)];
        
        [btn setAccessibilityHint:[[files objectAtIndex:i] objectAtIndex:0]];
        [btn addTarget:self action:@selector(showMedia:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *mediaLink = [documentsPath stringByAppendingPathComponent:[[files objectAtIndex:i] objectAtIndex:1]];
        
        if([[[files objectAtIndex:i] objectAtIndex:4] isEqualToString:@"AUDIO"]){
            [btn setImage:[UIImage imageNamed:@"galeria_img_archivosaudio"] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(((99*[_contAudios.subviews count])+23), 26, 76, 76)];
            [_contAudios addSubview:btn];
        }else if([[[files objectAtIndex:i] objectAtIndex:4] isEqualToString:@"FOTO"]){
            
            
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:mediaLink];
            
            [btn setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(((99*[_contFotos.subviews count])+23), 26, 76, 76)];
            [_contFotos addSubview:btn];
        }else if([[[files objectAtIndex:i] objectAtIndex:4] isEqualToString:@"VIDEO"]){

            NSURL *videoURL = [NSURL fileURLWithPath:mediaLink];
            
            AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
            AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
            generate1.appliesPreferredTrackTransform = YES;
            NSError *err = NULL;
            
            UIImage *one = [[UIImage alloc] init];
            
            if (CMTimeGetSeconds(asset1.duration)>1) {
                CMTime time = CMTimeMake(0, CMTimeGetSeconds(asset1.duration));
                CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
                one = [[UIImage alloc] initWithCGImage:oneRef];
                CFRelease(oneRef);
            }else{
                one = [UIImage imageNamed:@"none"];
            }
            
            [btn setImage:one forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(((99*[_contVideos.subviews count])+23), 26, 76, 76)];
            [_contVideos addSubview:btn];
        }
    }
    
    [_contAudios setContentSize:CGSizeMake(((99*[_contAudios.subviews count])+23), 128)];
    [_contFotos setContentSize:CGSizeMake(((99*[_contFotos.subviews count])+23), 128)];
    [_contVideos setContentSize:CGSizeMake(((99*[_contVideos.subviews count])+23), 128)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma IBActions

- (IBAction)exit:(id)sender
{
    for(UIView *subview in [_contAudios subviews]) {
        [subview removeFromSuperview];
    }
    
    for(UIView *subview in [_contFotos subviews]) {
        [subview removeFromSuperview];
    }
    
    for(UIView *subview in [_contVideos subviews]) {
        [subview removeFromSuperview];
    }
    
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"galeria_exit");}];
}

- (IBAction)showMedia:(UIButton *)sender
{
    NSLog(@"id:%@", sender.accessibilityHint);
    VisorVC *visorVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Visor"];
    visorVC.id_media = sender.accessibilityHint;
    
    [self presentViewController:visorVC animated:YES completion:^(void){NSLog(@"show_visor");}];
}

@end
