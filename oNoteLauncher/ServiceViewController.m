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


#import "ServiceViewController.h"
#import "CRViewController.h"

@implementation ServiceViewController
@synthesize peripheral = _peripheral;
@synthesize cr_characteristic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
	_peripheral=nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
	serviceList = nil;
	[super viewDidUnload];
	// Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)connectPeripheral:(CBPeripheral *)per
{
	_peripheral=per;
	
	NSArray *keys = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"B8E06067-62AD-41BA-9231-206AE80AB550"], nil];
	
	//NSArray *keys = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"BF45E40A-DE2A-4BC8-BBA0-E5D6065F1B4B"], nil];
	//NSArray *keys = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"BF45E40A-DE2A-4BC8-BBA0-E5D6065F1B4B"], nil];
	NSArray *objects = [NSArray arrayWithObjects:@"TX", nil];
	
	serviceNames = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	[_peripheral setDelegate:self];
	[_peripheral discoverServices:[serviceNames allKeys]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_peripheral==nil)
		return 0;
	return [_peripheral.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"foundService";
	UITableViewCell *cell = [serviceList dequeueReusableCellWithIdentifier:CellIdentifier];
	// Configure the cell.
	CBService*pcell=[_peripheral.services objectAtIndex: [indexPath row]];
	// Get human readable description of uuid
	cell.textLabel.text = [self serviceToString :pcell.UUID];
	return cell;
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	if (error != nil) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"did discover servicess" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	}
	
	NSLog(@"Services : %@", peripheral.services);
	
	[serviceList reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CBService* ser=[_peripheral.services objectAtIndex:[indexPath row]];
	
	//if([ser.UUID isEqual:[CBUUID UUIDWithString:@"da588615-01fc-4a86-949a-ca8de10607c5"]])
	//{
		//NSLog(@"right!");
		//CRViewController * cr=[self.storyboard instantiateViewControllerWithIdentifier:@"cablerep"];
		//[cr connectService:ser];
		//[self.navigationController pushViewController:cr animated:YES];
	//}
	
	// 2FBC0F31-726A-4014-B9FE-C8BE0652E982
	
	[_peripheral discoverCharacteristics:[NSArray arrayWithObjects:[CBUUID UUIDWithString:@"BF45E40A-DE2A-4BC8-BBA0-E5D6065F1B4B"], [CBUUID UUIDWithString:@"2FBC0F31-726A-4014-B9FE-C8BE0652E982"], nil] forService:ser];
	
	//[_peripheral discoverCharacteristics:nil forService:ser];
}

