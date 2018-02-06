//
//  RegisterViewModel.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional
import Moya
import RxSwiftExt

class RegisterViewModel {

    let username = PublishSubject<String?>()
    let registerTap = PublishSubject<Void>()
    let isRegistering: Driver<Bool>
    let isRegistered: Driver<Bool>

    private let socketConnection: SocketConnection
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(socketConnection: SocketConnection) {
        self.socketConnection = socketConnection

        let isRegistering = ActivityIndicator()
        self.isRegistering = isRegistering.asDriver()

        let validUsername = username
            .filterNil()
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

                isRegistered = registerTap
                    .map { UserDefaults.standard.value(forKey: Constants.UserDefaults.tokenKey) as? String }
                    .filterNil()
                    .withLatestFrom(validUsername) { ($0, $1) }
                    .flatMap { token, username -> Observable<(Event<String>, String)> in
                        return apiProvider.rx
                            .request(.newDevice(username: username, token: token))
                            .asObservable()
                            .filterSuccessfulStatusCodes()
                            .mapString()
                            .materialize()
                            .trackActivity(isRegistering)
                            .map { ($0, username) }
                    }
                    .map { (event, username) -> Bool in
                        if let string = event.element {
                            let phoneId = string
                            log.info("Phone ID: \(string)")
                            UserDefaults.standard.set(username, forKey: Constants.UserDefaults.usernameKey)
                            UserDefaults.standard.set(phoneId, forKey: Constants.UserDefaults.phoneIdKey)
                            socketConnection.start()
                            return true
                        } else {
                            return false
                        }
                    }
                    .asDriver(onErrorJustReturn: false)

//        isRegistered = registerTap
//            .withLatestFrom(validUsername)
//            .map { username -> Bool in
//                let phoneId = "5a4f50cbebd4d8179239db7c" //string
//                log.info("Phone ID: \(phoneId)")
//                UserDefaults.standard.set(username, forKey: Constants.UserDefaults.usernameKey)
//                UserDefaults.standard.set(phoneId, forKey: Constants.UserDefaults.phoneIdKey)
//                socketConnection.start()
//                return true
//            }
//            .asDriver(onErrorJustReturn: false)
    }
}
