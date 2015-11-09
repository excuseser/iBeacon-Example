//
//  ViewController.swift
//  iBeaconDemo
//
//  Created by kan xu on 15/11/5.
//  Copyright © 2015年 kan xu. All rights reserved.
//

import UIKit

struct iBeaconModel {
    var name: String
    var RSSI: Int
    init (name: String, RSSI: Int) {
        self.name = name
        self.RSSI = RSSI
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var ibeaconSwitch: UISwitch!
    
    var beaconFinder: KRBeaconOne!
    
    var iBeacons = [iBeaconModel]();

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //BLE获取
//        beaconFinder = KRBeaconOne sharedFinder];
//        //    _beaconFinder.oneDelegate = self;
//        _beaconFinder.uuid = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
//        _beaconFinder.identifier = @"com.sailcore.deerguide.ibeacon";
//        [_beaconFinder awakeDisplay];
        
        
        beaconFinder = KRBeaconOne.sharedFinder()
        beaconFinder.uuid = "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"
        beaconFinder.identifier = "com.sailcore.deerguide.ibeacon"
        
        //    [_beaconFinder setFoundBeaconsHandler:^(NSArray *foundBeacons, CLBeaconRegion *beaconRegion){
        //        //对获得的foundBeacons 判断 5次后返回最小的数据
        //        [_weakmydata.ibeacon updateiBeacons:foundBeacons];
        //     }];
        
//        [_beaconFinder setEnterRegionHandler:^(CLLocationManager *manager, CLRegion *region){
//            [_weakBeaconFinder fireLocalNotificationWithMessage:@"进入介绍区" userInfo:@{@"key" : @"doShareToPeople"}];
//         }];
//        
//        
//        [_beaconFinder setExitRegionHandler:^(CLLocationManager *manager, CLRegion *region){
//            [_weakBeaconFinder stopRanging];
//         }];

        beaconFinder.foundBeaconsHandler = {(foundBeacons, beaconRegion:CLBeaconRegion!) in
            print("\(foundBeacons)")
        }
        
        beaconFinder.enterRegionHandler = {(manager:CLLocationManager!, region:CLRegion!) in
            self.beaconFinder.ranging()
        }
        
        beaconFinder.exitRegionHandler = {(manager:CLLocationManager!, region:CLRegion!) in
            self.beaconFinder.stopRanging()
        }
        
        beaconFinder.bleScanningEnumerator = {(peripheral:CBPeripheral!, advertisements, RSSI) in
            print("The advertisement with identifer:\(peripheral.identifier), state: \(peripheral.state), name: \(peripheral.name), services: \(peripheral.services), advertisements:\(advertisements.description) rssi:\(RSSI)")
            self.iBeacons.append(iBeaconModel(name: peripheral.name!, RSSI: Int(RSSI)))
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData();
            })
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchChange(){
        if (ibeaconSwitch.on == true){
            beaconFinder.ranging()
            beaconFinder.bleScan()
        }
        else{
            beaconFinder.stopRanging()
            beaconFinder.bleStopScan()
        }
    }
    
    // MARK: table delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return iBeacons.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
        
        let row = indexPath.row
        let item = iBeacons[row]
        
        cell.textLabel!.text = item.name;
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //performSegueWithIdentifier("itemSegue", sender:indexPath.row)
    }


}

