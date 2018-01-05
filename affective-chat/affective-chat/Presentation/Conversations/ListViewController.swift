//
//  ListViewController.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 04.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class ListViewController: UIViewController {

    var tableView = UITableView()

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
        title = "Conversations"
        view.backgroundColor = UIColor.white

        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()

        setupComposeButton()
        setupTableView()

        viewModel.selectedConversationViewModel
            .filterNil()
            .subscribeNext(weak: self, ListViewController.presentConversation)
            .disposed(by: disposeBag)

        viewModel.update()
    }

    // MARK: - Setup Functions

    private func setupComposeButton() {
        let composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: nil, action: nil)
        navigationItem.rightBarButtonItem = composeButton

//        composeButton.rx.tap
//            .subscribeNext(weak: self, ListViewController.composeButtonTapped)
//            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        viewModel.conversations
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, conversation, cell in
                cell.textLabel?.text = conversation.title
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Conversation.self)
            .bind(to: viewModel.selectedConversation)
            .disposed(by: disposeBag)
    }

    // MARK: - Private Functions

    private func presentConversation(_ viewModel: ConversationViewModel) {
        let viewController = ConversationViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

}
