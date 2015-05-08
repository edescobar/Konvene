//
//  KLActivity.h
//  Klike
//
//  Created by Alexey on 5/8/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import <Parse/Parse.h>

@interface KLActivity : PFObject <PFSubclassing>

@property (nonatomic, strong) NSNumber *activityType;
@property (nonatomic, strong) KLEvent *event;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSArray *followings;
@property (nonatomic, strong) NSArray *photos;

@end