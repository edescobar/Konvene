//
//  KLTicketViewController.m
//  Klike
//
//  Created by Anton Katekov on 14.05.15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLTicketViewController.h"
#import "KLEventPaymentFinishedPageCell.h"



@interface KLTicketViewController ()

@end

@implementation KLTicketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _image.image = [[_eventImage scaleToFillSize:_image.frame.size] filteredImage];
    CGSize sz = _image.frame.size;
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0, 0, sz.width, sz.height);
    maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"ticket_top_mask"] CGImage];
    _image.layer.mask = maskLayer;
    
    _labelEventName.text = _event.title;
    _labeCost.text = [NSString stringWithFormat:@"$%d", (int)_event.price.pricePerPerson.floatValue * [[KLEventManager sharedManager] boughtTicketsForEvent:self.event].intValue];
    _labelTicketNumber.text = [NSString stringWithFormat:@"%d Tickets", [[KLEventManager sharedManager] boughtTicketsForEvent:self.event].intValue];
    
    if (_event.location) {

//        KLUserWrapper *currentUser = [[KLAccountManager sharedManager] currentUser];
        
        KLLocation *eventVenue = [[KLLocation alloc] initWithObject:self.event.location];
        
//        PFObject *userPlace = currentUser.place;
//        KLLocation *userVenue = [[KLLocation alloc] initWithObject:currentUser.place];
//        CLLocationDistance distance = [userVenue distanceTo:eventVenue];
//        NSString *milesString = [NSString stringWithFormat:SFLocalized(@"event.location.distance"), distance*0.000621371];//Convert to miles
        _labelDistance.text = eventVenue.name;
        
    }
    else {
        _imagePin.hidden = YES;
        _labelDistance.hidden = YES;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    
    NSString *timeBefore = [dateFormatter stringFromDate:_event.startDate];
    _labelTime.text = timeBefore;
    
    if (self.event.isPastEvent) {
        CGAffineTransform tr = CGAffineTransformMakeRotation(-0.02);
        tr = CGAffineTransformTranslate(tr, 0, -8);
        _viewTop.transform = tr;
        
        
        tr = CGAffineTransformMakeRotation(0.02);
        tr = CGAffineTransformTranslate(tr, -2, 0);
        _viewBottom.transform = tr;
        
        _viewBottom.layer.borderWidth = 3;
        _viewBottom.layer.borderColor = [UIColor clearColor].CGColor;
        _viewBottom.layer.shouldRasterize = YES;
        
        _viewTop.layer.borderWidth = 3;
        _viewTop.layer.borderColor = [UIColor clearColor].CGColor;
        _viewTop.layer.shouldRasterize = YES;
    }
}

- (void)swipe:(UISwipeGestureRecognizer *)recognizer
{
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    self.dismissDirection = recognizer.direction;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
