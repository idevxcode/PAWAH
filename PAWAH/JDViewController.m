//
//  JDViewController.m
//  PAWAH
//
//  Created by Jean Dieu on 6/24/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "JDViewController.h"
#import "TourVC.h"
#import "HomeVC.h"

@interface JDViewController ()

@end

@implementation JDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if(![[defaults objectForKey:@"tour_view"] boolValue]){
            TourVC *tourViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tour"];
            tourViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:tourViewController animated:YES completion:^(void){
                NSLog(@"tour_view");
            }];
        }else{
            HomeVC *homeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Home"];
            homeViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
            [self presentViewController:homeViewController animated:YES completion:^(void){
                NSLog(@"home_view");
            }];
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
