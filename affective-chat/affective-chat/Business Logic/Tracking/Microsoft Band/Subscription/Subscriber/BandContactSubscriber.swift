//
//  BandContactSubscriber.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 12.12.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

class BandContactSubscriber: MBDataSubscriber {
    
    var bandHasNoContact = PublishSubject<Void>()
    
    private lazy var bandContactUpdateHandler: (MSBSensorBandContactData?, Error?) -> Void = {
        if let error = $1 {
            log.error(error)
        }
        
        if let wornState = $0?.wornState, wornState == .notWorn {
            self.bandHasNoContact.onNext(())
        }
    }
    
    // MARK: - MBDataSubscriber Conformance
    
    var shouldWriteDate = false
    var client: MSBClient?
    let dataKey = ""
    var data = [String: Any]()
    
    // MARK: - Public Functions
    
    func startUpdates() {
        do {
            try client?.sensorManager.startBandContactUpdates(
                to: nil,
                withHandler: bandContactUpdateHandler
            )
        } catch {
            log.error(error)
        }
    }
    
    func stopUpdates() {
        do {
            try client?.sensorManager.stopBandContactUpdatesErrorRef()
        } catch {
            log.error(error)
        }
    }
    
}
