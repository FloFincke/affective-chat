//
//  SocketConnection.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 16.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import Foundation
import SocketIO
import RxSwift

enum SocketIOError: Error {
    case missingUsername
}

class SocketConnection {

    let newMessages: Observable<[[String: Any]]>
    private let newMessagesPublishSubject = PublishSubject<[[String: Any]]>()

    private let manager: SocketManager
    private let socket: SocketIOClient
    private var isConnected = false
    private var username: String? {
        return UserDefaults.standard.string(forKey: Constants.UserDefaults.usernameKey)
    }

    private let dateFormatter = DateFormatter.forMessageTimestamp()
    private let disposeBag = DisposeBag()

    // MARK: - Singleton
    static let shared = SocketConnection()
    private init() {
//        let url = URL(string: "http://10.180.23.70:3000")!
        let url = URL(string: "\(serverUrl):3000")!
        manager = SocketManager(socketURL: url, config: [.log(true), .compress])
        socket = manager.defaultSocket

        newMessages = newMessagesPublishSubject.asObservable()
        socket.on("newMessage") { [weak self] data, _ in
            if let newMessage = data.first as? [String: Any] {
                self?.newMessagesPublishSubject.onNext([newMessage])
            }
        }
    }

    // MARK: - Public Functions

    func start() {
        guard username != nil else {
            return
        }

        socket.rx.connected
            .filter { $0 }
            .subscribeNext(weak: self, SocketConnection.connectionEstablished)
            .disposed(by: disposeBag)

        socket.connect()
    }

    func stop() {
        guard let username = username else {
            return
        }

        socket.emit("appBackgrounded", username)
        isConnected = false
    }

    // MARK: Messages

    func sendMessageInConversation(
        withId conversationId: String, message: String, recipient: String, timestamp: Date) {

        guard let sender = username else {
            return
        }

        socket.emit("newMessage", conversationId, message, sender, recipient, dateFormatter.string(from: timestamp))
    }

    // MARK: - Private Functions

    private func connectionEstablished(_ connected: Bool) {
        guard !isConnected, let username = username else {
            return
        }

        socket.emit("connectUser", username)
        isConnected = true
        
        getNewMessages(for: username)
    }

    private func getNewMessages(for username: String) {
        socket.emit("getNewMessages", username)
        socket.rx.on("newMessages")
            .map { return $0.0.first as? [[String: Any]] ?? [] }
            .subscribe(onNext: { [weak self] in
                self?.newMessagesPublishSubject.onNext($0)
            })
//            .bind(to: newMessagesPublishSubject)
            .disposed(by: disposeBag)
    }
}
