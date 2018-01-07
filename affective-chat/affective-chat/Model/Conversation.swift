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
        guard let lastMessage = messages?.lastObject as? Message,
            let timestamp = lastMessage.timestamp
            else {
                return creationDate ?? Date.distantPast
        }

        return timestamp
    }

    // MARK: - Public Functions

    public override func awakeFromInsert() {
        creationDate = Date()
    }

}

func > (lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.firstMessageTimestamp > rhs.firstMessageTimestamp
}
