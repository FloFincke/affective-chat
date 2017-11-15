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

class RegisterViewModel {

    let username = PublishSubject<String?>()
    let registerTap = PublishSubject<Void>()
    let isRegistered: Driver<Bool>
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init() {
        let validUsername = username
            .filterNil()
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        isRegistered = registerTap
            .map { UserDefaults.standard.value(forKey: Constants.tokenKey) as? String }
            .filterNil()
            .withLatestFrom(validUsername) { ($0, $1) }
            .flatMapLatest { apiProvider.rx.request(.newDevice(username: $1, token: $0)) }
            .filterSuccessfulStatusCodes()
            .map { _ in true }
            .asDriver(onErrorJustReturn: false)
    }
}
