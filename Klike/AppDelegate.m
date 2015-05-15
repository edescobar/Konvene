//
//  AppDelegate.m
//  Klike
//
//  Created by Yarik Smirnov on 2/27/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import "KLLoginViewController.h"
#import "KLTabViewController.h"
#import "KLAccountManager.h"
#import "KLLoginManager.h"
#import "Stripe.h"

static NSString *HOCKEY_APP_ID = @"92c9bd20cc7f211030770676bfccdbe0";
static NSString *klParseApplicationId = @"1V5JZTeeZ542nlDbDrq8cMYUJt34SSNDeOyUfJy8";
static NSString *klParseClientKey = @"39cpW1MC1BJNERQtB9c8SJgREsW87SQkpdjsisfG";
static NSString *klForsquareClientId = @"J4NE02UOCLIRQ2ZDB4EZ55MBPATTE302R3RDQSVZELJS2E3F";
static NSString *klForsquareClientSecret = @"DIREMPJJQBBQZVB54AZODCRRUUCRJMPPAAY2RPBDOICQZICW";
static NSString *klStripePublishKey = @"pk_test_4ZGECql8uXlAP2irRMNXoWY7";

@interface AppDelegate ()
@property(nonatomic, strong) KLTabViewController *mainVC;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [self initializServices];
    [self initializeModelManagers];
    [self configureAppearance];
    
    self.mainVC = (KLTabViewController *)self.window.rootViewController;
    if (![[KLAccountManager sharedManager] isCurrentUserAuthorized]) {
        self.window.rootViewController = [[KLLoginViewController alloc] init];
        [self.window makeKeyAndVisible];
        self.window.rootViewController = self.mainVC;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentLoginUIAnimated:NO];
        });
    } else {
        [[KLAccountManager sharedManager] updateUserData:^(BOOL succeeded, NSError *error) {
            //TODO add check
        }];
    }
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    
    __weak typeof(self) weakSelf = self;
    [self subscribeForNotification:klAccountManagerLogoutNotification
                         withBlock:^(NSNotification *notification) {
        [weakSelf presentLoginUIAnimated:YES];
    }];
    
    return YES;
}

- (void)initializeModelManagers
{
    [Parse setApplicationId:klParseApplicationId
                  clientKey:klParseClientKey];
    [KLAccountManager sharedManager];
    [KLLoginManager sharedManager];
}

- (void)initializServices
{
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:HOCKEY_APP_ID];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    [BITHockeyManager sharedHockeyManager].disableUpdateManager = YES;
    [Foursquare2 setupFoursquareWithClientId:klForsquareClientId
                                      secret:klForsquareClientSecret
                                 callbackURL:@""];
    [Stripe setDefaultPublishableKey:klStripePublishKey];
}

- (void)configureAppearance
{
    [UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil].tintColor = [UIColor colorFromHex:0x6466ca];
    
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setBarStyle:UIBarStyleDefault];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorFromHex:0x1d2027]
                                                                 size:CGSizeMake(screenRect.size.width, 49.)]];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageWithColor:[UIColor colorFromHex:0x6466ca]
                                                                         size:CGSizeMake(screenRect.size.width/5, 49.)]];
}

- (void)presentLoginUIAnimated:(BOOL)animated
{
    KLLoginViewController *loginVC = [[KLLoginViewController alloc] init];
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self.mainVC presentViewController:navigationVC animated:animated completion:nil];
}

@end
