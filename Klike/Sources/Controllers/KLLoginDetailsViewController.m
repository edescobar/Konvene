//
//  KLLoginDetailsViewController.m
//  Klike
//
//  Created by admin on 11/03/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLLoginDetailsViewController.h"
#import "SFTextField.h"
#import "SFAlertMessageView.h"
#import "KLAccountManager.h"
#import "KLUserWrapper.h"
#import "KLLocationSelectTableViewController.h"
#import "KLLocation.h"
#import "KLInviteFriendsViewController.h"
#import "KLLocationManager.h"

@interface KLLoginDetailsViewController () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, KLLocationSelectTableViewControllerDelegate, KLChildrenViewControllerDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet SFTextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *userPhotoButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadPlaceIndicator;

@property (nonatomic, strong) KLUserWrapper *currentUser;
@property (nonatomic, strong) UIImage *userImage;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UIAlertView *locationAlert;
@property (nonatomic, assign) BOOL isFirstRun;
@end

static CGFloat klHalfSizeofImage = 32.;
static NSInteger klMaxNameLength = 30;
static NSInteger klMinNameLength = 3;

@implementation KLLoginDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentUser = [KLAccountManager sharedManager].currentUser;
    
    [self kl_setNavigationBarColor:nil];
    
    [self.userImageView.layer setCornerRadius:klHalfSizeofImage];
    [self.userImageView.layer setMasksToBounds:YES];
    [self.userPhotoButton.layer setCornerRadius:klHalfSizeofImage];
    [self.userPhotoButton.layer setMasksToBounds:YES];
    
    self.nameTextField.placeholder = SFLocalized(@"Full Name");
    self.nameTextField.font = [UIFont fontWithFamily:SFFontFamilyNameHelveticaNeue
                                               style:SFFontStyleRegular
                                                size:16.];
    self.nameTextField.placeholderColor = [UIColor colorFromHex:0x91919f];
    
    self.submitButton.enabled = NO;
    self.isFirstRun = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self kl_setTitle:SFLocalized(@"DETAILS") withColor:[UIColor blackColor]];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.isFirstRun) {
        self.locationAlert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:SFLocalized(@"user.autoDetactLocation.text" )
                                                       delegate:self
                                              cancelButtonTitle:SFLocalized(@"user.autoDetactLocation.cancel")
                                              otherButtonTitles:SFLocalized(@"user.autoDetactLocation.allow"), nil];
        [self.locationAlert show];
        self.isFirstRun = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)disableControls
{
    [super disableControls];
    self.userPhotoButton.enabled = NO;
    self.locationButton.enabled = NO;
    self.nameTextField.enabled = NO;
}

- (void)enableControls
{
    [super enableControls];
    self.userPhotoButton.enabled = YES;
    self.locationButton.enabled = YES;
    self.nameTextField.enabled = YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newText.length>klMaxNameLength) {
        return NO;
    } else if(newText.length<klMinNameLength) {
        self.submitButton.enabled = NO;
    } else {
        self.submitButton.enabled = YES;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Actions

- (IBAction)onSubmit:(id)sender
{
    [self disableControls];
    if (self.userImage) {
        [self.currentUser updateUserImage:self.userImage];
    }
    self.currentUser.fullName = self.nameTextField.text;
    self.currentUser.isRegistered = @(YES);
    __weak typeof(self) weakSelf = self;
    [[KLAccountManager sharedManager] uploadUserDataToServer:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            KLInviteFriendsViewController *inviteVC = [[KLInviteFriendsViewController alloc] initForType:KLInviteTypeFriends];
            inviteVC.isAfterSignIn = YES;
            [self.navigationController pushViewController:inviteVC animated:YES];
        } else {
            
        }
        [weakSelf enableControls];
    }];
}

- (IBAction)onUserPhoto:(id)sender
{
    [self showPhotosActionSheet];
}

- (IBAction)onLocation:(id)sender
{
    KLLocationSelectTableViewController *location = [[KLLocationSelectTableViewController alloc] initWithType:KLLocationSelectTypeParse];
    location.delegate = self;
    location.kl_parentViewController = self;
    [self.navigationController pushViewController:location
                                         animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES
                               completion:^{
    }];
    self.userImage = image;
    self.userImageView.image = image;
    [self.userPhotoButton setImage:[UIImage imageNamed:@"ic_cam"] forState:UIControlStateNormal];
    self.userPhotoButton.backgroundColor = [UIColor colorWithWhite:0
                                                             alpha:.6];
}

#pragma mark - KLLocationSelectTableViewControllerDelegate

- (void)dissmissLocationSelectTableView:(KLLocationSelectTableViewController *)selectViewController
                              withVenue:(KLLocation *)venue
{
    __weak typeof(self) weakSelf = self;
    if (venue.predictionDescription) {
        [self.loadPlaceIndicator startAnimating];
        self.locationButton.hidden = YES;
        [[KLLocationManager sharedManager] fetchPlace:venue
                                         completition:^(KLLocation *place, NSError *error) {
                                             weakSelf.currentUser.place = place.locationObject;
                                             [weakSelf.locationButton setTitle:place.description
                                                                      forState:UIControlStateNormal];
                                             [weakSelf.loadPlaceIndicator stopAnimating];
                                             weakSelf.locationButton.hidden = NO;
                                         }];
    } else {
        self.currentUser.place = venue.locationObject;
        [self.locationButton setTitle:venue.address
                             forState:UIControlStateNormal];
    }
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - KLChildrenViewControllerDelegate

- (void)viewController:(UIViewController *)viewController
      dissmissAnimated:(BOOL)animated
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == self.locationAlert && buttonIndex == 1) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    }
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    __weak typeof(self) weakSelf = self;
    if (manager == self.locationManager && (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways)) {
        CLLocation *location = [self.locationManager location];
        [self.loadPlaceIndicator startAnimating];
        self.locationButton.hidden = YES;
        [[KLLocationManager sharedManager] getCurrentPlaceWithLocation:location completion:^(KLLocation *currentPlace) {
            weakSelf.currentUser.place = currentPlace.locationObject;
            [weakSelf.locationButton setTitle:currentPlace.address
                                     forState:UIControlStateNormal];
            [weakSelf.loadPlaceIndicator stopAnimating];
            weakSelf.locationButton.hidden = NO;
        }];
    }
}

@end
