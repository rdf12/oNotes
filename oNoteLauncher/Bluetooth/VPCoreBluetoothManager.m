//
//  VPCoreBluetoothManager.m
//  oNoteLauncher
//
//  Created by Patrick Butkiewicz on 6/23/14.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import "VPCoreBluetoothManager.h"

NSString * const VPCoreBluetoothDeviceStateUpdateNotification = @"VPCoreBluetoothDeviceStateUpdateNotification";
static NSString * const kCoreBluetoothPeripheralRestoreIdentifier = @"VPCoreBluetoothPeripheralRestoreIdentifier";
static NSString * const kOPhoneDeviceIdentifierCharacteristicUUID = @"65C228DA-BAD1-4F41-B55F-3D177F4E2196";
static NSString * const kOPhoneServiceUUID = @"B8E06067-62AD-41BA-9231-206AE80AB550";
static NSString * const kOPhoneRXCharacteristicUUID = @"F897177B-AEE8-4767-8ECC-CC694FD5FCEE";
static NSString * const kOPhoneTXCharacteristicUUID = @"BF45E40A-DE2A-4BC8-BBA0-E5D6065F1B4B";
static NSString * const kOPhoneBaudrateCharacteristicUUID = @"2FBC0F31-726A-4014-B9FE-C8BE0652E982";

@interface VPCoreBluetoothManager() <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBCharacteristic *characteristic;
@property (nonatomic, strong) NSMutableArray *mutableDiscoveredPeripherals;
@end

@implementation VPCoreBluetoothManager

#pragma mark - Manager Init and Private Methods

+ (VPCoreBluetoothManager *)sharedManager {
    static VPCoreBluetoothManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[VPCoreBluetoothManager alloc] init];
    });
                  
    return _sharedManager;
}

- (void)configureWithOptions:(NSDictionary *)options {
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"[BLE Manager] Attempting to connect to peripheral");
    [peripheral setDelegate:self];
    [self.centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark - Public Methods

- (BOOL)isConnected {
    return (self.currentPeripheral.state == CBPeripheralStateConnected);
}

- (NSArray *)discoveredPeripherals {
    return [self.mutableDiscoveredPeripherals copy];
}

- (void)startScanningForPeripherals {
    [self stopScanningForPeripherals];
    NSLog(@"[BLE Manager] Starting scan for BLE services");
    NSArray *servicesToScanFor = @[[CBUUID UUIDWithString:kOPhoneServiceUUID]];
    self.mutableDiscoveredPeripherals = [NSMutableArray array];
    NSArray *connectedPeripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:servicesToScanFor];
    [self.mutableDiscoveredPeripherals addObjectsFromArray:connectedPeripherals];
    [self.centralManager scanForPeripheralsWithServices:servicesToScanFor options:nil];
}

- (void)stopScanningForPeripherals {
    [self.centralManager stopScan];
}

- (void)disconnect {
    NSLog(@"[BLE Manager] Disconnecting Peripheral");
    if (self.currentPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.currentPeripheral];
        _currentPeripheral = nil;
    }
}

- (void)writeData:(NSData *)data {
    if (self.isConnected && self.currentPeripheral && self.characteristic) {
        [self.currentPeripheral writeValue:data forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse];
    } else if ([self.delegate respondsToSelector:@selector(oNotePeripheralDidWriteDataForCharacteristic:error:)]) {
        NSError *error = [[NSError alloc] initWithDomain:@"ONoteErrorDomain" code:0 userInfo:@{ NSLocalizedDescriptionKey: @"Tried to write data over bluetooth, but peripheral isn't connected." }];
        [self.delegate oNotePeripheralDidWriteDataForCharacteristic:self.characteristic error:error];
    }
}

#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"[BLE Manager] CentralManager Did connect peripheral: %@", peripheral);
    [peripheral setDelegate:self];
    NSArray *servicesToScanFor = @[[CBUUID UUIDWithString:kOPhoneServiceUUID]];
    [peripheral discoverServices:servicesToScanFor];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"[BLE Manager] CentralManager Did Disconnect from peripheral: %@", peripheral);
    NSLog(@"Error: %@", error);
    if (peripheral == self.currentPeripheral) {
        _currentPeripheral = nil;
        self.characteristic = nil;
    }
    if ([self.delegate respondsToSelector:@selector(oNotePeripheralDidDisconnect:error:)]) {
        [self.delegate oNotePeripheralDidDisconnect:peripheral error:error];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"[BLE Manager] CentralManager Failed connecting to peripheral: %@", peripheral);
    NSLog(@"Error: %@", error);
    if ([self.delegate respondsToSelector:@selector(oNotePeripheralDidFailToConnect:error:)]) {
        [self.delegate oNotePeripheralDidFailToConnect:peripheral error:error];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"[BLE Manager] CentralManager discovered peripheral: %@", peripheral);
    NSLog(@"Advertisement data: %@", advertisementData);
    if (![self.mutableDiscoveredPeripherals containsObject:peripheral]) {
        [self.mutableDiscoveredPeripherals addObject:peripheral];
        if ([self.delegate respondsToSelector:@selector(oNotePeripheralWasDiscovered:)]) {
            [self.delegate oNotePeripheralWasDiscovered:peripheral];
        }
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}


#pragma mark - CBPeripheralDelegate Methods

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"[BLE Manager] Wrote value for characteristic %@", characteristic.UUID.UUIDString);
    if ([self.delegate respondsToSelector:@selector(oNotePeripheralDidWriteDataForCharacteristic:error:)]) {
        [self.delegate oNotePeripheralDidWriteDataForCharacteristic:characteristic error:error];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        if ([self.delegate respondsToSelector:@selector(oNotePeripheralDidFailToConnect:error:)]) {
            [self.delegate oNotePeripheralDidFailToConnect:peripheral error:error];
        }
    }
    for (CBService *service in peripheral.services) {
        NSLog(@"[BLE Manager] Peripheral discovered service: %@", service.UUID.UUIDString);
        if ([service.UUID.UUIDString isEqualToString:kOPhoneServiceUUID]) {
            [peripheral discoverCharacteristics:nil forService:service];
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(oNotePeripheralDidFailToConnect:error:)]) {
        NSError *err = [[NSError alloc] initWithDomain:@"OPhoneErrorDomain" code:0 userInfo:@{ NSLocalizedDescriptionKey : @"Service not found on peripheral."}];
        [self.delegate oNotePeripheralDidFailToConnect:peripheral error:err];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error) {
        if ([self.delegate respondsToSelector:@selector(oNotePeripheralDidFailToConnect:error:)]) {
            [self.delegate oNotePeripheralDidFailToConnect:peripheral error:error];
        }
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"Discovered characteristic: %@", characteristic.UUID.UUIDString);
        if ([characteristic.UUID.UUIDString isEqualToString:kOPhoneTXCharacteristicUUID]) {

            self.characteristic = characteristic;
            _currentPeripheral = peripheral;
            if ([self.delegate respondsToSelector:@selector(oNotePeripheralDidConnect:)]) {
                [self.delegate oNotePeripheralDidConnect:peripheral];
            }
            
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(oNotePeripheralDidFailToConnect:error:)]) {
        NSError *err = [[NSError alloc] initWithDomain:@"OPhoneErrorDomain" code:0 userInfo:@{ NSLocalizedDescriptionKey : @"TX Characteristic not found." }];
        [self.delegate oNotePeripheralDidFailToConnect:peripheral error:err];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"[BLE Manager] Peripheral Updated Characteristic %@", characteristic);
    if (error) { NSLog(@"Error: %@", error); }
}

@end