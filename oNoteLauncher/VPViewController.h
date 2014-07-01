//
//  VPViewController.h
//  oNoteLauncher
//
//  Created by Joel Sooriah on 27/04/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageExampleCell.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface VPViewController : UIViewController <UISearchBarDelegate, UICollectionViewDelegate, UIScrollViewDelegate> {
	NSMutableArray *imageFilesArray;
	NSMutableArray *imagesArray;
}

@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollection;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) MBProgressHUD *hud;


//
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL isRefreshing;
@property (nonatomic) BOOL loadingViewEnabled;
@property (nonatomic) BOOL pullToRefreshEnabled;
@property (nonatomic) BOOL paginationEnabled;
@property (nonatomic) NSInteger objectsPerPage;




@end

