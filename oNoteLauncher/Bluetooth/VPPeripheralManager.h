//
//  VPPeripheralManager.h
//  oNoteLauncher
//
//  Created by Patrick Butkiewicz on 6/23/14.
//  Copyright (c) 2014 Vapor Communications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPCoreBluetoothManager.h"

typedef void(^VPPeripheralManagerWriteValueCompletionBlock)(NSError *error);
typedef void(^VPPeripheralManagerConnectCompletionBlock)(NSError *error);
typedef void(^VPPeripheralManagerDisconnectCompletionBlock)(NSError *error);

@interface VPPeripheralManager : NSObject <VPCoreBluetoothConnectionDelegate>

+ (VPPeripheralManager *)sharedManager;
- (void)configure;
- (void)connectWithCompletion:(VPPeripheralManagerConnectCompletionBlock)completion;
- (void)disconnectWithCompletion:(VPPeripheralManagerDisconnectCompletionBlock)completion;
- (void)writeData:(NSData *)data withCompletion:(VPPeripheralManagerWriteValueCompletionBlock)completion;
@end
