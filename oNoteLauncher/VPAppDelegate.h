//
//  VPAppDelegate.h
//  oNoteLauncher
//
//  Created by Joel Sooriah on 27/04/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface VPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSArray *allScents;

@property (nonatomic, strong) NSMutableArray   *peripherals;
@property (nonatomic, strong) CBPeripheral *connected_peripheral;

@end

