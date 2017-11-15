//
//  AffectiveChatEndpoint.swift
//  affective-chat
//
//  Created by vfu on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import Moya

private let serverUrl = "http://www.google.com"

//let ACProvider = MoyaProvider<ServerAPI>()
let ACProvider = MoyaProvider<ServerAPI>(plugins: [NetworkLoggerPlugin()])

enum ServerAPI {

}

extension ServerAPI: TargetType {

    var baseURL: URL {
        return URL(string: serverUrl)!
    }

    var path: String {
        return ""
    }

    var method: Moya.Method {
        return .get
    }

    var parameters: [String: Any]? {
        let params = [String: Any]()
        print(params)
        return params
    }

    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        return .requestPlain
    }

    var validate: Bool {
        return false
    }

    var headers: [String : String]? {
        return nil
    }

}
