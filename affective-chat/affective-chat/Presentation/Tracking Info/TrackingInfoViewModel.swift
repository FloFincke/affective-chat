//
//  TrackingInfoViewModel.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 13.12.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

class TrackingInfoViewModel {

    let trackTap = PublishSubject<Void>()
    private let disposeBag = DisposeBag()

    init(dataCollectionCycle: DataCollectionCycle) {
        trackTap
            .subscribe(onNext: {
                dataCollectionCycle.start(withDuration: 30, timeoutAfter: 15, message: "")
            })
            .disposed(by: disposeBag)
    }
}
