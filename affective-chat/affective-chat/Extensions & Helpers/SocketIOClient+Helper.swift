//
//  SocketIOClient+Helper.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 16.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift
import SocketIO

extension Reactive where Base: SocketIOClient {

    func on(_ event: String) -> Observable<([Any], SocketAckEmitter)> {
        return Observable.create { observer in
            self.base.on(event) {
                observer.onNext(($0, $1))
                observer.onCompleted()
            }

            return Disposables.create()
        }
    }

    var connected: Observable<Bool> {
        return self.on("connect")
            .map { _ in true}
            .startWith(false)
    }

}
