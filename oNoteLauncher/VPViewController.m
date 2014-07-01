//
//  VPViewController.m
//  oNoteLauncher
//
//  Created by Joel Sooriah on 27/04/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "VPViewController.h"
#import "VPoNoteDetailsViewController.h"
#import "NSdate+TimeAgo.h"
#import "UIImageView+WebCache.h"
#import "bletestViewController.h"
#import "MBProgressHUD.h"
#import "VPBluetoothSettingsViewController.h"

@interface VPViewController ()
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UINavigationController *popoverContent;
@end

@implementation VPViewController
{
	NSDate *_lastLoadedData;
	UIActivityIndicatorView *_loadingIndicator;
}

@synthesize imagesCollection;
@synthesize refreshControl;
@synthesize searchBar;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
	// Private method called from all initializers
	
	_loadingViewEnabled = YES;
	_pullToRefreshEnabled = YES;
	_paginationEnabled = YES;
	_objectsPerPage = 15;
	
	self.imagesCollection.backgroundColor = [UIColor whiteColor];
	self.imagesCollection.frame = CGRectMake(0, 50, self.view.frame.size.width, self.imagesCollection.frame.size.height-50);
	self.imagesCollection.delegate = self;
	
	self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:(90/255.0) green:(28/255.0) blue:(33/255.0) alpha:1.0];
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
	self.navigationController.navigationBar.translucent = NO;
	self.navigationItem.title = @"Newsfeed";
	self.navigationItem.titleView.tintColor = [UIColor whiteColor];
	
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
		self.edgesForExtendedLayout = UIRectEdgeNone;
	[[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], UITextAttributeTextColor,[UIFont fontWithName:@"Futura" size:16.0], UITextAttributeFont,nil]];
	
	self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
	
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(toggleBluetoothSettingsScreen:)];
	self.navigationItem.rightBarButtonItem = rightBarButtonItem;
	self.view.backgroundColor = [UIColor whiteColor];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VPBluetoothSettingsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"bluetoothSettings"];
    self.popoverContent = [[UINavigationController alloc] initWithRootViewController:vc];
    [vc autoConnectBluetooth];
    
	[self queryParseMethod];
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(queryParseMethod) forControlEvents:UIControlEventValueChanged];
	[self.imagesCollection addSubview:self.refreshControl];
	
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
	self.searchBar.delegate = self;
	[self.view addSubview:self.searchBar];
}

- (void)toggleBluetoothSettingsScreen:(id)sender {
    if (!self.popover) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:self.popoverContent];
    }
    
    [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)queryParseMethod {
	
	NSLog(@"start query");
	
	PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
	[query orderByDescending:@"createdAt"];
	
	if (_paginationEnabled) {
		[query setLimit:_objectsPerPage];
		//fetching the next page of objects
		if (!_isRefreshing) {
			[query setSkip:imageFilesArray.count];
		}
	}
	
	[self objectsWillLoad];
	
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		
		self.isLoading = NO;
		
		if (error)
			imageFilesArray = [NSMutableArray new];
		else {
			if (_paginationEnabled /*&& !_isRefreshing*/) {
				//add a new page of objects
				NSMutableArray *mutableObjects = [NSMutableArray arrayWithArray:imageFilesArray];
				[mutableObjects addObjectsFromArray:objects];
				imageFilesArray = [NSMutableArray arrayWithArray:mutableObjects];
				imagesCollection.contentSize = CGSizeMake(imagesCollection.contentSize.width, imagesCollection.contentSize.height);
			}
			else {
				imageFilesArray = [[NSMutableArray alloc] initWithArray:objects];
			}
		}
		[self objectsDidLoad:error];
	}];
	
	[self.refreshControl endRefreshing];
}

- (void)objectsDidLoad:(NSError *)error
{
	_lastLoadedData = [NSDate date];
	[_loadingIndicator stopAnimating];
	[self.imagesCollection reloadData];
}

