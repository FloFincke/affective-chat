//
//  AppDelegate.swift
//  affective-chat
//
//  Created by Florian Fincke on 08.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import UIKit
import CoreData
import SwiftyBeaver

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Services

    private var dataStore = CoreDataStack()
    private var notificationHandler = NotificationHandler()

    private var bandConnection = MBConnection()
    private var bandDataStore = MBDataStore()
    private var bandDataSubscriber: MBDataSubscriber?

    // MARK: - UIApplicationDelegate Functions
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N[$l] $F - $M"
        console.minLevel = .debug
        log.addDestination(console)

        let file = FileDestination()
        file.format = "$DHH:mm:ss.SSS$d $L $N[$l] $F - $M"
        file.minLevel = .info
        log.addDestination(file)

        log.info(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])

        if let notification = launchOptions?[.remoteNotification] as? [String: Any],
            let aps = notification["aps"] as? [String: Any] {
            log.debug("\(aps)")
        }

        notificationHandler.registerForPushNotifications()
        notificationHandler.userInteractedWithPush
            .subscribe(onNext: { [weak self] _ in
                self?.bandDataSubscriber?.stopHeartRateUpdates()
                self?.bandDataStore.sendSensorData()
            })

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

        bandDataSubscriber = MBDataSubscriber(
            connection: bandConnection,
            dataStore: bandDataStore
        )

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
        
        log.warning("Failed to register: \(error)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        guard let aps = userInfo["aps"] as? [String: Any] else { return }
        log.debug("\(aps)")

        // TODO: Schedule is receptible notification
        bandDataSubscriber?.startHeartRateUpdates()
        notificationHandler.scheduleIsReceptibleNotification(inSeconds: 5)
    }

}

