//
//  File.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 19.12.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {

    func flatMap<A: AnyObject, O: ObservableType>(
        weak obj: A, selector: @escaping (A, Self.E) throws -> O) -> Observable<O.E> {

        return flatMap { [weak obj] value -> Observable<O.E> in
            try obj.map { try selector($0, value).asObservable() } ?? .empty()
        }
    }

    func flatMapFirst<A: AnyObject, O: ObservableType>(
        weak obj: A, selector: @escaping (A, Self.E) throws -> O) -> Observable<O.E> {

        return flatMapFirst { [weak obj] value -> Observable<O.E> in
            try obj.map { try selector($0, value).asObservable() } ?? .empty()
        }
    }

    func flatMapWithIndex<A: AnyObject, O: ObservableType>(
        weak obj: A, selector: @escaping (A, Self.E, Int) throws -> O) -> Observable<O.E> {

        return flatMapWithIndex { [weak obj] value, index -> Observable<O.E> in
            try obj.map { try selector($0, value, index).asObservable() } ?? .empty()
        }
    }

    func flatMapLatest<A: AnyObject, O: ObservableType>(
        weak obj: A, selector: @escaping (A, Self.E) throws -> O) -> Observable<O.E> {
        return flatMapLatest { [weak obj] value -> Observable<O.E> in
            try obj.map { try selector($0, value).asObservable() } ?? .empty()
        }
    }
}
