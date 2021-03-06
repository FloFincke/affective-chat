//
//  RegisterViewController.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit
import RxSwift
import CoreLocation

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

        setupTextField()
        setupButton()

        viewModel.isRegistered
            .filter { $0 }
            .drive(onNext: { _ in
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.presentList()
                }
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Setup Functions

    private func setupTextField() {
        registerView.textField.rx.text.asObservable()
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)

        viewModel.isRegistering
            .map { !$0 }
            .drive(registerView.textField.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    private func setupButton() {
        registerView.button.rx.tap
            .bind(to: viewModel.registerTap)
            .disposed(by: disposeBag)

        viewModel.isRegistering
            .drive(registerView.button.rx.isHidden)
            .disposed(by: disposeBag)
    }

}
