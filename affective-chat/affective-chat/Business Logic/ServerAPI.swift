//
//  ServerAPI.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import Moya

private let serverUrl = "http://localhost:3000"

private let newDevicePath = "/device/new"
private let usernameParameter = "username"
private let tokenParameter = "token"

private let newDataPath = "/data/new"
private let idParameter = "id"

//let apiProvider = MoyaProvider<ServerAPI>()
//let apiProvider = MoyaProvider<ServerAPI>(plugins: [CompactNetworkLoggerPlugin()])
let apiProvider = MoyaProvider<ServerAPI>(plugins: [NetworkLoggerPlugin()])

enum ServerAPI {
    case newDevice(username: String, token: String)
    case newData(id: String, data: Data)
}

extension ServerAPI: TargetType {

    var baseURL: URL {
        switch self {
        case .newData(let id, _):
            return URL(string: "\(serverUrl)\(newDataPath)?\(idParameter)=\(id)")!
        default:
            return URL(string: serverUrl)!
        }
    }

    var path: String {
        switch self {
        case .newDevice:
            return newDevicePath
        default:
            return ""
        }
    }

    var method: Moya.Method {
        switch self {
        case .newDevice, .newData:
            return .post
        }
    }

    var parameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
        case .newDevice(let username, let token):
            params[usernameParameter] = username
            params[tokenParameter] = token
        default:
            break
        }
        return params
    }

    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .newData(_, let data):
            let data = MultipartFormData(
                provider: .data(data),
                name: "watch_data",
                fileName: "sensor-data.zip",
                mimeType: "application/zip"
            )
            return .uploadMultipart([data])
        default:
            return .requestPlain
        }
    }

    var validate: Bool {
        return false
    }

    var headers: [String : String]? {
        return nil
    }

}
