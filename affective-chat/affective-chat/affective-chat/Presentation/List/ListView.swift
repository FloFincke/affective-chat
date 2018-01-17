//
//  ListView.swift
//  affective-chat
//
//  Created by vfu on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit

class ListView: UIView {

    let label = UILabel()
    private var shouldSetupConstraints = true

    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white
        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func updateConstraints() {
        if(shouldSetupConstraints) {
            shouldSetupConstraints = false
        }
        super.updateConstraints()

        label.autoCenterInSuperview()
    }
}
