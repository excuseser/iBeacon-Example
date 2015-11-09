//
//  KRBeaconCentralManager.m
//  KRBeaconFinder V1.5.1
//
//  Created by Kalvar on 2013/07/01.
//  Copyright (c) 2013 - 2015年 Kalvar. All rights reserved.
//

#import "KRBeaconCentral.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface KRBeaconCentral()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation KRBeaconCentral (fixScanning)


@end

@implementation KRBeaconCentral

@synthesize centralManager     = _centralManager;
@synthesize peripheral         = _peripheral;
@synthesize scanningEnumerator = _scanningEnumerator;

#pragma --mark Public Methods
+(instancetype)sharedCentral
{
    static dispatch_once_t pred;
    static KRBeaconCentral *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRBeaconCentral alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        dispatch_queue_t _centralQueue = dispatch_queue_create("CentralManagerQueue", DISPATCH_QUEUE_SERIAL);
        _centralManager     = [[CBCentralManager alloc] initWithDelegate:self queue:_centralQueue];
        _peripheral         = nil;
        _scanningEnumerator = nil;
    }
    return self;
}

-(void)scanWithEnumerator:(ScanningEnumerator)_enumerator
{
    _scanningEnumerator = _enumerator;
    [self scan];
}

- (BOOL)state{
    if (_centralManager.state != CBCentralManagerStatePoweredOn) {
        return NO;
    }
    return YES;
}

-(void)scanWithUUID:(NSString *)UUID {
    
    [self stopScan];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey,
                             nil];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:UUID]] options:options];
}

-(void)scan
{
    [self stopScan];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey,
                             nil];
    [self.centralManager scanForPeripheralsWithServices:nil options:options];
}

-(void)stopScan
{
    [_centralManager stopScan];
}

#pragma --mark Setters
-(void)setScanningEnumerator:(ScanningEnumerator)_theScanningEnumerator
{
    _scanningEnumerator = _theScanningEnumerator;
}

#pragma --mark CentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
        {
            //Kalvar : 別把 Scan 寫在這裡, 直接使用 Scan 的函式即可
            break;
        }
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if( self.scanningEnumerator ) {
        _scanningEnumerator(peripheral, advertisementData, RSSI);
    }
    
    //Beacons 是不能被連線的，所以就不用做連線
//    self.peripheral = peripheral;
//    [_centralManager connectPeripheral:peripheral options:nil];
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
//    self.peripheral.delegate = self;
//    if (!self.timer) {
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
//                                                      target:self
//                                                    selector:@selector(readRSSI)
//                                                    userInfo:nil
//                                                     repeats:1.0];
//        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
//    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSArray *)serviceUuids
{
    //NSLog(@"discovered a peripheral's services: %@", serviceUuids);
//    [_centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (!error) {
        //NSLog(@"rssi %d", [[peripheral RSSI] integerValue]);
        NSLog(@"peripheral name %@ id %@ rssi %d", peripheral.name, peripheral.identifier, [[peripheral RSSI] integerValue]);
    }
}

- (void)readRSSI{
    
    if (self.peripheral) {
        [self.peripheral readRSSI];
    }
}

@end
