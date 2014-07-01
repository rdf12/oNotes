//
// Bluegiga’s Bluetooth Smart Demo Application SW for iPhone 4S
// This SW is showing how to iPhone 4S can interact with Bluegiga Bluetooth
// Smart components like BLE112.
// Contact: support@bluegiga.com.
//
// This is free software distributed under the terms of the MIT license reproduced below.
//
// Copyright (c) 2012, Bluegiga Technologies
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
// EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
//


#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface bletestViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource>
{
	CBCentralManager * manager;
	NSMutableArray   * peripherals;
	CBPeripheral *connected_peripheral;
	
	CBPeripheral *myPeripheral;
	
	__weak IBOutlet UILabel *managerState;
	__weak IBOutlet UISwitch *scanSwitch;
	__weak IBOutlet UITableView *scanResult;
}

@property (nonatomic, strong) UITextField *logTextField;
@property (nonatomic, strong) CBPeripheral *myPeripheral;

- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

- (IBAction)scannerState:(id)sender;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;

@end
