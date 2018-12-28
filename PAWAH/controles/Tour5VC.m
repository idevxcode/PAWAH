//
//  Tour5VC.m
//  PAWAH
//
//  Created by Jean Dieu on 7/15/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "Tour5VC.h"

@interface Tour5VC ()

@end

@implementation Tour5VC

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma IBActions

- (IBAction)noAcepto:(id)sender
{
    exit(0);
}

- (IBAction)siAcepto:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"tour_view"];
    [defaults setBool:YES forKey:@"tour_exit"];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"tour_exit");}];
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
