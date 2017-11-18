//
//  AppDelegate.swift
//  affective-chat
//
//  Created by Florian Fincke on 08.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

fileprivate let isReceptibleActionIdentifier = "isReceptibleAction"
fileprivate let isNotReceptibleActionIdentifier = "isNotReceptibleAction"
fileprivate let receptibleCategoryIdentifier = "receptibleCategory"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var dataStore = CoreDataStack()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        if let notification = launchOptions?[.remoteNotification] as? [String: Any],
            let aps = notification["aps"] as? [String: Any] {
            dlog("\(aps)")
        }

        UNUserNotificationCenter.current().delegate = self
        registerForPushNotifications()

        let viewController: UIViewController
        if UserDefaults.standard.value(forKey: Constants.usernameKey) != nil {
            viewController = ListViewController()
        } else {
            let viewModel = RegisterViewModel()
            viewController = RegisterViewController(viewModel: viewModel)
        }

        window = UIWindow()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        scheduleIsReceptibleNotification(inSeconds: 10)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        try? dataStore.save()
    }

    // MARK: - Notifications

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        UserDefaults.standard.set(token, forKey: Constants.tokenKey)
        UserDefaults.standard.synchronize()
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        dlog("Failed to register: \(error)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        guard let aps = userInfo["aps"] as? [String: Any] else { return }
        dlog("\(aps)")
        // TODO: Schedule is receptible notification
    }

    // MARK: - Private Functions

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
                print("Permission granted: \(granted)")
                guard granted else { return }

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

    private func notificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            dlog("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.actionIdentifier == isReceptibleActionIdentifier {
            dlog("receptible")
        } else if response.actionIdentifier == isReceptibleActionIdentifier {
            dlog("not receptible")
        }

        completionHandler()
    }
}

