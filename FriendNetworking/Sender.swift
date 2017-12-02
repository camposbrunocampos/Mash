//
//  BluetoothManager.swift
//  FriendNetworking
//
//  Created by Bruno Fernandes Campos on 12/2/17.
//  Copyright © 2017 Bruno Fernandes Campos. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class Sender: NSObject, CBPeripheralManagerDelegate {
    static let sharedInstance = Sender()
    var peripheralManager: CBPeripheralManager?
    
    func initialize() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func sendBeacon() {
        advertiseDevice(region: self.createBeaconRegion()!)
    }
    
    private func advertiseDevice(region : CLBeaconRegion) {
        let peripheralData = region.peripheralData(withMeasuredPower: nil)
        
        self.peripheralManager?.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    }
    
    private func createBeaconRegion() -> CLBeaconRegion? {
        let uuid = UIDevice.current.identifierForVendor?.uuidString;
        print("Uuid used for broadcast" + uuid!)
        let proximityUUID = UUID(uuidString: uuid!)
        let major : CLBeaconMajorValue = 100
        let minor : CLBeaconMinorValue = 1
        let beaconID = "FriendNetworking"
        
        return CLBeaconRegion(proximityUUID: proximityUUID!,
                              major: major, minor: minor, identifier: beaconID)
    }

    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case CBManagerState.poweredOn:
            print("IS POWERED ON")
            sendBeacon()
            break
        default:
            NSLog("defaultState")
            break
        }
    }

}
