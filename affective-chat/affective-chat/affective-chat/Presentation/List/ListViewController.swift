//
//  ListViewController.swift
//  affective-chat
//
//  Created by vfu on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    private let listView = ListView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(listView)
        listView.autoPinEdgesToSuperviewEdges()
    }

}
