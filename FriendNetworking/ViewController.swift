//
//  ViewController.swift
//  FriendNetworking
//
//  Created by Bruno Fernandes Campos on 12/2/17.
//  Copyright © 2017 Bruno Fernandes Campos. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var deviceIdLabel: UILabel!
    @IBOutlet weak var beaconStateLabel: UILabel!
    
    var locationManager = CLLocationManager()
    var beaconSender: Sender?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        Sender.sharedInstance.initialize()
        deviceIdLabel.text = UIDevice.current.identifierForVendor?.uuidString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        monitorBeacons()
    }
    
    func monitorBeacons() {
        if CLLocationManager.isMonitoringAvailable(for:
            CLBeaconRegion.self) {
            // Match all beacons with the specified UUID
            let proximityUUID = UUID(uuidString:
                "659DE155-67DA-4AA0-8DDB-DA26A1F854D7")
            let beaconID = "FriendNetworking"
            
            // Create the region and begin monitoring it.
            let region = CLBeaconRegion(proximityUUID: proximityUUID!,
                                        identifier: beaconID)
            self.locationManager.startMonitoring(for: region)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion {
            // Start ranging only if the feature is available.
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(in: region as! CLBeaconRegion)
                
                // Store the beacon so that ranging can be stopped on demand.
//                beaconsToRange.append(region as! CLBeaconRegion)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("SAI FORA")
    }
    var lastState : CLProximity?
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            let nearestBeacon = beacons.first!
        
            let major = CLBeaconMajorValue(nearestBeacon.major)
            let minor = CLBeaconMinorValue(nearestBeacon.minor)
            
            var duration: Double?
            var shouldAnimate: Bool?
            shouldAnimate = lastState != nearestBeacon.proximity
            
            switch nearestBeacon.proximity {
            case .near:
                // Display information about the relevant exhibit.
                self.beaconStateLabel.text = "NEAR"
                duration = 0.8
                break
            case .immediate:
                duration = 0.1
                self.beaconStateLabel.text = "IMMEDIATE"
                break
            case .far:
                duration = 1.3
                self.beaconStateLabel.text = "FAR"
                break
            default:
                // Dismiss exhibit information, if it is displayed.
//                dismissExhibit(major: major, minor: minor)
                break
            }
            
            if let animationTime = duration {
                UIView.animate(withDuration: animationTime,
                               delay:0.0,
                               options:[.allowUserInteraction, .curveEaseInOut],
                               animations: { self.view.alpha = 0 }) { _ in
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                                UIView.animate(withDuration: animationTime, animations: {
                                    self.view.alpha = 1
                                })
                }
                
                
            }
        }
    }
    @IBAction func didTapBroadcastButton(_ sender: Any) {
        Sender.sharedInstance.sendBeacon()
        monitorBeacons()
    }
    
    
}

