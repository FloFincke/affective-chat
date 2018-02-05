//
//  ConversationView.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 05.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import UIKit
import PureLayout
import RxSwift
import RxGesture

class ConversationView: UIView {

    let nameConainerView = UIView()
    let nameTextField = TextField()

    let tableView = UITableView()

    let typingContainerView = UIView()
    let typingStackView = UIStackView()
    let textField = TextField()
    let sendButton = UIButton()

    private var shouldSetupConstraints = true
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white

        rx.tapGesture()
            .when(.recognized)
            .subscribeNext(weak: self, ConversationView.viewTapped)
            .disposed(by: disposeBag)

        addSubview(tableView)

        nameConainerView.backgroundColor = UIColor.lightGray
        addSubview(nameConainerView)

        nameTextField.backgroundColor = .white
        nameTextField.placeholder = "Recipient"
        nameConainerView.addSubview(nameTextField)

        typingContainerView.backgroundColor = UIColor.lightGray
        addSubview(typingContainerView)

        typingStackView.axis = .horizontal
        typingStackView.alignment = .center
        typingStackView.spacing = 20
        typingContainerView.addSubview(typingStackView)

        textField.layer.cornerRadius = 4
        textField.backgroundColor = .white
        textField.placeholder = "Message"
        typingStackView.addArrangedSubview(textField)

        sendButton.setTitleColor(.blue, for: .normal)
        sendButton.setTitle("Send", for: .normal)
        typingStackView.addArrangedSubview(sendButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }

    override func updateConstraints() {
        if shouldSetupConstraints {
            shouldSetupConstraints = false
        }
        super.updateConstraints()

        nameConainerView.autoSetDimension(.height, toSize: 44)
        nameConainerView.autoPinEdge(toSuperviewEdge: .top)
        nameConainerView.autoPinEdge(toSuperviewEdge: .left)
        nameConainerView.autoPinEdge(toSuperviewEdge: .right)

        nameTextField.autoSetDimension(.height, toSize: 30)
        nameTextField.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        nameTextField.autoAlignAxis(toSuperviewAxis: .vertical)
        nameTextField.autoAlignAxis(toSuperviewAxis: .horizontal)

        tableView.autoPinEdge(toSuperviewEdge: .top)
        tableView.autoPinEdge(toSuperviewEdge: .left)
        tableView.autoPinEdge(toSuperviewEdge: .right)

        typingContainerView.autoPinEdge(
            .top,
            to: .bottom,
            of: tableView)
        typingContainerView.autoPinEdge(toSuperviewEdge: .left)
        typingContainerView.autoPinEdge(toSuperviewEdge: .bottom)
        typingContainerView.autoPinEdge(toSuperviewEdge: .right)

        typingStackView.autoSetDimension(.height, toSize: 44)
        typingStackView.autoPinEdge(toSuperviewEdge: .top)
        typingStackView.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        typingStackView.autoPinEdge(toSuperviewEdge: .right, withInset: 16)

        textField.autoSetDimension(.height, toSize: 30)
    }

    // MARK: - Private Functions

    private func viewTapped(_ tapGesture: UITapGestureRecognizer) {
        endEditing(true)
    }
}

