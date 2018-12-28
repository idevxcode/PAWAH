//
//  ViewController.h
//  PageViewController
//
//  Created by Jean Dieu on 10/17/12.
//  Copyright (c) 2012 Jean Dieu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagerViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

- (IBAction)changePage:(id)sender;

- (void)previousPage;
- (void)nextPage;

- (void)changePageManual:(int)pagina;

@end
