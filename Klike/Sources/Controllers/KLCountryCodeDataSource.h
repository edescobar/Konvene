//
//  KLCountryCodeDataSource.h
//  Klike
//
//  Created by admin on 05/03/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "SFBasicDataSource.h"

@interface KLCountryCodeDataSource : SFBasicDataSource

- (NSString *)codeForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)keyForIndexPath:(NSIndexPath *)indexPath;

- (void)setLastUseedCode:(NSString *)code;

@end
