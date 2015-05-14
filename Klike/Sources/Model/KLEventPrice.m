//
//  KLEventPrice.m
//  Klike
//
//  Created by Alexey on 5/12/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLEventPrice.h"

static NSString *klEventPriceClassName = @"EventPrice";

@implementation KLEventPrice

@dynamic pricingType;
@dynamic pricePerPerson;
@dynamic minimumAmount;
@dynamic suggestedAmount;
@dynamic maximumTickets;
@dynamic throwIn;
@dynamic soldTickets;
@dynamic payments;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return klEventPriceClassName;
}

- (NSArray *)payments
{
    if (!self[sf_key(payments)]) {
        return [NSArray array];
    } else {
        return self[sf_key(payments)];
    }
}

@end