- (NSString*)serviceToString:(CBUUID*)uuid
{
	NSString *rv=[serviceNames objectForKey:uuid];
	//no text found, return hex string
	if (rv == nil)
		return [uuid.data description];
	return rv;
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
	
	NSLog(@"Did write characteristic value : %@ with ID %@", characteristic.value, characteristic.UUID);
	
	NSLog(@"With error: %@", [error localizedDescription]);
	
	if(error != nil)
	{
		// TODO: handle error
		UIAlertView *temp = [[UIAlertView alloc] initWithTitle:@"didWriteValueForCharacteristic error" message:error.description delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
		[temp show];
		return;
		
	} else {
		
		UIAlertView *temp = [[UIAlertView alloc] initWithTitle:@"" message:@"did write characteristics" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
		[temp show];
	}
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	if(error != nil)
	{
		// TODO: handle error
		return;
	}
	
	NSLog(@"service : %@", service);
	NSLog(@"characteristics : %@", service.characteristics);	
	
	self.cr_characteristic = [service.characteristics objectAtIndex:0];
	
	NSString *bitSeries = @"11111111";
	uint8_t value = strtoul([bitSeries UTF8String], NULL, 2);
	NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
	[peripheral writeValue:data forCharacteristic:self.cr_characteristic type:CBCharacteristicWriteWithResponse];
	
//	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//		NSString *bitSeries = @"01101001";
//		uint8_t value = strtoul([bitSeries UTF8String], NULL, 2);
//		NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
//		[peripheral writeValue:data forCharacteristic:self.cr_characteristic type:CBCharacteristicWriteWithResponse];
//	});
	
	//	NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
	//	uint8_t value = strtoul([bitSeries UTF8String], NULL, 2);
	//	NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
	//	unsigned char bytes[] = {'b'};
	//	NSData *expectedData = [NSData dataWithBytes:bytes length:sizeof(bytes)];
	//	NSString *bitSeries1 = @"01101011";
	//	uint8_t value1 = strtoul([bitSeries1 UTF8String], NULL, 2);
	//	NSData *data1 = [NSData dataWithBytes:&value length:sizeof(value1)];
	//	unsigned char bytes[] = {0x01};
	//	NSData *singleByte = [[NSData alloc] initWithBytes:bytes length:1];
	//	const char myByteArray[] = { 0x12,0x23,0x34,0x45,0x56,0x67,0x78,0x89,0x12,0x23,0x34,0x45,0x56,0x67,0x78,0x89};
	// NSLog(@"---------> data sent to board : %@ , %@, %@, %@", data, self.cr_characteristic.descriptors, self.cr_characteristic.value, self.cr_characteristic);
	// unsigned char bytes[] = { 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11,0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11};
	// NSData *expectedData = [NSData dataWithBytes:myByteArray length:sizeof(bytes)];
	//[peripheral setNotifyValue:YES forCharacteristic:self.cr_characteristic];
	//-------> [peripheral writeValue:data forCharacteristic:self.cr_characteristic type:CBCharacteristicWriteWithResponse];
	//	NSString *characteristicUUIDstring = @"BF45E40A-DE2A-4BC8-BBA0-E5D6065F1B4B";
	//	CBUUID *characteristicUUID = [CBUUID UUIDWithString:characteristicUUIDstring];
	//	char dataByte = 0x10;
	//	NSData *data = [NSData dataWithBytes:&dataByte length:1];
	//	CBMutableCharacteristic *testCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyRead|CBCharacteristicPropertyWrite value:data permissions:CBAttributePermissionsReadable|CBAttributePermissionsWriteable];
	//	[peripheral writeValue:data forCharacteristic:testCharacteristic type:CBCharacteristicWriteWithResponse];
	//[peripheral readValueForCharacteristic:aChar];
	// Delay execution of my block for 10 seconds.
	//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		//UIAlertView *willsendAV = [[UIAlertView alloc] initWithTitle:@"" message:@"will send second byte" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		//[willsendAV show];
		//[peripheral writeValue:data forCharacteristic:self.cr_characteristic type:CBCharacteristicWriteWithResponse];
	//});
	//	if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID]])  {  // 1
	//		for (CBCharacteristic *aChar in service.characteristics)
	//		{
	//			// Request heart rate notifications
	//			if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID]]) { // 2
	//				[self.polarH7HRMPeripheral setNotifyValue:YES forCharacteristic:aChar];
	//				NSLog(@"Found heart rate measurement characteristic");
	//			}
	//			// Request body sensor location
	//			else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID]]) { // 3
	//				[self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
	//				NSLog(@"Found body sensor location characteristic");
	//			}
	//		}
	//	}
	//
	//	// Retrieve Device Information Services for the Manufacturer Name
	//	if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]])  { // 4
	//		for (CBCharacteristic *aChar in service.characteristics)
	//		{
	//			if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID]]) {
	//				[self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
	//				NSLog(@"Found a device manufacturer name characteristic");
	//			}
	//		}
	//	}
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (error != nil) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"error dude !!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"didUpdateValueForCharacteristic" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alertView show];
	}
	
	//	// Updated value for heart rate measurement received
	//	if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID]]) { // 1
	//		// Get the Heart Rate Monitor BPM
	//		[self getHeartBPMData:characteristic error:error];
	//	}
	//	// Retrieve the characteristic value for manufacturer name received
	//	if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID]]) {  // 2
	//		[self getManufacturerName:characteristic];
	//	}
	//	// Retrieve the characteristic value for the body sensor location received
	//	else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID]]) {  // 3
	//		[self getBodyLocation:characteristic];
	//	}
	//
	//	// Add your constructed device information to your UITextView
	//	self.deviceInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@\n", self.connected, self.bodyData, self.manufacturer];  // 4
	
}

@end

