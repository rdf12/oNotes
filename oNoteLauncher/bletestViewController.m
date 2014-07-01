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


#import "bletestViewController.h"
#import "PeripheralCell.h"
#import "ServiceViewController.h"
#import "VPAppDelegate.h"

@implementation bletestViewController

@synthesize logTextField;
@synthesize myPeripheral;

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.logTextField = [[UITextField alloc] initWithFrame:CGRectMake(50, 350, 500, 400)];
	self.logTextField.layer.borderColor = [UIColor redColor].CGColor;
	self.logTextField.layer.borderWidth = 1.0;
	
	[self.view addSubview:self.logTextField];
	
	// Do any additional setup after loading the view, typically from a nib.
	manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	connected_peripheral=nil;
	//scanSwitch.on=NO;
	peripherals = [NSMutableArray arrayWithCapacity:1];
}

-(void)logText:(NSString *)logText {
	self.logTextField.text = [self.logTextField.text stringByAppendingString:logText];
}


- (void)viewDidUnload
{
    scanResult = nil;
    managerState = nil;
    scanSwitch = nil;
    scanResult = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	//disconnect peripheral if connected
	if(connected_peripheral!=nil)
		[manager cancelPeripheralConnection:connected_peripheral];
	connected_peripheral=nil;
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    char * managerStrings[]={
        "Unknown",
        "Resetting",
        "Unsupported",
        "Unauthorized",
        "PoweredOff",
        "PoweredOn"
    };
    
    NSString * newstring=[NSString stringWithFormat:@"Manager State: %s",managerStrings[central.state]];
    managerState.text=newstring;
}

- (IBAction)scannerState:(id)sender {
	
	if(scanSwitch.on)
	{
		[peripherals removeAllObjects];
		[scanResult reloadData];
		
		// NSArray * services=[NSArray arrayWithObjects:[CBUUID UUIDWithString:@"da588615-01fc-4a86-949a-ca8de10607c5"],nil];
		NSArray *services = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"BF45E40A-DE2A-4BC8-BBA0-E5D6065F1B4B"], nil];
		[manager scanForPeripheralsWithServices:nil options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey]];
		
	} else {
		
		[manager stopScan];
	}
}

/**
 Called when scanner finds device
 First checks if it exists, if not then insert new device
 */

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	
	//////////
//	NSError *error;
//	NSString *jsonString;
//	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:advertisementData
//													   options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//														 error:&error];
//	if (! jsonData) {
//		NSLog(@"Got an error: %@", error);
//	} else {
//		jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//	}
//	[self logText:jsonString];
	
	BOOL (^test)(id obj, NSUInteger idx, BOOL *stop);
    test = ^ (id obj, NSUInteger idx, BOOL *stop) {
		if([[[obj peripheral] name] compare:peripheral.name] == NSOrderedSame)
            return YES;
        return NO;
	};
    
	self.myPeripheral = peripheral;
	
	
    PeripheralCell* cell;
    NSUInteger t=[peripherals indexOfObjectPassingTest:test];
    if(t!= NSNotFound)
    {
        cell=[peripherals objectAtIndex:t];
        cell.peripheral=peripheral;
        cell.rssi=RSSI;
        [scanResult reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:t inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
		
    } else {
		
		cell=[[PeripheralCell alloc] init];
		[peripherals addObject: cell];
		cell.peripheral=peripheral;
		cell.rssi=RSSI;
		[scanResult insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[peripherals count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(peripherals==nil)
		return 0;
	return [peripherals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"foundDevice";
	
	UITableViewCell *cell = [scanResult dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// Configure the cell.
	
	PeripheralCell*pcell=[peripherals objectAtIndex: [indexPath row]];
	cell.textLabel.text = [pcell.peripheral name];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI %d",[pcell.rssi intValue]];
	
	//self.colorNames objectAtIndex: [indexPath row]];
	
	return cell;
}

/*
 user selected row
 stop scanner
 connect peripheral for service search
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"didSelectRowAtIndexPath" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	//[alertView show];
	
    PeripheralCell* per=[peripherals objectAtIndex:[indexPath row]];
    scanSwitch.on=false;
    [manager stopScan];
	//[manager connectPeripheral:per.peripheral options:nil];
	[manager connectPeripheral:self.myPeripheral options:nil];
}

/*
 connected to peripheral
 Show service search view
 */

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"did connect peripheral" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	[alertView show];
	
	ServiceViewController * hr= [self.storyboard instantiateViewControllerWithIdentifier:@"services"];
	connected_peripheral = peripheral;
	connected_peripheral.delegate = self;
	
	//CBService *s = [myPeripheral.services objectAtIndex:(myPeripheral.services.count - 1)];
	//[connected_peripheral discoverCharacteristics:[NSArray arrayWithObjects:
	//                                        [CBUUID UUIDWithString:@"65C228DA-BAD1-4F41-B55F-3D177F4E2196"], nil] forService:s];
	//	NSString *bitSeries = @"B01101001";
	//	uint32_t value = strtoul([bitSeries UTF8String], NULL, 2);
	//	NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
	//	NSLog(@"%@", data);
	//	[connected_peripheral writeValue:data forCharacteristic:nil type:CBCharacteristicWriteWithResponse];
	
	VPAppDelegate *d = (VPAppDelegate *)[[UIApplication sharedApplication] delegate];
	d.connected_peripheral = peripheral;
	
	[hr connectPeripheral:peripheral];
	[self.navigationController pushViewController:hr animated:YES];
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral NS_AVAILABLE(NA, 6_0) {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"----> peripheralDidUpdateName" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral NS_DEPRECATED(NA, NA, 6_0, 7_0) {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"----> peripheralDidInvalidateServices" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}


- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices NS_AVAILABLE(NA, 7_0) {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"---> didModifyServices" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"---> peripheralDidUpdateRSSI" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"----> didDiscoverServices" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"----> didDiscoverIncludedServicesForService" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"did discover characteristics" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"----> didUpdateValueForCharacteristic" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"----> didWriteValueForCharacteristic" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"-----> didUpdateNotificationStateForCharacteristic" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"----> didDiscoverDescriptorsForCharacteristic" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"----> didUpdateValueForDescriptor" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
	
	UIAlertView *carAlertView = [[UIAlertView alloc] initWithTitle:@"" message:@"---> didWriteValueForDescriptor" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[carAlertView show];
}



@end




