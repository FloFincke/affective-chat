//
//  ListView.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit

class ListView: UIView {

    private let stackView = UIStackView()
    let phoneIdLabel = UILabel()
    let lastSilentPushLabel = UILabel()
    let notConnectedLabel = UILabel()
    let alreadyTrackingLabel = UILabel()
    let lastDataSentLabel = UILabel()
    let lastDataSentSuccessful = UILabel()
    let lastCancelledLabel = UILabel()
    let testTrackingButton = UIButton()

    private var shouldSetupConstraints = true

    // MARK: - Lifecycle

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.white

        stackView.alignment = .fill
        stackView.axis = .vertical
        addSubview(stackView)

        stackView.addArrangedSubview(phoneIdLabel)
        stackView.addArrangedSubview(lastSilentPushLabel)
        stackView.addArrangedSubview(notConnectedLabel)
        stackView.addArrangedSubview(alreadyTrackingLabel)
        stackView.addArrangedSubview(lastCancelledLabel)
        stackView.addArrangedSubview(lastDataSentLabel)
        stackView.addArrangedSubview(lastDataSentSuccessful)

        testTrackingButton.setTitleColor(UIColor.red, for: .normal)
        testTrackingButton.setTitle("Start Tracking", for: .normal)
        addSubview(testTrackingButton)
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

        testTrackingButton.autoSetDimensions(to: CGSize(width: 200, height: 54))
        testTrackingButton.autoAlignAxis(toSuperviewAxis: .vertical)
        testTrackingButton.autoPinEdge(.top, to: .bottom, of: stackView)
    }
}
