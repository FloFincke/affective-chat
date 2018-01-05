//
//  NSManagedObjectContext+Helpers.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 05.01.18.
//  Copyright © 2018 Florian Fincke. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

extension NSManagedObjectContext {

    func insertNewObject<T: NSManagedObject>() -> T {
        return NSEntityDescription.insertNewObject(
            forEntityName: String(describing: T.self),
            // swiftlint:disable:next force_cast
            into: self) as! T
    }

}

extension Reactive where Base: NSManagedObjectContext {

    func fetchEntities<E>(for request: NSFetchRequest<E>) -> Observable<[E]> {
        return Observable.create { observer in
            self.base.perform {
                do {
                    let result = try self.base.fetch(request)
                    observer.onNext(result)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }

            return Disposables.create()
            }.observeOn(MainScheduler.instance)
    }

    func object<T: NSManagedObject>(withId objectID: NSManagedObjectID) -> Observable<T?> {
        return Observable.create { observer in
            self.base.perform {
                do {
                    let object = try self.base.existingObject(with: objectID) as? T
                    observer.onNext(object)
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }
    }

    func save() -> Observable<Void> {
        return Observable.create { observer in
            guard self.base.hasChanges else {
                observer.onNext(())
                observer.onCompleted()
                return Disposables.create()
            }

            self.base.perform {
                do {
                    try self.base.save()
                    observer.onNext(())
                    observer.onCompleted()
                } catch let error {
                    observer.onError(error)
                }
            }

            return Disposables.create()
        }
    }

    func recursiveSave() -> Observable<Void> {
        return save().flatMapLatest { _ -> Observable<Void> in
            if let parent = self.base.parent {
                return parent.rx.recursiveSave()
            }

            return Observable.just(())
        }
    }

}

