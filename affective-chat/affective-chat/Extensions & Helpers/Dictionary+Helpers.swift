//
//  Dictionary+Helpers.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 22.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

extension Dictionary { }

func += <K, V> (left: inout [K: V], right: [K: V]) {
    for (k, v) in right {
        left[k] = v
    }
}
