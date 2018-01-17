//
//  MessagesInbox.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 17.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class MessagesInbox {

    private let dateFormatter = DateFormatter.forMessageTimestamp()
    private let connection: SocketConnection
    private let moc: NSManagedObjectContext
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(connection: SocketConnection, moc: NSManagedObjectContext) {
        self.connection = connection
        self.moc = moc

        connection.newMessages
            .subscribeNext(weak: self, MessagesInbox.saveMessages)
            .disposed(by: disposeBag)
    }

    // MARK: - Private Functions

    private func saveMessages(_ messagesJson: [[String: Any]]) {
        let messagesSaves = messagesJson.map { saveMessage($0) }
        Observable.from(messagesSaves).merge()
//            .map { [weak self] in self?.moc.rx.recursiveSave() }
            .subscribe(onNext: { [weak self] _ in try? self?.moc.save() })
            .disposed(by: disposeBag)
    }

    private func saveMessage(_ messageJson: [String: Any]) -> Observable<Void> {
        guard let conversationId = messageJson["conversationId"] as? String,
            let stringTimestamp = messageJson["timestamp"] as? String,
            let timestamp = dateFormatter.date(from: stringTimestamp),
            let sender = messageJson["sender"] as? String,
            let body = messageJson["body"] as? String
            else {
                return Observable.just(())
        }

        let message: Message = moc.insertNewObject()
        message.conversationId = conversationId
        message.timestamp = timestamp
        message.sender = sender
        message.text = body

        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", conversationId)
        return moc.rx.fetchEntity(for: fetchRequest)
            .map { localConversation in
                var conversation = localConversation
                if conversation == nil {
                    conversation = self.moc.insertNewObject()
                    conversation?.id = conversationId
                    conversation?.title = sender
                }

                conversation?.lastMessage = message
        }
    }
}
