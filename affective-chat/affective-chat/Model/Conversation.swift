//
//  Conversation+CoreDataClass.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 05.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Conversation)
public class Conversation: NSManagedObject {

    var firstMessageTimestamp: Date {
        return lastMessage?.timestamp ?? Date.distantPast
    }

    // MARK: - Public Functions

    public override func awakeFromInsert() {
        id = UUID().uuidString
        creationDate = Date()
    }

}

func > (lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.firstMessageTimestamp > rhs.firstMessageTimestamp
}

func > (lhs: Message, rhs: Message) -> Bool {
    return lhs.timestamp ?? Date.distantPast > rhs.timestamp ?? Date.distantPast
}
