//
//  ComoUsarVC.m
//  PAWAH
//
//  Created by Jean Dieu on 8/2/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "ComoUsarVC.h"
#import "CreditosVC.h"

@interface ComoUsarVC ()

@end

@implementation ComoUsarVC

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
    
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UITextView class]]) {
            UITextView *label = (UITextView *)subview;
            [label setFont:[UIFont fontWithName:@"Rockwell" size:12]];
        }
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            [label setFont:[UIFont fontWithName:@"Rockwell" size:[label.font pointSize]]];
        }
    }
    
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour1"]];
	[self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour2"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour3"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Tour6"]];
}

- (IBAction)exit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"comoUsar_exit");}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showCreditos:(id)sender
{
    CreditosVC *creditosVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Creditos"];
    [self presentViewController:creditosVC animated:YES completion:^(void){NSLog(@"show_creditos");}];
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
