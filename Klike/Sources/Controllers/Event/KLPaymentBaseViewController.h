//
//  KLPaymentBaseViewController.h
//  Klike
//
//  Created by Anton Katekov on 14.05.15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>



@class KLPaymentPriceAmountView;
@class KLPaymentNumberAmountView;



@interface KLPaymentBaseViewController : UIViewController {
    IBOutlet UIImageView *_imageBackground1;
    IBOutlet UIImageView *_imageBackground2;
    IBOutlet UIImageView *_imageBackground;
    IBOutlet UILabel *_labelAmount;
    IBOutlet UILabel *_labelAmountDescription;
    IBOutlet UIButton *_button;
    IBOutlet UIView *_viewInputConyeny;
    IBOutlet UILabel *_labelHeader;
    
    IBOutlet NSLayoutConstraint *_constraintBottom;
    KLPaymentPriceAmountView *_viewPriceAmount;
    KLPaymentNumberAmountView *_viewNumberAmount;
    
    UIColor *_color;
}

@property (nonatomic) BOOL throwInStyle;
- (IBAction)onClose:(id)sender;

@end
