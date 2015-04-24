//
//  KLEventListController.h
//  Klike
//
//  Created by admin on 17/04/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLListViewController.h"

typedef enum : NSUInteger {
    KLEVEntListTypeGoing,
    KLEVEntListTypeSaved,
} KLEVEntListType;

@interface KLEventListController : KLListViewController

- (instancetype)initWithType:(KLEVEntListType)type;

@end