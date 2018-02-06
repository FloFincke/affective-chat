//
//  ServerAPI.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import Moya

let serverUrl = "http://192.168.2.2"
//let serverUrl = "http://172.20.10.4"

// Oettingenstr. 67
//private let serverUrl = "http://10.180.20.198:3000"

// Amalienstr. 17
//private let serverUrl = "http://10.176.82.49:3000"

// Zu Hause
//private let serverUrl = "http://192.168.178.23:3000"

// Emma
//private let serverUrl = "http://192.168.179.24:3000"

private let newDevicePath = "/device/new"
private let usernameParameter = "username"
private let tokenParameter = "token"

private let newDataJsonPath = "/data/recep"
private let newDataPath = "/data/new"
private let idParameter = "id"
private let messageParameter = "message"

//let apiProvider = MoyaProvider<ServerAPI>()
let apiProvider = MoyaProvider<ServerAPI>(plugins: [CompactNetworkLoggerPlugin()])

enum ServerAPI {
    case newDevice(username: String, token: String)
    case newData(id: String, message: String, data: Data, fileName: String)
    case newDataJson(id: String, message: String, data: [String: Any])
}

extension ServerAPI: TargetType {

    var baseURL: URL {
        switch self {
        case .newData(let id, _, _, _):
            return URL(string: "\(serverUrl):3000\(newDataPath)?\(idParameter)=\(id)")!
        case .newDataJson:
            return URL(string: "\(serverUrl):3000\(newDataJsonPath)")!
        default:
            return URL(string: "\(serverUrl):3000")!
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
        case .newDevice, .newData, .newDataJson:
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
        case .newDevice(let username, let token):
            return .requestParameters(
                parameters: [
                    usernameParameter: username,
                    tokenParameter: token
                ],
                encoding: JSONEncoding.default
            )

        case .newData(_, let message, let data, let fileName):
            let messageData = MultipartFormData(
                provider: .data(message.data(using: .utf8)!),
                name: messageParameter)
            let data = MultipartFormData(
                provider: .data(data),
                name: "watch_data",
                fileName: fileName,
                mimeType: "application/zip")
            return .uploadMultipart([messageData, data])

        case .newDataJson(let id, let message, let data):
            let parameters = Task.requestParameters(
                parameters: [
                    "id": id,
                    "message": message,
                    "data": data
                ],
                encoding: JSONEncoding.default)
            return parameters
        }
    }

    var validate: Bool {
        return false
    }

    var headers: [String: String]? {
        return nil
    }

}
