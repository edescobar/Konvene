//
//  KLExploreEventDataSource.m
//  Klike
//
//  Created by Alexey on 4/21/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLExploreEventDataSource.h"
#import "KLExploreEventCell.h"
#import "KLPlaceholderCell.h"

static NSString *klEventListCellReuseId = @"ExploreEventCell";

@interface KLExploreEventDataSource () <KLExploreEventCellDelegate>

@end

@implementation KLExploreEventDataSource

- (instancetype)init
{
    self =[super init];
    if (self) {
        self.placeholderView = [[KLPlaceholderCell alloc] initWithTitle:nil
                                                                message:@"Please define your location and we\n will offer you the best public events\nEVAR!"
                                                                  image:[UIImage imageNamed:@"empty_state"]
                                                            buttonTitle:nil
                                                           buttonAction:nil];
    }
    return self;
}

- (void)registerReusableViewsWithTableView:(UITableView *)tableView
{
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerNib:[UINib nibWithNibName:klEventListCellReuseId
                                          bundle:nil]
    forCellReuseIdentifier:klEventListCellReuseId];
}

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
                         inTableView:(UITableView *)tableView
{
    KLExploreEventCell *cell = (KLExploreEventCell *)[tableView dequeueReusableCellWithIdentifier:klEventListCellReuseId
                                                                               forIndexPath:indexPath];
    cell.delegate = self;
    [cell configureWithEvent:[self itemAtIndexPath:indexPath]];
    return cell;
}

- (PFQuery *)buildQuery
{
    KLUserWrapper *currentUser = [KLAccountManager sharedManager].currentUser;
    if(!currentUser) {
        return nil;
    }
    
    NSDate *minimalDate = [NSDate date];
    minimalDate = [minimalDate mt_dateHoursBefore:12];
    
    PFQuery *publicQuery = [KLEvent query];
    [publicQuery whereKey:sf_key(startDate) greaterThan:minimalDate];
    if (currentUser) {
        [publicQuery whereKey:sf_key(owner)
                   notEqualTo:currentUser.userObject];
    }
    [publicQuery whereKey:sf_key(privacy)
                  equalTo:@(KLEventPrivacyTypePublic)];
    
    PFQuery *privateQuery = [KLEvent query];
    [privateQuery whereKey:sf_key(startDate)
               greaterThan:minimalDate];
    if (currentUser) {
        [privateQuery whereKey:sf_key(owner)
                   notEqualTo:currentUser.userObject];
    }
    [privateQuery whereKey:sf_key(privacy)
                  containedIn:@[@(KLEventPrivacyTypePrivate), @(KLEventPrivacyTypePrivatePlus)]];
    [privateQuery whereKey:sf_key(invited)
                   equalTo:currentUser.userObject.objectId];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[publicQuery, privateQuery]];
    query.limit = 3;
        [query includeKey:sf_key(location)];
        [query includeKey:sf_key(price)];
    [query orderByDescending:sf_key(createdAt)];
    return query;
}

- (void)exploreEventCell:(KLExploreEventCell *)cell
   showAttendiesForEvent:(KLEvent *)event
{
    if (self.listDelegate && [self.listDelegate respondsToSelector:@selector(exploreEventDataSource:showAttendiesForEvent:)] ) {
        [self.listDelegate exploreEventDataSource:self
                            showAttendiesForEvent:event];
    }
}

@end
