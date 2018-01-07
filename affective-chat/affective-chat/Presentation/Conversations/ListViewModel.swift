//
//  ListViewModel.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 04.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import Foundation
import CoreData
import RxCocoa
import RxSwift

class ListViewModel {

    let conversations: Driver<[Conversation]>
    private let conversationsVar = Variable<[Conversation]>([])

    let selectedConversation = PublishSubject<Conversation?>()
    let selectedConversationViewModel: Observable<ConversationViewModel?>

    private let moc: NSManagedObjectContext
    private let disposeBag = DisposeBag()

    init(moc: NSManagedObjectContext) {
        self.moc = moc
        conversations = conversationsVar.asDriver()

        selectedConversationViewModel = selectedConversation
            .map { ConversationViewModel(conversation: $0, moc: moc) }

        NotificationCenter.default.rx
            .notification(Notification.Name.NSManagedObjectContextDidSave)
            .filter { ($0.object as? NSManagedObjectContext) == self.moc }
            .subscribeNext(weak: self, ListViewModel.handleContextSave)
            .disposed(by: disposeBag)
    }

    // MARK: - Public Functions

    func update() {
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        moc.rx.fetchEntities(for: fetchRequest)
            .subscribe(onNext: { [weak self] in
                self?.conversationsVar.value = $0.sorted(by: >)
            })
            .disposed(by: disposeBag)
    }

    private func handleContextSave(notifiaction: Notification) {
        guard let userInfo = notifiaction.userInfo else {
            return
        }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>,
            inserts.count > 0 {
            for insert in inserts where insert is Conversation {
                update()
                return
            }
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
            updates.count > 0 {
            for update in updates where update is Conversation {
                self.update()
                return
            }
        }

        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>,
            deletes.count > 0 {
            for delete in deletes where delete is Conversation {
                update()
                return
            }
        }
    }
}
