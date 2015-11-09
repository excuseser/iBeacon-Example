//
//  ViewController.m
//  iBeaconDemo-Objc
//
//  Created by kan xu on 15/11/6.
//  Copyright © 2015年 kan xu. All rights reserved.
//

#import "ViewController.h"
#import "KRBeaconOne.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>{
    KRBeaconOne *beaconFinder;
    NSMutableArray *iBeacons;
}

@property (nonatomic, strong) IBOutlet UITableView *listTable;
@property (nonatomic, strong) IBOutlet UISwitch *iBeaconSwitch;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    iBeacons = [NSMutableArray array];
    
    beaconFinder = [KRBeaconOne sharedFinder];
    //    _beaconFinder.oneDelegate = self;
    beaconFinder.uuid = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
    beaconFinder.identifier = @"com.sailcore.deerguide.ibeacon";
    [beaconFinder awakeDisplay];
    
    
    __weak typeof(self) _weakSelf = self;
    __weak typeof(beaconFinder) _weakBeaconFinder = beaconFinder;
    __weak typeof(iBeacons) _weakiBeacons = iBeacons;

    [beaconFinder setFoundBeaconsHandler:^(NSArray *foundBeacons, CLBeaconRegion *beaconRegion){
        NSLog(@"%@", foundBeacons);
    }];
    
    [beaconFinder setEnterRegionHandler:^(CLLocationManager *manager, CLRegion *region){
        [_weakBeaconFinder fireLocalNotificationWithMessage:@"进入iBeacon" userInfo:@{@"key" : @"doShareToPeople"}];
    }];
    
    
    [beaconFinder setExitRegionHandler:^(CLLocationManager *manager, CLRegion *region){
        [_weakBeaconFinder stopRanging];
    }];
    
    [beaconFinder setBleScanningEnumerator:^(CBPeripheral *peripheral, NSDictionary *advertisements, NSNumber *RSSI){
        NSLog(@"The advertisement with identifer: %@, state: %ld, name: %@, services: %@,  description: %@",
               [peripheral identifier],
               (long)[peripheral state],
               [peripheral name],
               [peripheral services],
               [advertisements description]);
        
        [_weakiBeacons addObject:@{@"name":[peripheral name]}];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_weakSelf.listTable reloadData];
        });
        
    }];
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  事件

-(IBAction)switchChange:(id)sender{
    if (_iBeaconSwitch.on == true){
        [beaconFinder ranging];
        [beaconFinder bleScan];
    }
    else{
        [beaconFinder stopRanging];
        [beaconFinder bleStopScan];
    }
}

#pragma mark -  table-代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return iBeacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSUInteger row = [indexPath row];
    NSDictionary *listInfo = iBeacons[row];
    
    cell.textLabel.text = listInfo[@"name"];
    return cell;
}


@end
