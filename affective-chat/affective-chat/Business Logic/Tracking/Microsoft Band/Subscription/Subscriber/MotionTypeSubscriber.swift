//
//  MotionTypeSubscriber.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

private let motionTypeKey = "motionType"

class MotionTypeSubscriber: MBDataSubscriber {
    
    private lazy var motionTypeUpdateHandler: (MSBSensorDistanceData?, Error?) -> Void = {
        if let error = $1 {
            log.error(error)
        }
        
        if let motionType = $0?.motionType, self.shouldWriteDate {
            self.data[Date().stringTimeIntervalSince1970InMilliseconds] = motionType.rawValue
        }
    }
    
    // MARK: - MBDataSubscriber Conformance
    
    var shouldWriteDate = true
    var client: MSBClient?
    let dataKey = motionTypeKey
    var data = [String: Any]()
    
    // MARK: - Public Functions
    
    func startUpdates() {
        shouldWriteDate = true
        do {
            try client?.sensorManager.startDistanceUpdates(
                to: nil,
                withHandler: motionTypeUpdateHandler
            )
        } catch {
            log.error(error)
        }
    }
    
    func stopUpdates() {
        do {
            try client?.sensorManager.stopDistanceUpdatesErrorRef()
        } catch {
            log.error(error)
        }
    }
    
}