#pragma mark - UICollectionView data source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [imageFilesArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellIdentifier = @"imageCell";
	ImageExampleCell *cell = (ImageExampleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	
	PFObject *imageObject = [imageFilesArray objectAtIndex:indexPath.row];
	PFFile *imageFile = [imageObject objectForKey:@"image"];
    
	cell.loadingSpinner.hidden = NO;
	[cell.loadingSpinner startAnimating];
	
	[imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
		
		if (!error) {
			
			cell.layer.masksToBounds = NO;
			cell.layer.cornerRadius = 3; // if you like rounded corners
			cell.layer.shadowOffset = CGSizeMake(-1, 1);
			cell.layer.shadowRadius = 2;
			cell.layer.shadowOpacity = 0.5;
			
			cell.parseImage.image = [UIImage imageWithData:data];
			[cell.loadingSpinner stopAnimating];
			cell.loadingSpinner.hidden = YES;
			
			cell.contentView.backgroundColor = [UIColor whiteColor];
			cell.backgroundColor = [UIColor whiteColor];
			
			NSString *username = [imageObject objectForKey:@"name"];
			NSString *title = [imageObject objectForKey:@"title"];
			NSString *location = [imageObject objectForKey:@"location"];
			NSString *pictureURL = [imageObject objectForKey:@"pictureURL"];
			
			[cell.avatarImageView setImageWithURL:[NSURL URLWithString:pictureURL]];
			cell.avatarImageView.layer.cornerRadius = 25;
			cell.avatarImageView.layer.masksToBounds = YES;
			
			if (title && location) {
				cell.titleLocationLabel.text = [NSString stringWithFormat:@"%@,%@", title, location];
			} else {
				cell.titleLocationLabel.text = [NSString stringWithFormat:@"%@", title];
			}
			
			cell.titleLocationLabel.textColor = [UIColor whiteColor];
			cell.nameLabel.text = username;
			cell.nameLabel.textColor = [UIColor whiteColor];
			NSDate *date = imageObject.updatedAt;
			NSString *ago = [date timeAgo];
			cell.timeAgoLabel.text = ago;
			cell.timeAgoLabel.textColor = [UIColor whiteColor];
			
			UIImageView *overlay = [[UIImageView alloc] initWithFrame:CGRectMake(70, 35, 80, 150)];
			overlay.image = [UIImage imageNamed:@"oNotes_overlay.png"];
			[cell.parseImage addSubview:overlay];
			cell.parseImage.layer.cornerRadius = 105;
			cell.parseImage.layer.masksToBounds = YES;
			cell.layer.borderColor = [UIColor grayColor].CGColor;
			cell.layer.borderWidth = 2.0;
		}
	}];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	
	PFObject *oSnap = [imageFilesArray objectAtIndex:indexPath.row];
	VPoNoteDetailsViewController *vc = [[VPoNoteDetailsViewController alloc] initWithoSnap:oSnap];
	[self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UISearchBarDelegate 

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	NSMutableArray *finalResults = [NSMutableArray array];
	
	[imageFilesArray removeAllObjects];
	
	if (self.searchBar.text.length > 0) {
		
		PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
		[query whereKey:@"name" containsString:[self.searchBar.text capitalizedString]];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error) {
				[imageFilesArray addObjectsFromArray:objects];
				[imagesCollection reloadData];
			}
		}];
		
		PFQuery *query_ = [PFQuery queryWithClassName:@"Photo"];
		[query_ whereKey:@"location" containsString:[self.searchBar.text capitalizedString]];
		[query_ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error) {
				[imageFilesArray addObjectsFromArray:objects];
				[imagesCollection reloadData];
			}
		}];
		
		PFQuery *query__ = [PFQuery queryWithClassName:@"Photo"];
		[query__ whereKey:@"title" containsString:[self.searchBar.text capitalizedString]];
		[query__ findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error) {
				[imageFilesArray addObjectsFromArray:objects];
				[imagesCollection reloadData];
			}
		}];
		
		[hud hide:YES];
	}
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
	;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	;
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar NS_AVAILABLE_IOS(3_2) {
	;
}

#pragma mark - UIScrollView Delegate
#pragma mark - Scroll View delegate

// Forward these messages to the refresh view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	//[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	//[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	//	//if the scrollView has reached the bottom fetch the next page of objects
	float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
	if (bottomEdge >= scrollView.contentSize.height) {
		// [self setIsRefreshing:NO];
		[self queryParseMethod];
	}
}

- (void)objectsWillLoad
{
	// Enter the loading state
	self.isLoading = YES;
	
	// Display the loading thingy
	if (self.loadingViewEnabled)
	{
		if (!_loadingIndicator)
		{
			_loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
			_loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
			_loadingIndicator.hidesWhenStopped = YES;
			_loadingIndicator.center = CGPointMake(self.imagesCollection.bounds.size.width / 2, self.imagesCollection.bounds.size.height / 2);
			[self.view addSubview:_loadingIndicator];
		}
		// Unhide if this is the second time loading
		_loadingIndicator.hidden = NO;
		[_loadingIndicator startAnimating];
	}
}

@end

