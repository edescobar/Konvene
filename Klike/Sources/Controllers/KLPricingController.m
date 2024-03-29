//
//  KLPricingController.m
//  Klike
//
//  Created by admin on 10/04/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLPricingController.h"
#import "KLFreePricingController.h"
#import "KLPayedPricingController.h"
#import "KLThrowPricingController.h"
#import "KLEventManager.h"
#import "KLInviteFriendsViewController.h"
#import "AppDelegate.h"



@interface KLPricingController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) KLEvent *event;

@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *nextButton;

@property (nonatomic, strong) KLFreePricingController *freePricingController;
@property (nonatomic, strong) KLPayedPricingController *payedPricingController;
@property (nonatomic, strong) KLThrowPricingController *throwPricingController;

@end

@implementation KLPricingController

- (instancetype)initWithEvent:(KLEvent *)event
{
    if (self = [super init]) {
        self.event = event;
        self.freePricingController = [[KLFreePricingController alloc] init];
        self.payedPricingController = [[KLPayedPricingController alloc] init];
        self.throwPricingController = [[KLThrowPricingController alloc] init];
        self.childControllers = @[self.freePricingController, self.payedPricingController, self.throwPricingController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:[UIColor colorFromHex:0x6465c6]];
    
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"]
                                                        style:UIBarButtonItemStyleDone
                                                       target:self
                                                       action:@selector(onBack)];
    self.backButton.tintColor = [UIColor colorFromHex:0x6466ca];
    self.navigationItem.leftBarButtonItem = self.backButton;
    
    self.nextButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"event_right_arr_whight"]
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(onNext)];
    self.navigationItem.rightBarButtonItem = self.nextButton;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self kl_setNavigationBarColor:[UIColor whiteColor]];
    [self kl_setTitle:SFLocalized(@"PRICING") withColor:[UIColor blackColor]];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

#pragma mark - Action

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onNext
{
    NSInteger pricingType = self.segmentedControl.selectedSegmentIndex;
    switch (pricingType) {
        case KLEventPricingTypePayed:{
            self.event.price = self.payedPricingController.pricingView.price;
        }break;
        case KLEventPricingTypeThrow:{
            self.event.price = self.throwPricingController.pricingView.price;
        }break;
        default:
            self.event.price = self.freePricingController.pricingView.price;
            break;
    }
    
    __weak typeof(self) weakSelf = self;
    [[KLEventManager sharedManager] uploadEvent:self.event toServer:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [weakSelf.delegate dissmissCreateEvent];
        }
        
        KLInviteFriendsViewController *vc = [[KLInviteFriendsViewController alloc] init];
        vc.inviteType = KLInviteTypeEvent;
        vc.isAfterSignIn = NO;
        vc.needBackButton = YES;
        vc.event = self.event;
        [ADI.currentNavigationController pushViewController:vc animated:YES];
    }];
    
}

@end
