//
//  RegisterViewController.swift
//  affective-chat
//
//  Created by vfu on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit
import RxSwift

class RegisterViewController: UIViewController {

    private var registerView: RegisterView!
    private let viewModel: RegisterViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerView = RegisterView()
        view.addSubview(registerView)
        registerView.autoPinEdgesToSuperviewEdges()

        registerView.textField.rx.text.asObservable()
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)

        registerView.button.rx.tap
            .bind(to: viewModel.registerTap)
            .disposed(by: disposeBag)

        viewModel.isRegistered
            .filter { $0 }
            .drive(onNext: { _ in
                UIApplication.shared.keyWindow?.rootViewController = ListViewController()
            })
            .disposed(by: disposeBag)
    }

}
