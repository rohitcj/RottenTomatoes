//
//  NetworkHelper.swift
//  RottenTomatoes
//
//  Created by Rohit Jhangiani on 5/10/15.
//  Copyright (c) 2015 5TECH. All rights reserved.
//

import Foundation

class NetworkHelper {
    static func startMonitoring() {
            AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (networkStatus: AFNetworkReachabilityStatus)
            -> Void in
            switch (networkStatus) {
            case AFNetworkReachabilityStatus.ReachableViaWiFi, AFNetworkReachabilityStatus.ReachableViaWWAN:
                NSNotificationCenter.defaultCenter().postNotificationName("NetworkConnected", object: self)
            case AFNetworkReachabilityStatus.NotReachable, AFNetworkReachabilityStatus.Unknown:
                NSNotificationCenter.defaultCenter().postNotificationName("NetworkError", object: self)
            default:
                NSNotificationCenter.defaultCenter().postNotificationName("NetworkError", object: self)            }
        }
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
    }
    
    static func stopMonitoring() {
        AFNetworkReachabilityManager.sharedManager().stopMonitoring()
    }
    
}