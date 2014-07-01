//
//  VPAppDelegate.m
//  oNoteLauncher
//
//  Created by Joel Sooriah on 27/04/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "VPAppDelegate.h"
#import "PasteboardViewController.h"
#import "VPViewController.h"
#import <Parse/Parse.h>

#import "VPCoreBluetoothManager.h"

@implementation VPAppDelegate

@synthesize allScents;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[Parse setApplicationId:@"2aj19QnJSX5aGfiIEK6GntRM3EnzRiJQuY7zlhGg" clientKey:@"KndvFXfqpubGPFFEFnRUZ4iFle1ppzLzo3kVNavy"];
	[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [[VPCoreBluetoothManager sharedManager] configureWithOptions:nil];
    

	
	// Override point for customization after application launch.
	// VPViewController *pasteBrd = [[VPViewController alloc] init];
	
	VPViewController *pasteBrd = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"VPViewController"];
	
	[self fetchAllScents];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pasteBrd];
	self.window.rootViewController = navController;	//self.viewController;
	[self.window makeKeyAndVisible];
	
	return YES;
}

#pragma mark - Fetch All Scents 

- (void)fetchAllScents {
	
	PFQuery *query = [PFQuery queryWithClassName:@"Scent"];
	// __block NSMutableArray *scents = [NSMutableArray array];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			self.allScents = objects;
			NSLog(@"all Scents : %@", self.allScents);
		}
	}];
}



@end
