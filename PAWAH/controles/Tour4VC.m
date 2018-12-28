//
//  Tour4VC.m
//  PAWAH
//
//  Created by Jean Dieu on 6/25/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "Tour4VC.h"

@interface Tour4VC ()

@end

@implementation Tour4VC

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
