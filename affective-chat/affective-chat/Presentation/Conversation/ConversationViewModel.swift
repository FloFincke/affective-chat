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
    private let socketConnection: SocketConnection
    private let moc: NSManagedObjectContext
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(conversation: Conversation? = nil, socketConnection: SocketConnection, moc: NSManagedObjectContext) {
        self.isNew = Variable(conversation?.title == nil)
        self.hideNameTextField = isNew.asDriver().map { !$0 }
        self.socketConnection = socketConnection
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
        guard let conversationId = conversation.id else {
            return
        }

        let fetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "conversationId == %@", conversationId)
        moc.rx.fetchEntities(for: fetchRequest)
            .map { $0.sorted(by: >) }
            .bind(to: messagesVar)
            .disposed(by: disposeBag)
    }

    // MARK: - Private Functions

    private func addMessage() {
        guard let conversationId = conversation.id else {
            return
        }

        guard conversation.title?.isNotEmpty ?? false
            || senderText.value?.isNotEmpty ?? false
            else {
                return
        }

        guard let body = messageText.value, body.isNotEmpty else {
            return
        }

        if isNew.value {
            conversation.title = senderText.value
            try? moc.save()
            isNew.value = false
        }

        let timestamp = Date()
        let user = UserDefaults.standard.string(forKey: Constants.UserDefaults.usernameKey) ?? ""
        let message: Message = moc.insertNewObject()
        message.conversationId = conversationId
        message.timestamp = timestamp
        message.sender = user
        message.text = body
        
        conversation.lastMessage = message

        try? moc.save()
        socketConnection.sendMessageInConversation(
            withId: conversationId,
            message: body,
            recipient: conversation.title ?? "",
            timestamp: timestamp)
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
