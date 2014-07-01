//
//  VPControlViewController.m
//  oNoteLauncher
//
//  Created by Joel Sooriah on 27/04/2014.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "VPControlViewController.h"

@import CoreBluetooth;
@import QuartzCore;

@interface VPControlViewController ()

@end

@implementation VPControlViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Do any additional setup after loading the view.
		
	// Scan for all available CoreBluetooth LE devices
	
	//	NSArray *services = @[[CBUUID UUIDWithString:@""], [CBUUID UUIDWithString:@""]];
	//	CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	//	[centralManager scanForPeripheralsWithServices:services options:nil];
	//	self.centralManager = centralManager;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

#pragma mark - CBCentralManagerDelegate

// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	[peripheral setDelegate:self];
	[peripheral discoverServices:nil];
	self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
	NSLog(@"%@", self.connected);
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	//	NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
	//	if ([localName length] > 0) {
	//		NSLog(@"Found the heart rate monitor: %@", localName);
	//		[self.centralManager stopScan];
	//		self.polarH7HRMPeripheral = peripheral;
	//		peripheral.delegate = self;
	//		[self.centralManager connectPeripheral:peripheral options:nil];
	//	}
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	// Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
		NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
		NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
		NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
	else if ([central state] == CBCentralManagerStateUnknown) {
		NSLog(@"CoreBluetooth BLE state is unknown");
	}
	else if ([central state] == CBCentralManagerStateUnsupported) {
		NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
	}
}

#pragma mark - CBPeripheralDelegate

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	for (CBService *service in peripheral.services) {
		NSLog(@"Discovered service: %@", service.UUID);
		[peripheral discoverCharacteristics:nil forService:service];
	}
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
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


#pragma mark - CBCharacteristic helpers

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
{
}
// Instance method to get the manufacturer name of the device
- (void) getManufacturerName:(CBCharacteristic *)characteristic
{
}
// Instance method to get the body location of the device
- (void) getBodyLocation:(CBCharacteristic *)characteristic
{
}
// Helper method to perform a heartbeat animation
- (void)doHeartBeat {
}


@end
