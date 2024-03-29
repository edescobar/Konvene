//
//  KLActivityEventCell.m
//  Klike
//
//  Created by Alexey on 5/22/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLActivityEventCell.h"

@interface KLActivityEventCell ()
@property (weak, nonatomic) IBOutlet PFImageView *eventImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet PFImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation KLActivityEventCell

- (void)awakeFromNib
{
    [self.iconImageView kl_fromRectToCircle];
}

- (void)configureWithActivity:(KLActivity *)activity
{
    [super configureWithActivity:activity];
    KLEvent *event = self.activity.event;
    
    self.eventTitleLabel.text = event.title;
    if (event.backImage) {
        self.eventImageView.file = event.backImage;
        [self.eventImageView loadInBackground];
    } else {
        self.eventImageView.image = [UIImage imageNamed:@"event_pic_placeholder"];
    }
    
    KLUserWrapper *from = [[KLUserWrapper alloc] initWithUserObject:self.activity.from];
    
    UIFont *descriptionFont = [UIFont helveticaNeue:SFFontStyleRegular size:12.];
    UIColor *grayColor = [UIColor colorFromHex:0xb3b3bd];
    UIColor *purpleColor = [UIColor colorFromHex:0x6466ca];
    
    switch ([self.activity.activityType integerValue]) {
        case KLActivityTypeCreateEvent:{
            [self setUserImage:from];
            KLAttributedStringPart *fromStr = [[KLAttributedStringPart alloc] initWithString:from.fullName
                                                                                       color:purpleColor
                                                                                        font:descriptionFont];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:@" created event"
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[fromStr, description]];
        }break;
        case KLActivityTypeGoesToEvent:{
            [self setUserImage:from];
            KLAttributedStringPart *fromStr = [[KLAttributedStringPart alloc] initWithString:from.fullName
                                                                                       color:purpleColor
                                                                                        font:descriptionFont];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:@" goes to the event"
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[fromStr, description]];
        }break;
        case KLActivityTypeEventCanceled:{
            self.iconImageView.contentMode = UIViewContentModeCenter;
            self.iconImageView.image = [UIImage imageNamed:@"ic_activity_canceled"];
            KLAttributedStringPart *subjectStr = [[KLAttributedStringPart alloc] initWithString:@"Event has been"
                                                                                       color:[UIColor blackColor]
                                                                                        font:descriptionFont];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:@" canceled"
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[subjectStr, description]];
        }break;
        case KLActivityTypeEventChangedName:{
            self.iconImageView.contentMode = UIViewContentModeCenter;
            self.iconImageView.image = [UIImage imageNamed:@"ic_activity_settings"];
            KLAttributedStringPart *subjectStr = [[KLAttributedStringPart alloc] initWithString:@"Title"
                                                                                          color:[UIColor blackColor]
                                                                                           font:descriptionFont];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:@" changed"
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[subjectStr, description]];
        }break;
        case KLActivityTypeEventChangedLocation:{
            self.iconImageView.contentMode = UIViewContentModeCenter;
            self.iconImageView.image = [UIImage imageNamed:@"ic_activity_settings"];
            KLAttributedStringPart *subjectStr = [[KLAttributedStringPart alloc] initWithString:@"Location"
                                                                                          color:[UIColor blackColor]
                                                                                           font:descriptionFont];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:@" changed"
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[subjectStr, description]];
        }break;
        case KLActivityTypeEventChangedTime:{
            self.iconImageView.contentMode = UIViewContentModeCenter;
            self.iconImageView.image = [UIImage imageNamed:@"ic_activity_settings"];
            KLAttributedStringPart *subjectStr = [[KLAttributedStringPart alloc] initWithString:@"Time"
                                                                                          color:[UIColor blackColor]
                                                                                           font:descriptionFont];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:@" changed"
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[subjectStr, description]];
        }break;
        case KLActivityTypeCommentAdded:{
            self.iconImageView.contentMode = UIViewContentModeCenter;
            self.iconImageView.image = [UIImage imageNamed:@"ic_activity_comment"];
            KLAttributedStringPart *subjectStr = [[KLAttributedStringPart alloc] initWithString:@"Comment"
                                                                                          color:[UIColor blackColor]
                                                                                           font:descriptionFont];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:@" added"
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[subjectStr, description]];
        }break;
        case KLActivityTypePayForEvent:{
            [self setUserImage:from];
            KLAttributedStringPart *fromStr = [[KLAttributedStringPart alloc] initWithString:from.fullName
                                                                                       color:purpleColor
                                                                                        font:descriptionFont];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:@" paid for your event"
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[fromStr, description]];
        }break;
        case KLActivityTypeGoesToMyEvent:{
            self.iconImageView.contentMode = UIViewContentModeCenter;
            self.iconImageView.image = [UIImage imageNamed:@"ic_activity_go"];
            NSString *goesStr = [NSString stringWithFormat:@"%lu people go to your event", (unsigned long)self.activity.users.count];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:goesStr
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[description]];
        }break;
        case KLActivityTypePhotosAdded:{
            self.iconImageView.contentMode = UIViewContentModeCenter;
            self.iconImageView.image = [UIImage imageNamed:@"ic_activity_photo"];
            NSString *photoStr = [NSString stringWithFormat:@"%lu photos were added", (unsigned long)self.activity.photos.count];
            KLAttributedStringPart *description = [[KLAttributedStringPart alloc] initWithString:photoStr
                                                                                           color:grayColor
                                                                                            font:descriptionFont];
            self.descriptionLabel.attributedText = [KLAttributedStringHelper stringWithParts:@[description]];
        }break;
            
        default:
            break;
    }
}

- (void)setUserImage:(KLUserWrapper *)user
{
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    if (user.userImage) {
        self.iconImageView.file = user.userImage;
        [self.iconImageView loadInBackground];
    } else {
        self.iconImageView.image = [UIImage imageNamed:@"profile_pic_placeholder"];
    }
}

+ (NSString *)reuseIdentifier
{
    return @"ActivityEvent";
}

@end
