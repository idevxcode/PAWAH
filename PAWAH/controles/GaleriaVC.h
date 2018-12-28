//
//  GaleriaVC.h
//  PAWAH
//
//  Created by Jean Dieu on 7/22/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GaleriaVC : UIViewController
{
    IBOutlet NSMutableArray *files;
}

@property (nonatomic, retain) IBOutlet NSMutableArray *files;

@property (nonatomic, retain) IBOutlet UIScrollView *contVideos;
@property (nonatomic, retain) IBOutlet UIScrollView *contFotos;
@property (nonatomic, retain) IBOutlet UIScrollView *contAudios;

@end
