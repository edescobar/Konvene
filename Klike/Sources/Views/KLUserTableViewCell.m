//
//  KLUserTableViewCell.m
//  Klike
//
//  Created by Дмитрий Александров on 01.04.15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLUserTableViewCell.h"
@interface KLUserTableViewCell ()
{
    IBOutlet PFImageView *_imagePhoto;
    IBOutlet UILabel *_labelUserInitials;
    IBOutlet UILabel *_labelUserName;
    IBOutlet UIButton *_buttonFollow;
    
}
@end

@implementation KLUserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configureWithUser:(KLUserWrapper *)user {
    self.user = user;
    _labelUserName.text = user.fullName;
    NSMutableString * firstCharacters = [NSMutableString string];
    NSArray * words = [user.fullName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSString * word in words) {
        if ([word length] > 0) {
            NSString * firstLetter = [word substringToIndex:1];
            [firstCharacters appendString:[firstLetter uppercaseString]];
        }
    }
    _labelUserInitials.text = firstCharacters;
    if (user.userImage) {
        _imagePhoto.file = user.userImage;
        [_imagePhoto loadInBackground];
    } else {
        _imagePhoto.image = [UIImage new];
    }
    [self styleFollowButton];
    [self update];
}

- (void)styleFollowButton
{
    _buttonFollow.layer.cornerRadius = 12;
    _buttonFollow.layer.borderWidth = 2;
    _buttonFollow.layer.borderColor = [UIColor colorFromHex:0x6466ca].CGColor;
    [_buttonFollow setTitle:@"Follow" forState:UIControlStateNormal];
    [_buttonFollow setTitle:@"Followed" forState:UIControlStateHighlighted];
    [_buttonFollow setTitleColor:[UIColor colorFromHex:0x6466ca] forState:UIControlStateNormal];
    [_buttonFollow setTitleColor:[UIColor colorFromHex:0xffffff] forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onFollowClicked:(id)sender {
    [self.delegate cellDidClickFollow:self];
}

- (void)update
{
    if ([[KLAccountManager sharedManager] isFollowing:self.user]) {
        _buttonFollow.highlighted = YES;
        _buttonFollow.backgroundColor = [UIColor colorFromHex:0x6466ca];
    }else {
        _buttonFollow.highlighted = NO;
        _buttonFollow.backgroundColor = [UIColor colorFromHex:0xffffff];
    }
}

@end
