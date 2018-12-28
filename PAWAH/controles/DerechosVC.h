//
//  DerechosVC.h
//  PAWAH
//
//  Created by Jean Dieu on 8/2/14.
//  Copyright (c) 2014 FMA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DerechosVC : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UILabel *titulo;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *fileToDisplay;

@end
