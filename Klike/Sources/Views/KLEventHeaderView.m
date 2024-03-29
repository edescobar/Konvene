//
//  KLEventHeaderView.m
//  Klike
//
//  Created by admin on 28/04/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLEventHeaderView.h"

@interface KLEventHeaderView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation KLEventHeaderView

- (UIView *)flexibleView
{
    return self.eventImageView;
}

- (void)configureWithEvent:(KLEvent *)event
{
    if (event.backImage) {
        self.eventImageView.file = event.backImage;
        [self.eventImageView loadInBackground];
        if (!self.gradientLayer) {
            self.gradientLayer = [self grayGradient];
            self.gradientLayer.frame = self.eventImageView.frame;
            [self.eventImageView.layer addSublayer:self.gradientLayer];
        } else {
            self.gradientLayer.frame = self.eventImageView.frame;
        }
    }
}

- (CAGradientLayer *)grayGradient
{
    UIColor *topColor = [UIColor colorWithWhite:0.
                                          alpha:0.5];
    UIColor *bottomColor = [UIColor clearColor];
    return [UIImage gradientLayerWithTopColor:topColor
                                  bottomColor:bottomColor];
}

@end
