//
//  TrackingInfoViewController.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit
import RxSwift

class TrackingInfoViewController: UIViewController {

    private let trackingInfoView = TrackingInfoView()
    private let viewModel: TrackingInfoViewModel
    private let disposeBag = DisposeBag()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd.MM.yyyy"
        return dateFormatter
    }()

    // MARK: - Lifecycle

    init(viewModel: TrackingInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        trackingInfoView.phoneIdLabel.text
            = UserDefaults.standard.string(forKey: Constants.UserDefaults.phoneIdKey)
        updateLabels()

        trackingInfoView.testTrackingButton.rx.tap
            .bind(to: viewModel.trackTap)
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(Constants.Notifications.labelsUpdatedNotification)
            .subscribe(onNext: { [weak self] _ in self?.updateLabels() })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(NSNotification.Name.UIApplicationDidBecomeActive)
            .subscribe(onNext: { [weak self] _ in self?.updateLabels() })
            .disposed(by: disposeBag)

        view.addSubview(trackingInfoView)
        trackingInfoView.autoPinEdgesToSuperviewEdges()
    }

    // MARK: - Private Functions

    private func updateLabels() {
        if let date = UserDefaults.standard.value(
            forKey: Constants.TrackingInfos.lastSilentPushKey) as? Date {
            trackingInfoView.lastSilentPushLabel.text
                = "Push received: \(dateFormatter.string(from: date))"
        }

        if let date = UserDefaults.standard.value(
            forKey: Constants.TrackingInfos.notConnectedKey) as? Date {
            trackingInfoView.notConnectedLabel.text
                = "Not connected: \(dateFormatter.string(from: date))"
        }

        if let date = UserDefaults.standard.value(
            forKey: Constants.TrackingInfos.alreadyTrackingKey) as? Date {
            trackingInfoView.alreadyTrackingLabel.text
                = "Already tracking: \(dateFormatter.string(from: date))"
        }

        if let date = UserDefaults.standard.value(
            forKey: Constants.TrackingInfos.lastDataSentKey) as? Date {
            trackingInfoView.lastDataSentLabel.text
                = "Data sent: \(dateFormatter.string(from: date))"
            let successful = UserDefaults.standard.bool(
                forKey: Constants.TrackingInfos.lastDataSentSuccessfulKey)
            trackingInfoView.lastDataSentSuccessful.text
                = "Successful: \(successful)"
        }

        if let date = UserDefaults.standard.value(
            forKey: Constants.TrackingInfos.lastCancelledKey) as? Date {
            trackingInfoView.lastCancelledLabel.text
                = "Cancelled: \(dateFormatter.string(from: date))"
        }
    }

}
