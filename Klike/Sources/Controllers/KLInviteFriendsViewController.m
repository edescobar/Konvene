//
//  KLInviteFriendsViewController.m
//  Klike
//
//  Created by Dima on 18.03.15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLInviteFriendsViewController.h"
#import "KLInviteSocialTableViewCell.h"
#import "KLInviteFriendTableViewCell.h"
#import "KLAddressBookHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MessageUI.h>
#import "KLFilteredUsersViewController.h"
#import "SFFacebookAPI.h"

static NSString *inviteButtonCellId = @"inviteButtonCellId";
static NSString *inviteKlikeCellId = @"inviteKlikeCellId";
static NSString *inviteContactCellId = @"inviteContactCellId";

@interface KLInviteFriendsViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, KLInviteUserCellDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating>
{
    IBOutlet UIButton *_buttonInviteFacebook;
    IBOutlet UIButton *_buttonConnectContacts;
    IBOutlet UIButton *_buttonInviteEmail;
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UIView *_viewScrollable;
    UISearchBar *searchBar;
}

@property UISearchController *searchController;
@property UITableView *tableView;
@property NSArray *unregisteredUsers;
@property NSArray *registeredUsers;
@property KLFilteredUsersViewController *searchVC;
@property SFFacebookAPI *facebook;
@property KLAddressBookHelper *helper;
@end

@implementation KLInviteFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self kl_setNavigationBarColor:[UIColor whiteColor]];
    self.helper = [[KLAddressBookHelper alloc] init];
    [_scrollView addSubview:_viewScrollable];
    [_viewScrollable sendSubviewToBack:_buttonConnectContacts];
    _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, _viewScrollable.bounds.size.height*3);
//    [_scrollView setContentOffset:CGPointMake(0, _buttonInviteFacebook.frame.origin.y) animated:YES];
    [_viewScrollable autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    CGSize mainScreenSize= [UIScreen mainScreen].bounds.size;
    mainScreenSize.height = mainScreenSize.height-self.navigationController.navigationBar.height-20;
    [_viewScrollable autoSetDimensionsToSize:mainScreenSize];
    [_viewScrollable sendSubviewToBack:_buttonConnectContacts];
    
    _tableView = [[UITableView alloc] initForAutoLayout];
    [self.view addSubview:_tableView];
    [self.view sendSubviewToBack:_tableView];
    self.tableView = _tableView;
    [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    _tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64.0;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"KLInviteSocialTableViewCell" bundle:nil]
         forCellReuseIdentifier:inviteButtonCellId];
    [self.tableView registerNib:[UINib nibWithNibName:@"KLInviteFriendTableViewCell" bundle:nil]
         forCellReuseIdentifier:inviteKlikeCellId];
    [self.tableView registerNib:[UINib nibWithNibName:@"KLInviteFriendTableViewCell" bundle:nil]
         forCellReuseIdentifier:inviteContactCellId];
    self.navigationItem.title = SFLocalizedString(@"inviteUsers.findFriendsTitle", nil);
    
    self.navigationItem.hidesBackButton = YES;
    UIImage *tickImage = [[UIImage imageNamed:@"tick"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:tickImage
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(onDone)];
    self.navigationItem.rightBarButtonItem = doneButton;
    if (self.helper.isAuthorized) {
        _tableView.hidden = NO;
        _scrollView.hidden = YES;
    } else {
        _tableView.hidden = YES;
        _scrollView.hidden = NO;
    }
    [self loadContactList];
    self.searchVC = [[KLFilteredUsersViewController alloc] init];
    
    if (!self.searchVC.displayingSearchResults) {
        self.edgesForExtendedLayout =  UIRectEdgeNone;
        self.searchVC.edgesForExtendedLayout = UIRectEdgeNone;
        self.searchVC.displayingSearchResults = YES;
        self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchVC];
        self.searchController.searchBar.delegate = self;
        self.searchController.searchBar.frame = CGRectMake(0, 0, self.view.width, 44.0);
        self.searchController.searchBar.backgroundColor = [UIColor whiteColor];
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.searchController.searchBar.placeholder = @"Search";
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.definesPresentationContext = YES;

    }
    self.facebook = [[SFFacebookAPI alloc] init];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)onDone
{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)loadContactList
{
    void (^ loadContacts)() = ^{
        [self.helper loadListOfContacts:^(NSArray *rawContants) {
            //TODO sort registered and unregistered users by email
            _unregisteredUsers = rawContants;
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [self.tableView setContentOffset:CGPointMake(0, self.searchController.searchBar.height)];
        }];
    };
    if (self.helper.isAuthorized) {
        loadContacts();
    }
    else {
        [self.helper authorizeWithCompletionHandler:^(BOOL success) {
            [self animateButtonsMovement];
            loadContacts();
        }];
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section) {
        case KLSectionTypeKlikeInvite:
            sectionName = SFLocalizedString(@"inviteUsers.contactsOnKlikeTitle", nil);
            break;
        case KLSectionTypeContactInvite:
            sectionName = SFLocalizedString(@"inviteUsers.inviteContactsTitle", nil);
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == KLSectionTypeSocialInvite)
    {
        return UITableViewAutomaticDimension;
    }
    return 48.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 48)];
    headerView.backgroundColor = [UIColor colorFromHex:0xf2f2f7];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 48)];
    label.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:label];
    NSString *sectionName;
    switch (section) {
        case KLSectionTypeKlikeInvite:
            sectionName = SFLocalizedString(@"inviteUsers.contactsOnKlikeTitle", nil);
            break;
        case KLSectionTypeContactInvite:
            sectionName = SFLocalizedString(@"inviteUsers.inviteContactsTitle", nil);
            break;
        default:
            sectionName = @"";
            break;
    }
    label.text = sectionName;
    label.textColor = [UIColor colorFromHex:0x1d2027];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == KLSectionTypeSocialInvite) {
        return 2;
    }
    else {
        if (section == KLSectionTypeKlikeInvite) {
            return _registeredUsers.count;
        }
        else
            return _unregisteredUsers.count;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == KLSectionTypeSocialInvite) {
        if (indexPath.row == KLSocialTypeFacebook) {
            if (self.facebook.isAuthorized) {
                [self inviteFacebook];
            } else {
                [self.facebook openSession:^(BOOL authorized, NSError *error) {
                    [self inviteFacebook];
                }];
            }
        }
        else {
            [self inviteEmail];
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == KLSectionTypeSocialInvite) {
        KLInviteSocialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:inviteButtonCellId forIndexPath:indexPath];
        [cell configureForInviteType:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        KLInviteFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:inviteKlikeCellId forIndexPath:indexPath];
        if (indexPath.section == KLSectionTypeKlikeInvite) {
            cell.registered = YES;
        }
        else {
            cell.registered = NO;
        }
        [cell configureWithUser:[_unregisteredUsers objectAtIndex:indexPath.row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        return cell;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)inviteMessage
{
    if(![MFMessageComposeViewController canSendText]) {
        NSString *title = SFLocalizedString(@"error.imessage.unavailable.title", nil);
        NSString *message = SFLocalizedString(@"error.imessage.unavailable.message", nil);
//        SFAlertMessageView *alert = [[SFAlertMessageView alloc] initWithTitle:title
//                                                                      message:message
//                                                                        image:nil
//                                                                 cancelButton:@"Ok"];
//        [alert show];
        NSLog(@"cant send text");
        return;
    }
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    NSString *message = SFLocalizedString(@"inviteUsers.inviteIMessage", nil);
    [messageController setBody:message];
    [self presentViewController:messageController animated:YES completion:nil];
    
}

- (void)inviteFacebook
{
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Join Klike"
                                                    title:@"App Requests"
                                               parameters:nil
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}
     ];
}

