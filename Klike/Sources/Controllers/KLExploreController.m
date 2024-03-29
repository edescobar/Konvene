//
//  KLExploreController.m
//  Klike
//
//  Created by Alexey on 4/21/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLExploreController.h"
#import "KLExploreEventListController.h"
#import "KLExplorePeopleListController.h"
#import "KLSearchPeopleControllerTableViewController.h"

@interface KLExploreController () <KLExplorePeopleDelegate, KLExploreEventListDelegate, KLChildrenViewControllerDelegate>

@end

@implementation KLExploreController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        KLExploreEventListController *events = [[KLExploreEventListController alloc] init];
        events.delegate = self;
        KLExplorePeopleListController *people = [[KLExplorePeopleListController alloc] init];
        people.delegate = self;
        self.childControllers = @[events, people];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self kl_setNavigationBarColor:[UIColor whiteColor]];
    [self kl_setTitle:SFLocalized(@"explore.title") withColor:[UIColor blackColor]];
    self.navigationItem.hidesBackButton = YES;
}

#pragma mark - KLExplorePeopleDelegate methods

- (void)explorePeopleList:(KLExplorePeopleListController *)peopleListControler
          openUserProfile:(KLUserWrapper *)user
{
    [self showUserProfile:user];
}

- (void)presentSearchController
{
    KLSearchPeopleControllerTableViewController *searchController = [[KLSearchPeopleControllerTableViewController alloc] init];
    searchController.kl_parentViewController = self;
    UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:searchController];
    [self presentViewController:navVc animated:YES completion:nil];
    
}

#pragma mark - KLExploreEventListDelegate methods

- (void)exploreEventListOCntroller:(KLExploreEventListController *)controller
             showAttendiesForEvent:(KLEvent *)event
{
    [self showEventAttendies:event];
}

- (void)exploreEventListOCntroller:(KLExploreEventListController *)controller
                  showEventDetails:(KLEvent *)event
{
    [self showEventDetails:event];
}

- (void)viewController:(UIViewController *)viewController
      dissmissAnimated:(BOOL)animated
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
