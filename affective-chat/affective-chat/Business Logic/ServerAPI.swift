//
//  ServerAPI.swift
//  affective-chat
//
//  Created by vfu on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import Moya

private let serverUrl = "http://localhost:8080/"
private let newDevicePath = "newDevice"
private let usernameParameter = "username"
private let tokenParameter = "token"

//let apiProvider = MoyaProvider<ServerAPI>()
let apiProvider = MoyaProvider<ServerAPI>(plugins: [NetworkLoggerPlugin()])

enum ServerAPI {
    case newDevice(username: String, token: String)
}

extension ServerAPI: TargetType {

    var baseURL: URL {
        return URL(string: serverUrl)!
    }

    var path: String {
        switch self {
        case .newDevice:
            return newDevicePath
        }
    }

    var method: Moya.Method {
        switch self {
        case .newDevice:
            return .post
        }
    }

    var parameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case .newDevice(let username, let token):
            params[usernameParameter] = username
            params[tokenParameter] = token
        }
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
