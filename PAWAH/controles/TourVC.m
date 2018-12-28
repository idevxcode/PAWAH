//
//  TourVC.m
//  ProgressGold
//
//  Created by Jean Dieu on 1/31/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "TourVC.h"
#import "CreditosVC.h"

@interface TourVC ()

@end

@implementation TourVC

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
    
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour1"]];
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour2"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour3"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour6"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour4"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour5"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)showCreditos:(id)sender
{
    CreditosVC *creditosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Creditos"];
    [self presentViewController:creditosVC animated:YES completion:^(void){NSLog(@"show_creditos");}];
}

@end
