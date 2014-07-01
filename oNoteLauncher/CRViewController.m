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


#include <string.h>
#import "CRViewController.h"
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CAMediaTimingFunction.h>

#define ARROWDURATION 0.4

@implementation CRViewController
@synthesize peripheral = _peripheral;


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
    isOpen = YES;
}
- (void)viewDidUnload
{
    helloText = nil;
    textRx = nil;
    arrowTx = nil;
    arrowRx = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)connectService:(CBService *)ser
{
    _peripheral=ser.peripheral;
    cr_characteristic=nil;
    pot_characteristic=nil;
    alert_characteristic=nil;
    [_peripheral setDelegate:self];
    
    [_peripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                          [CBUUID UUIDWithString:@"c3bad76c-a2b5-4b30-b7ae-74bf35b97651"],
                                          [CBUUID UUIDWithString:@"c3bad76c-a2b5-4b30-b7ae-74bf35b97652"], nil] forService:ser];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
//	CBCharacteristic *cr_characteristic;
//    CBCharacteristic *pot_characteristic;
//    CBCharacteristic *alert_characteristic;
	
    if(error != nil)
    {
        //TODO: handle error
        return;
    }
    
    NSEnumerator *e = [service.characteristics objectEnumerator];
    for (int i=0; i<2; i++) {
        if ( (cr_characteristic = [e nextObject]) ) {
            if (i==0) {
                pot_characteristic = cr_characteristic;
                [peripheral setNotifyValue:YES forCharacteristic: pot_characteristic];
            }
            else {
                alert_characteristic = cr_characteristic;
                [peripheral setNotifyValue:YES forCharacteristic: alert_characteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if(error != nil)
    {
        //TODO: handle error
        return;
    }
    
    NSEnumerator *e = [_peripheral.services objectEnumerator];
    CBService * service;
    
    while ( (service = [e nextObject]) ) {
        [_peripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                              [CBUUID UUIDWithString:@"c3bad76c-a2b5-4b30-b7ae-74bf35b97651"],
                                              [CBUUID UUIDWithString:@"c3bad76c-a2b5-4b30-b7ae-74bf35b97652"], nil] forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error != nil)
        return;
    
    if (characteristic == pot_characteristic) {
        char buffer[32];
        int len=characteristic.value.length;
        memcpy(buffer,[characteristic.value bytes],len);
        buffer[len]=0;
        
        NSString *bufferStr = [NSString stringWithFormat:@"%@", characteristic.value];
        NSString *right = [bufferStr substringWithRange:NSMakeRange(1, 2)];
        NSString *left = [bufferStr substringWithRange:NSMakeRange(3, 2)];
        bufferStr = [NSString stringWithFormat:@"%@%@", left, right];
        
        NSScanner *scanner = [NSScanner scannerWithString:bufferStr];
        unsigned int temp;
        [scanner scanHexInt:&temp];
        textRx.text = [NSString stringWithFormat:@"%d\n", temp];
        
        if (temp>3000 && isOpen==FALSE) {
            helloText.text = @"Morning! Open the curtains.";
        }
        else if (temp<2000 && isOpen==TRUE) {
            helloText.text = @"Night! Close the curtains.";
        }
        
//        textRx.text=[textRx.text stringByAppendingString:[NSString stringWithFormat:@"%d\n", temp]];
//        [textRx scrollRectToVisible:CGRectMake(0, textRx.contentSize.height-textRx.frame.size.height, textRx.frame.size.width, textRx.frame.size.height) animated:NO];
    }
    else if (characteristic == alert_characteristic) {

    }


}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (error)
	{
		//handle error
		cr_characteristic = nil;
		pot_characteristic = nil;
		alert_characteristic = nil;
	}
	
	// [_peripheral readValueForCharacteristic:characteristic];
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
	
	NSLog(@"descriptor: %@", descriptor);
	NSLog(@"error: %@", error);
}

- (IBAction)openButton:(id)sender {
	
	//start animation on tx
	
	CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
	
	pulseAnimation.toValue = [NSNumber numberWithInt:157];
	pulseAnimation.fromValue = [NSNumber numberWithInt:0];
	
    pulseAnimation.duration = ARROWDURATION;
    pulseAnimation.repeatCount = 1;
    pulseAnimation.autoreverses = NO;
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [[arrowTx layer] addAnimation:pulseAnimation forKey:nil];
    
	UInt8 s = 0x10;
	NSData *data=[NSData dataWithBytes:&s length:sizeof(s)];
    
	[_peripheral writeValue:data forCharacteristic:alert_characteristic type:CBCharacteristicWriteWithResponse];
	
	isOpen = TRUE;
	helloText.text = @"";
}

- (IBAction)closeButton:(id)sender {
	
	// start animation on tx
	
	CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
	
	pulseAnimation.toValue = [NSNumber numberWithInt:157];
	pulseAnimation.fromValue = [NSNumber numberWithInt:0];
	
	pulseAnimation.duration = ARROWDURATION;
	pulseAnimation.repeatCount = 1;
	pulseAnimation.autoreverses = NO;
	pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	
	[[arrowTx layer] addAnimation:pulseAnimation forKey:nil];
	
	UInt8 s = 0x11;
    NSData *data=[NSData dataWithBytes:&s length:sizeof(s)];
	
	
	// NSString *bitSeries = @"00000000000000000000000111101100";
	// uint32_t value = strtoul([bitSeries UTF8String], NULL, 2);
	// NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
	// NSLog(@"%@", data);
	
    [_peripheral writeValue:data forCharacteristic:alert_characteristic type:CBCharacteristicWriteWithResponse];
    
    isOpen = FALSE;
    helloText.text = @"";
}

@end
