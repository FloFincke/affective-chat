//
//  RegisterView.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture
import PureLayout

class RegisterView: UIView {

    var stackView: UIStackView!
    var textField: UITextField!
    var button: UIButton!
    private var shouldSetupConstraints = true
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white

        rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in self?.endEditing(true) })
            .disposed(by: disposeBag)

        textField = UITextField()
        textField.textAlignment = .center
        textField.placeholder = "Username"
        textField.clipsToBounds = true
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor

        button = UIButton()
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)

        stackView = UIStackView(arrangedSubviews: [textField, button])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 20
        addSubview(stackView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func updateConstraints() {
        if shouldSetupConstraints {
            shouldSetupConstraints = false
        }
        super.updateConstraints()

        stackView.autoCenterInSuperview()
        stackView.autoPinEdge(toSuperviewEdge: .left, withInset: 60)
        textField.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
        textField.autoSetDimension(.height, toSize: 32)
        button.autoSetDimensions(to: CGSize(width: 80, height: 44))
    }

}