- (void)inviteEmail
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:SFLocalizedString(@"inviteUsers.inviteEmailSubject", nil)];
    
    NSString *emailBody = SFLocalizedString(@"inviteUsers.inviteEmailMessage", nil);
    [picker setMessageBody:emailBody isHTML:NO];
    
    if([MFMailComposeViewController canSendMail]) {
        [self presentViewController:picker animated:YES completion:nil];
    }
}
#pragma mark - KLInviteFriendTableViewCellDelegate methods
- (void) cellDidClickAddUser:(KLInviteFriendTableViewCell *)cell
{
    NSLog(@"addUser");
}

- (void) cellDidClickSendMail:(KLInviteFriendTableViewCell *)cell
{
    [self inviteEmail];
}

- (void) cellDidClickSendSms:(KLInviteFriendTableViewCell *)cell
{
    [self inviteMessage];
}

#pragma mark - MFMessageComposeViewControllerDelegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed: {
            NSString *title = SFLocalizedString(@"error.mail.failed.title", nil);
            NSString *message = SFLocalizedString(@"error.mail.failed.message", nil);
            NSString *ok = SFLocalizedString(@"sfkit.message.ok", nil);
//            SFAlertMessageView *alert = [[SFAlertMessageView alloc] initWithTitle:title
//                                                                          message:message
//                                                                            image:nil
//                                                                     cancelButton:ok];
//            [alert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearch* delegates



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    NSString *strippedStr = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (PFUser *user in _unregisteredUsers) {
        if ([[user[@"fullName"] lowercaseString] rangeOfString:[strippedStr lowercaseString]].location != NSNotFound) {
            [searchResults addObject:user];
        }
    }
    self.searchVC.unregisteredUsers = searchResults;
    [self.searchVC update];
    
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    NSString *strippedStr = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (PFUser *user in _unregisteredUsers) {
        if ([[user[@"fullName"] lowercaseString] rangeOfString:[strippedStr lowercaseString]].location != NSNotFound) {
            [searchResults addObject:user];
        }
    }
    self.searchVC.unregisteredUsers = searchResults;
    [self.searchVC update];
}

- (void)willPresentSearchController:(UISearchController *)searchController
{
    
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView setContentOffset:CGPointMake(0, self.searchController.searchBar.height) animated:YES];
            [self.searchController.searchBar resignFirstResponder];
        });
    }

- (IBAction)onConnectFacebook:(id)sender {
    [self inviteFacebook];
}

- (IBAction)onConnectContacts:(id)sender {
    [self loadContactList];
}

- (IBAction)onConnectEmail:(id)sender {
    [self inviteEmail];
}

- (void) animateButtonsMovement
{
    [UIView animateWithDuration:1.0f animations:^{
        CGRect buttonFrame = _buttonInviteEmail.frame;
        buttonFrame.origin.y -= _buttonInviteEmail.height;
        _buttonInviteEmail.frame = buttonFrame;
        CGRect viewFrame = _viewScrollable.frame;
        viewFrame.origin.y -= _buttonInviteFacebook.frame.origin.y;
        _viewScrollable.frame = viewFrame;
    } completion:^(BOOL finished) {
        [_viewScrollable setBackgroundColor:[UIColor colorFromHex:0xf2f2f7]];
        CATransition *animation = [CATransition animation];
        animation.type = kCATransitionFade;
        animation.duration = 0.5;
        [_tableView.layer addAnimation:animation forKey:nil];
        _tableView.hidden = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _scrollView.hidden = YES;
            [self.view sendSubviewToBack:_scrollView];
        });
        
    }];
}

@end

