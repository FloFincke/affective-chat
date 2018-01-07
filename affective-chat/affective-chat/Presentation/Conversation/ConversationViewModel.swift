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
    let senderText = Variable<String?>(nil)
    let messageText = Variable<String?>(nil)
    let sendTap = PublishSubject<Void>()

    let hideNameTextField: Driver<Bool>
    private let isNew: Variable<Bool>

    private let conversation: Conversation
    private let moc: NSManagedObjectContext
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(conversation: Conversation? = nil, moc: NSManagedObjectContext) {
        self.isNew = Variable(conversation?.title == nil)
        self.hideNameTextField = isNew.asDriver().map { !$0 }
        self.moc = moc

        if let conversation = conversation {
            self.conversation = conversation
        } else {
            self.conversation = self.moc.insertNewObject()
            try? self.moc.save()
        }

        title = self.conversation.title ?? "New conversation"
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
        guard conversation.title?.isNotEmpty ?? false
            || senderText.value?.isNotEmpty ?? false
            else {
                return
        }

        guard let messageText = messageText.value, messageText.isNotEmpty else {
            return
        }

        if isNew.value {
            conversation.title = senderText.value
            try? moc.save()
            isNew.value = false
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
