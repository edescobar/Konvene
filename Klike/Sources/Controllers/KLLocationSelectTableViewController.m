//
//  KLLocationSelectTableViewController.m
//  Klike
//
//  Created by admin on 23/03/15.
//  Copyright (c) 2015 SFÇD, LLC. All rights reserved.
//

#import "KLLocationSelectTableViewController.h"
#import "KLLocationDataSource.h"
#import "KLForsquareVenue.h"

@interface KLLocationSelectTableViewController () <UISearchBarDelegate, UISearchControllerDelegate>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) KLLocationDataSource *dataSource;
@property (nonatomic, strong) SFBasicDataSourceAdapter *dataSoruceAdapter;
@end

@implementation KLLocationSelectTableViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.dataSource = [[KLLocationDataSource alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self kl_setNavigationBarColor:[UIColor whiteColor]];
    [self kl_setBackButtonImage:[UIImage imageNamed:@"arrow_back"]
                         target:self
                       selector:@selector(dissmissViewController)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchController.searchBar becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self.dataSource;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
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
    if (self.kl_parentViewController) {
        [self.kl_parentViewController viewController:self
                                    dissmissAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KLForsquareVenue *currentVenue = [self.dataSource itemAtIndexPath:indexPath];
    [self.delegate dissmissLocationSelectTableView:self
                                         withVenue:currentVenue];
}

#pragma mark - UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length>2) {
        self.dataSource.input = searchText;
        [self.dataSource loadContent];
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

@end