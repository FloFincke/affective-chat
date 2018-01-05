//
//  ConversationViewController.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 05.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import RxKeyboard

class ConversationViewController: UIViewController {

    var conversationView = ConversationView()

    private let viewModel: ConversationViewModel
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        return dateFormatter
    }()
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(viewModel: ConversationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        view.backgroundColor = UIColor.white

        view.addSubview(conversationView)

        setupTextField()
        setupTableView()
        setupSendButton()

        viewModel.update()
    }

    // MARK: - Setup Functions

    private func setupTableView() {
        conversationView.tableView.estimatedRowHeight = 44
        conversationView.tableView.rowHeight = UITableViewAutomaticDimension
        conversationView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        viewModel.messages
            .drive(conversationView.tableView.rx.items(cellIdentifier: "Cell")) {
                [weak self] _, message, cell in

                cell.textLabel?.numberOfLines = 0
                cell.selectionStyle = .none

                let dateString = self?.dateFormatter.string(from: message.timestamp ?? Date()) ?? ""
                cell.textLabel?.text
                    = "[\(dateString)] \(message.sender ?? "unknown"): \(message.text ?? "")"
            }
            .disposed(by: disposeBag)
    }

    private func setupTextField() {
        conversationView.autoPinEdgesToSuperviewEdges()
        let bottomConstraint = conversationView.typingStackView.autoPin(
            toBottomLayoutGuideOf: self,
            withInset: 0)

        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                let bottomHeight = self?.bottomLayoutGuide.length ?? 0
                bottomConstraint.constant = -max(keyboardVisibleHeight - bottomHeight, 0)
            })
            .disposed(by: disposeBag)

        conversationView.textField.rx.text
            .bind(to: viewModel.messageText)
            .disposed(by: disposeBag)
    }

    private func setupSendButton() {
        let sendTap = conversationView.sendButton.rx.tap
        sendTap
            .bind(to: viewModel.sendTap)
            .disposed(by: disposeBag)
        sendTap
            .subscribeNext(weak: self, ConversationViewController.emptyTextField)
            .disposed(by: disposeBag)
    }

    // MARK: - Private Functions

    private func emptyTextField() {
        conversationView.textField.text = ""
    }
}
