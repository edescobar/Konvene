//
//  KLExplorePeopleCell.m
//  Klike
//
//  Created by admin on 22/04/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLExplorePeopleCell.h"

@interface KLExplorePeopleCell ()

@property (nonatomic, strong) KLUserWrapper *user;

@end

@implementation KLExplorePeopleCell

- (void)awakeFromNib
{
    self.followButton.layer.cornerRadius = 12;
    self.followButton.layer.borderWidth = 1.5;
    self.followButton.layer.borderColor = [UIColor colorFromHex:0x6466ca].CGColor;
    
    [self.userImageView kl_fromRectToCircle];
    [self.initialsLabel kl_fromRectToCircle];
}

- (void)configureWithUser:(KLUserWrapper *)user
{
    self.user = user;
    if (user.userImage) {
        self.userImageView.image = nil;
        self.userImageView.hidden = NO;
        self.userImageView.file = user.userImage;
        [self.userImageView loadInBackground];
    } else {
        self.userImageView.hidden = YES;
    }
    self.userNameLabel.text = user.fullName;
    self.initialsLabel.text = [user getInitials];
}

@end
