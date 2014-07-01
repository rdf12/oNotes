//
//  VPPeripheralManager.m
//  oNoteLauncher
//
//  Created by Patrick Butkiewicz on 6/23/14.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "VPPeripheralManager.h"

@interface VPPeripheralManager()
@property (nonatomic, copy) VPPeripheralManagerWriteValueCompletionBlock writeCompletionBlock;
@property (nonatomic, copy) VPPeripheralManagerConnectCompletionBlock connectionCompletionBlock;
@property (nonatomic, copy) VPPeripheralManagerDisconnectCompletionBlock disconnectionCompletionBlock;
@end

@implementation VPPeripheralManager

+ (VPPeripheralManager *)sharedManager{
    static VPPeripheralManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[VPPeripheralManager alloc] init];
        [_sharedManager configure];
    });
    
    return _sharedManager;
}

- (void)configure{
    [[VPCoreBluetoothManager sharedManager] configureWithOptions:nil];
}

#pragma mark - Public Methods

- (void)connectWithCompletion:(VPPeripheralManagerConnectCompletionBlock)completion{

    if ([[VPCoreBluetoothManager sharedManager] isConnected]) {
        NSLog(@"[Peripheral Manager] Already Connected");
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    _connectionCompletionBlock = completion;
    
    if ([[VPCoreBluetoothManager sharedManager] isScanning] == NO) {
        [[VPCoreBluetoothManager sharedManager] startScanningForServices];
    }
}

- (void)disconnectWithCompletion:(VPPeripheralManagerDisconnectCompletionBlock)completion{
    _disconnectionCompletionBlock = completion;
    
    // If we aren't connected, run the block right away. A connected-peripheral's disconnect block gets run in the delegate call
    if ([[VPCoreBluetoothManager sharedManager] isConnected] == NO) {
        if (completion) {
            completion(nil);
        }
        return;
    }

    // If we're scanning, stop the scanning, and run the block.
    if ([[VPCoreBluetoothManager sharedManager] isScanning]) {
        [[VPCoreBluetoothManager sharedManager] stopScanningForServices];
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    [[VPCoreBluetoothManager sharedManager] disconnect];
}

- (void)writeData:(NSData *)data withCompletion:(VPPeripheralManagerWriteValueCompletionBlock)completion{
    if ([[VPCoreBluetoothManager sharedManager] isConnected] == NO) {
        NSLog(@"Attempting to write data without being connected to the device");
        return;
    }
    
    _writeCompletionBlock = completion;
    [[VPCoreBluetoothManager sharedManager] writeData:data];
}

#pragma mark - VPCoreBluetoothConnectionDelegate Methods

- (void)oNotePeripheralDidConnect:(CBPeripheral *)peripheral{
    NSLog(@"[Peripheral Manager] oNote Peripheral Connected, %@", peripheral);
    
    if (self.connectionCompletionBlock) {
        self.connectionCompletionBlock(nil);
    }
    
    _connectionCompletionBlock = nil;
}

- (void)oNotePeripheralDidFailToConnect:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"[Peripheral Manager] oNote Peripheral Manager Failed To Connect %@", peripheral);
    NSLog(@"%@", error);
    
    if (self.connectionCompletionBlock) {
        self.connectionCompletionBlock(error);
    }
    
    _connectionCompletionBlock = nil;
}

- (void)oNotePeripheralDidDisconnect:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"[Peripheral Manager] oNote Peripheral Disconnected, %@", peripheral);
    NSLog(@"%@", error);
    
    if (self.disconnectionCompletionBlock) {
        self.disconnectionCompletionBlock(error);
    }
    
    _disconnectionCompletionBlock = nil;
}

- (void)oNotePeripheralDidWriteDataForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"[Peripheral Manager] oNote Peripheral Wrote Data");
    NSLog(@"%@", error);
    
    if (self.writeCompletionBlock) {
        self.writeCompletionBlock(error);
    }
    
    _writeCompletionBlock = nil;
}
@end
