//
//  KLSearchPeopleControllerTableViewController.m
//  Klike
//
//  Created by Alexey on 5/22/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLSearchPeopleControllerTableViewController.h"
#import "KLExplorePeopleSearchDataSource.h"
#import "KLMyProfileViewController.h"
#import "KLUserProfileViewController.h"

static CGFloat klExplorePeopleCellHeight = 64.;

@interface KLSearchPeopleControllerTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) KLExplorePeopleSearchDataSource *dataSource;
@property (nonatomic, strong) SFBasicDataSourceAdapter *dataSoruceAdapter;
@end

@implementation KLSearchPeopleControllerTableViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.dataSource = [[KLExplorePeopleSearchDataSource alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self kl_setNavigationBarColor:[UIColor whiteColor]];
    UIBarButtonItem *button = [self kl_setBackButtonImage:[UIImage imageNamed:@"ic_back"]
                                                   target:self
                                                 selector:@selector(dissmissViewController)];
    button.tintColor = [UIColor colorFromHex:0x6466ca];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self.dataSource loadContent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.estimatedRowHeight = klExplorePeopleCellHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.dataSoruceAdapter = [[SFBasicDataSourceAdapter alloc] initWithTableView:self.tableView];
    self.dataSource.delegate = self.dataSoruceAdapter;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.frame = YSRectMakeFromSize(self.tableView.width, 44.0);
    self.searchController.searchBar.showsCancelButton = NO;
    self.navigationItem.titleView = self.searchController.searchBar;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.edgesForExtendedLayout = UIRectEdgeNone;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    [self.dataSource registerReusableViewsWithTableView:self.tableView];
    
}

- (void)dissmissViewController
{
    self.searchController.active = NO;
    if (self.kl_parentViewController) {
        [self.kl_parentViewController viewController:self
                                    dissmissAnimated:YES];
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource obscuredByPlaceholder]) {
        return;
    }
    KLUserWrapper *user = [[KLUserWrapper alloc] initWithUserObject:[self.dataSource itemAtIndexPath:indexPath]];
    if (user) {
        [self showUserProfile:user];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffsetY >0) {
        [self kl_setNavigationBarShadowColor:[UIColor colorFromHex:0xe8e8ed]];
    } else {
        [self kl_setNavigationBarShadowColor:nil];
    }
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length>0) {
        [self.dataSource loadSearchContentWithQuery:searchText];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = NO;
}

#pragma mark - UISearchControllerDelegate methods

- (void)willPresentSearchController:(UISearchController *)searchController
{
    searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    searchController.searchBar.showsCancelButton = NO;
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)showUserProfile:(KLUserWrapper *)user
{
    if ([[KLAccountManager sharedManager].currentUser isEqualToUser:user]) {
        KLMyProfileViewController *myProfileViewController = [[KLMyProfileViewController alloc] init];
        [self.navigationController pushViewController:myProfileViewController
                                             animated:YES];
    } else {
        KLUserProfileViewController *userProfileVC = [[KLUserProfileViewController alloc] initWithUser:user];
        [self.navigationController pushViewController:userProfileVC
                                             animated:YES];
    }
}

@end