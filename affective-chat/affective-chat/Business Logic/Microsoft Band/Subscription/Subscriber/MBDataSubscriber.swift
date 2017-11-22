//
//  MBDataSubscriber.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 18.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

protocol MBDataSubscriber: class {
//    associatedtype SubscriptionDataType: SubscriptionData
//    var data: [SubscriptionDataType] { get }

    var client: MSBClient? { get set }
    var dataKey: String { get }
    var data: [String: Any] { get set }
    func startUpdates()
    func stopUpdates()
}

extension MBDataSubscriber {
    var name: String {
        return "\(type(of: self))"
    }
}
