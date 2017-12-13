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

        listView.label.text = UserDefaults.standard.string(forKey: Constants.phoneIdKey)
        listView.testTrackingButton.rx.tap
            .bind(to: viewModel.trackTap)
            .disposed(by: disposeBag)

        view.addSubview(listView)
        listView.autoPinEdgesToSuperviewEdges()
    }

}
