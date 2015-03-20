//
//  KLLoginFormViewController.h
//  Klike
//
//  Created by admin on 08/03/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KLLoginFormViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (nonatomic, weak) IBOutlet UIView *submitLoadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSubmitButtonPin;
@property (nonatomic, assign) id<KLChildrenViewControllerDelegate> kl_parentViewController;

@property (nonatomic, assign) CGFloat keyboardFrameHeight;

- (IBAction)onSubmit:(id)sender;
- (void)dissmissViewController;

- (void)animateFormApearenceWithKeyaboardHeight:(CGFloat)height
                                       duration:(NSTimeInterval)duration;


@end
