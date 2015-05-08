//
//  KLActivity.m
//  Klike
//
//  Created by Alexey on 5/8/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLActivity.h"

static NSString *klActivityClassName = @"Activity";

@implementation KLActivity

@dynamic activityType;
@dynamic event;
@dynamic user;
@dynamic followings;
@dynamic photos;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return klActivityClassName;
}

@end