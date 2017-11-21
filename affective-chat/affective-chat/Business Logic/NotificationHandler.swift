//
//  NotificationHandler.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 18.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import UserNotifications
import RxSwift

private let isReceptibleActionIdentifier = "isReceptibleAction"
private let isNotReceptibleActionIdentifier = "isNotReceptibleAction"
private let receptibleCategoryIdentifier = "receptibleCategory"

class NotificationHandler: NSObject {

    var userInteractedWithPush = PublishSubject<Void>()

    // MARK: - Lifecycle
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Public Functions

    func scheduleIsReceptibleNotification(inSeconds seconds: Double) {
        let content = UNMutableNotificationContent()
        content.title = "Title"
        content.body = "Are you receptible for messages?"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = receptibleCategoryIdentifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)

        let request = UNNotificationRequest(
            identifier: "IsReceptibleNotification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                guard granted else {
                    if let error = error {
                        log.error(error)
                    }
                    return
                }

                let isReceptibleAction = UNNotificationAction(
                    identifier: isReceptibleActionIdentifier,
                    title: "Receptible",
                    options: [.foreground]
                )

                let isNotReceptibleAction = UNNotificationAction(
                    identifier: isNotReceptibleActionIdentifier,
                    title: "Not receptible",
                    options: [.foreground]
                )

                let receptibleCategory = UNNotificationCategory(
                    identifier: receptibleCategoryIdentifier,
                    actions: [isReceptibleAction, isNotReceptibleAction],
                    intentIdentifiers: [],
                    options: []
                )

                UNUserNotificationCenter.current().setNotificationCategories([receptibleCategory])

                self.notificationSettings()
        }
    }

    // MARK: - Private Functions

    private func notificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            log.info(settings)
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationHandler: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.actionIdentifier == isReceptibleActionIdentifier {
            log.info("user is receptible")
            userInteractedWithPush.onNext(())
        } else if response.actionIdentifier == isReceptibleActionIdentifier {
            log.info("user is not receptible")
            userInteractedWithPush.onNext(())
        }

        completionHandler()
    }
}
