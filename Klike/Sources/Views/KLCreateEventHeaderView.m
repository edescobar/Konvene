//
//  KLCreateEventHeaderView.m
//  Klike
//
//  Created by admin on 06/04/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLCreateEventHeaderView.h"

@interface KLCreateEventHeaderView ()

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation KLCreateEventHeaderView

static CGFloat klwithImageHeight = 176.;

- (void)setBackImage:(UIImage *)backImage
{
    if (backImage) {
        if (!self.gradientLayer) {
            self.gradientLayer = [self grayGradient];
            self.gradientLayer.frame = self.photoImageView.frame;
            [self.photoImageView.layer addSublayer:self.gradientLayer];
        }
        self.photoImageView.image = backImage;
        self.addPhotoLabel.hidden = YES;
        self.addPhotoButton.hidden = YES;
        self.editPhotoButton.hidden = NO;
        self.heightConstraint.constant = klwithImageHeight;
    }
}

- (void)setLoadableBackImage:(PFFile *)backImage
{
    if (backImage) {
        if (!self.gradientLayer) {
            self.gradientLayer = [self grayGradient];
            self.gradientLayer.frame = self.photoImageView.frame;
            [self.photoImageView.layer addSublayer:self.gradientLayer];
        }
        self.photoImageView.file = backImage;
        [self.photoImageView loadInBackground];
        self.addPhotoLabel.hidden = YES;
        self.addPhotoButton.hidden = YES;
        self.editPhotoButton.hidden = NO;
        self.heightConstraint.constant = klwithImageHeight;
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

- (UIView *)flexibleView
{
    return self.photoImageView;
}

@end
