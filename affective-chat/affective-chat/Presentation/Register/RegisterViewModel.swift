//
//  RegisterViewModel.swift
//  affective-chat
//
//  Created by vfu on 15.11.17.
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
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init() {

        let isRegistering = ActivityIndicator()
        self.isRegistering = isRegistering.asDriver()

        let validUsername = username
            .filterNil()
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        registerTap
            .subscribe(onNext: {
                print("register tap")
            })
            .disposed(by: disposeBag)

        isRegistered = registerTap
            .debug("registerTap")
            .map { UserDefaults.standard.value(forKey: Constants.tokenKey) as? String }
            .filterNil()
            .withLatestFrom(validUsername) { ($0, $1) }
            .flatMap {
                return apiProvider.rx
                    .request(.newDevice(username: $1, token: $0))
                    .filterSuccessfulStatusCodes()
                    .asObservable()
                    .materialize()
                    .trackActivity(isRegistering)
            }
            .map { $0.element != nil && $0.error == nil }
            .asDriver(onErrorJustReturn: false)

    }
}
