//
//  KLEventLocationCell.m
//  Klike
//
//  Created by Anton Katekov on 07.05.15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLEventLocationCell.h"
#import "KLLocation.h"


@implementation KLEventLocationCell

- (void)configureWithEvent:(KLEvent *)event
{
    [super configureWithEvent:event];
    KLUserWrapper *currentUser = [[KLAccountManager sharedManager] currentUser];
    
    if (event.location && event.location.isDataAvailable) {
        KLLocation *eventVenue = [[KLLocation alloc] initWithObject:event.location];
        _labelPlaceName.text = eventVenue.name;
        PFObject *userPlace = currentUser.place;
        if (userPlace.isDataAvailable) {
            KLLocation *userVenue = [[KLLocation alloc] initWithObject:currentUser.place];
            CLLocationDistance distance = [userVenue distanceTo:eventVenue];
            NSString *milesString = [NSString stringWithFormat:SFLocalized(@"event.location.distance"), distance*0.000621371];//Convert to miles
            _labelPlaceDistance.hidden = NO;
            _labelPlaceDistance.text = milesString;
        } else {
            _labelPlaceDistance.hidden = YES;
        }
    }
}

@end
