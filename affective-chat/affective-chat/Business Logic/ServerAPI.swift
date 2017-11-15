//
//  AffectiveChatEndpoint.swift
//  affective-chat
//
//  Created by vfu on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import Moya

//let ACProvider = RxMoyaProvider<SSIEndpoint>()
let ACProvider = RxMoyaProvider<SSIEndpoint>(plugins: [NetworkLoggerPlugin()])

enum ServerAPI {

}

extension ServerAPI: TargetType {

    public var baseURL: URL {
        return URL(string: requestUrl)!
    }

    public var path: String {
        return ""
    }

    public var method: Moya.Method {
        return .get
    }

    public var parameters: [String: Any]? {
        var params = [String: Any]()
        print(params)
        return params
    }

    public var task: Task {
        return .request
    }

    public var validate: Bool {
        return false
    }

    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

}
