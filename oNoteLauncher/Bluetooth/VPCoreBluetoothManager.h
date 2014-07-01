//
//  VPCoreBluetoothManager.h
//  oNoteLauncher
//
//  Created by Patrick Butkiewicz on 6/23/14.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol VPCoreBluetoothManagerDelegate;

@interface VPCoreBluetoothManager : NSObject
@property (nonatomic, readonly) BOOL isConnected;
@property (nonatomic, readonly) CBPeripheral *currentPeripheral;
@property (nonatomic, readonly) NSArray *discoveredPeripherals;
@property (nonatomic, strong) id<VPCoreBluetoothManagerDelegate> delegate;

+ (VPCoreBluetoothManager *)sharedManager;
- (void)configureWithOptions:(NSDictionary *)options;
- (void)startScanningForPeripherals;
- (void)stopScanningForPeripherals;
- (void)connectPeripheral:(CBPeripheral *)peripheral;
- (void)disconnect;

- (void)writeData:(NSData *)data;
@end

@protocol VPCoreBluetoothManagerDelegate <NSObject>
- (void)oNotePeripheralWasDiscovered:(CBPeripheral *)peripheral;
- (void)oNotePeripheralDidConnect:(CBPeripheral *)peripheral;
- (void)oNotePeripheralDidFailToConnect:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)oNotePeripheralDidDisconnect:(CBPeripheral *)peripheral error:(NSError *)error;
- (void)oNotePeripheralDidWriteDataForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
@end