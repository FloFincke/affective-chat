//
//  ListViewController.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit
import RxSwift

class ListViewController: UIViewController {

    private let listView = ListView()
    private let viewModel: ListViewModel
    private let disposeBag = DisposeBag()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd.MM.yyyy"
        return dateFormatter
    }()

    // MARK: - Lifecycle

    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        listView.phoneIdLabel.text = UserDefaults.standard.string(forKey: Constants.phoneIdKey)
        updateLabels()

        listView.testTrackingButton.rx.tap
            .bind(to: viewModel.trackTap)
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(Constants.labelsUpdatedNotification)
            .subscribe(onNext: { [weak self] _ in self?.updateLabels() })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(NSNotification.Name.UIApplicationDidBecomeActive)
            .subscribe(onNext: { [weak self] _ in self?.updateLabels() })
            .disposed(by: disposeBag)

        view.addSubview(listView)
        listView.autoPinEdgesToSuperviewEdges()
    }

    // MARK: - Private Functions

    private func updateLabels() {
        if let date = UserDefaults.standard.value(forKey: Constants.lastSilentPushKey) as? Date {
            listView.lastSilentPushLabel.text = "Push received: \(dateFormatter.string(from: date))"
        }

        if let date = UserDefaults.standard.value(forKey: Constants.notConnectedKey) as? Date {
            listView.notConnectedLabel.text = "Not connected: \(dateFormatter.string(from: date))"
        }

        if let date = UserDefaults.standard.value(forKey: Constants.alreadyTrackingKey) as? Date {
            listView.alreadyTrackingLabel.text = "Already tracking: \(dateFormatter.string(from: date))"
        }

        if let date = UserDefaults.standard.value(forKey: Constants.lastDataSentKey) as? Date {
            listView.lastDataSentLabel.text = "Data sent: \(dateFormatter.string(from: date))"
            let successful = UserDefaults.standard.bool(forKey: Constants.lastDataSentSuccessfulKey)
            listView.lastDataSentSuccessful.text = "Successful: \(successful)"
        }

        if let date = UserDefaults.standard.value(forKey: Constants.lastCancelledKey) as? Date {
            listView.lastCancelledLabel.text = "Cancelled: \(dateFormatter.string(from: date))"
        }
    }

}
