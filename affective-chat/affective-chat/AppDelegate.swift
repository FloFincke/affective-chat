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
import RxSwift

let log = SwiftyBeaver.self

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var dataCollectionCycle: DataCollectionCycle!
    private let disposeBag = DisposeBag()

    // MARK: - Services

    private var dataStore: CoreDataStack!
    private var notificationHandler: NotificationHandler!
    private var geolocationService: GeolocationService!
    private var bandConnection: MBConnection!
    private var bandDataStore: MBDataStore!
    private var dataSubscriptionContainer: MBDataSubscriptionContainer!

    // MARK: - UIApplicationDelegate Functions

    // swiftlint:disable:next line_length
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Setup logging

        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d $C$L$c $N[$l] $F - $M"
        console.minLevel = .verbose
        log.addDestination(console)

        let file = FileDestination()
        file.format = "$DHH:mm:ss.SSS$d $L $N[$l] $F - $M"
        file.minLevel = .info
        log.addDestination(file)

        let documentsDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        log.debug("Documents Directory: \(documentsDirectory)")

        // Services

        setupServices()
        notificationHandler.registerForPushNotifications()

        dataCollectionCycle = DataCollectionCycle(
            notificationHandler: notificationHandler,
            bandConnection: bandConnection,
            bandDataStore: bandDataStore,
            dataSubscriptionContainer: dataSubscriptionContainer,
            geolocationService: geolocationService
        )

        // Present initial view controller

        let viewController: UIViewController
        if let username = UserDefaults.standard.value(forKey: Constants.usernameKey),
            let phoneId = UserDefaults.standard.value(forKey: Constants.phoneIdKey) {
            log.info("username: \(username) phoneId: \(phoneId)")

            let viewModel = ListViewModel(dataCollectionCycle: dataCollectionCycle)
            viewController = ListViewController(viewModel: viewModel)
        } else {
            let viewModel = RegisterViewModel()
            viewController = RegisterViewController(viewModel: viewModel)
        }

        window = UIWindow()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        // Handle Notification
        log.debug(launchOptions?[.remoteNotification])
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            handleNotification(userInfo: notification)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur
        // for certain types of temporary interruptions (such as an incoming phone call or SMS
        // message) or when the user quits the application and it begins the transition to the
        // background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering
        // callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store
        // enough application state information to restore your application to its current state in
        // case it is terminated later.
        // If your application supports background execution, this method is called instead of
        // applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can
        // undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was
        // inactive. If the application was previously in the background, optionally refresh the
        // user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also
        // applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application
        // terminates.
        try? dataStore.save()
    }

    // MARK: - Notifications

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        UserDefaults.standard.set(token, forKey: Constants.tokenKey)
        UserDefaults.standard.synchronize()
        log.debug("Device Token: \(token)")
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        log.warning("Failed to register: \(error)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        guard let aps = userInfo["aps"] as? [String: Any] else { return }
        handleNotification(userInfo: userInfo)
    }

    // MARK: - Public Functions

    func presentList() {
        let viewModel = ListViewModel(dataCollectionCycle: dataCollectionCycle)
        let viewController = ListViewController(viewModel: viewModel)
        window?.rootViewController = viewController
    }

    // MARK: - Private Functions

    private func setupServices() {
        dataStore = CoreDataStack()
        notificationHandler = NotificationHandler()
        geolocationService = GeolocationService()

        bandConnection = MBConnection()
        bandDataStore = MBDataStore()

        let subscriberFactory = MBDataSubscriberFactory()
        dataSubscriptionContainer = MBDataSubscriptionContainer(
            connection: bandConnection,
            dataStore: bandDataStore,
            subscriberFactory: subscriberFactory,
            subscriptionTypes: SubscriptionType.all
        )
    }

    private func handleNotification(userInfo: [AnyHashable: Any]) {
        log.debug(userInfo)
        
        if let duration = userInfo["duration"] as? Double,
            let timeout = userInfo["timeout"] as? Double {
            dataCollectionCycle.start(withDuration: duration, timeoutAfter: timeout)
        } else {
            log.warning("invalid notification received")
        }
    }

}
