//
//  DerechosVC.m
//  PAWAH
//
//  Created by Jean Dieu on 8/2/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import "DerechosVC.h"

@interface DerechosVC ()

@end

@implementation DerechosVC

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
    
    self.fileToDisplay = @"derechos";
    
    [self loadPrivacyPolicy];
    
    self.webView.delegate = self;
}

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    
    return YES;
}

- (void)loadPrivacyPolicy
{
    NSString *path = [[NSBundle mainBundle] pathForResource:self.fileToDisplay
                                                     ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^(void){NSLog(@"comoUsar_exit");}];
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
