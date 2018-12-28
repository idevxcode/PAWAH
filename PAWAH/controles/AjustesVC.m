//
//  AjustesVC.m
//  PAWAH
//
//  Created by Jean Dieu on 7/23/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "AjustesVC.h"

@interface AjustesVC ()

@end

@implementation AjustesVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _swIdioma.on = [[defaults objectForKey:@"ES"] boolValue];
    _swVideo.on = [[defaults objectForKey:@"HDV"] boolValue];
    _swAudio.on = [[defaults objectForKey:@"HDA"] boolValue];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (IBAction)idiomaCh:(UISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_swIdioma.on forKey:@"ES"];
    [defaults synchronize];
}

- (IBAction)videoCh:(UISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_swVideo.on forKey:@"HDV"];
    [defaults synchronize];
}

- (IBAction)audioCh:(UISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_swAudio.on forKey:@"HDA"];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma IBActions

- (IBAction)exit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"ajustes_exit");}];
}

@end
