//
//  ConversationViewModel.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 05.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import Foundation
import CoreData
import RxCocoa
import RxSwift

class ConversationViewModel {

    let title: String?
    let messages: Driver<[Message]>
    private let messagesVar = Variable<[Message]>([])
    let sendTap = PublishSubject<Void>()
    let messageText = Variable<String?>(nil)

    private let conversation: Conversation
    private let moc: NSManagedObjectContext
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(conversation: Conversation/*? = nil*/, moc: NSManagedObjectContext) {
        self.conversation = conversation
        self.moc = moc

        title = conversation.title
        messages = messagesVar.asDriver()

        sendTap.asObservable()
            .subscribeNext(weak: self, ConversationViewModel.addMessage)
            .disposed(by: disposeBag)

        NotificationCenter.default.rx
            .notification(Notification.Name.NSManagedObjectContextDidSave)
            .filter { ($0.object as? NSManagedObjectContext) == self.moc }
            .subscribeNext(weak: self, ConversationViewModel.handleContextSave)
            .disposed(by: disposeBag)
    }

    // MARK: - Public Functions

    func update() {
        guard let conversationMessages = conversation.messages,
            let validMessages = Array(conversationMessages) as? [Message] else {
                return
        }

        messagesVar.value = validMessages
    }

    // MARK: - Private Functions

    private func addMessage() {
        guard let messageText = messageText.value else {
            return
        }

        let user = UserDefaults.standard.string(forKey: Constants.UserDefaults.usernameKey) ?? ""
        let message: Message = moc.insertNewObject()
        message.timestamp = Date()
        message.sender = user
        message.text = messageText

        conversation.addToMessages(message)
        try? moc.save()
    }

    private func handleContextSave(notifiaction: Notification) {
        guard let userInfo = notifiaction.userInfo else {
            return
        }

        guard let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
            inserts.count > 0 else {
                return
        }

        for insert in inserts {
            guard let message = insert as? Message, message.conversation == conversation else {
                return
            }

            update()
            return
        }
    }
}
