//
//  CompactNetworkLoggerPlugin.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 20.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import Moya
import Result

/// Logs network activity (outgoing requests and incoming responses).
public final class CompactNetworkLoggerPlugin: PluginType {
    fileprivate let loggerId = "Moya_Logger"
    fileprivate let dateFormatString = "dd/MM/yyyy HH:mm:ss"
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let separator = ", "
    fileprivate let terminator = "\n"
    fileprivate let cURLTerminator = "\\\n"
    fileprivate let output: (_ seperator: String, _ terminator: String, _ items: Any...) -> Void
    fileprivate let responseDataFormatter: ((Data) -> (Data))?

    /// If true, also logs response body data.
    public let verbose: Bool
    public let cURL: Bool

    // swiftlint:disable:next line_length
    public init(verbose: Bool = false, cURL: Bool = false, output: @escaping (_ seperator: String, _ terminator: String, _ items: Any...) -> Void = CompactNetworkLoggerPlugin.reversedPrint, responseDataFormatter: ((Data) -> (Data))? = nil) {
        self.cURL = cURL
        self.verbose = verbose
        self.output = output
        self.responseDataFormatter = responseDataFormatter
    }

    public func willSend(_ request: RequestType, target: TargetType) {
        guard let url = request.request?.url else {
            return
        }

        log.info(url)
        if let data = request.request?.httpBody,
            let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            log.verbose("with parameters: \(json)")
        }
    }

    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            if let statusCode = response.response?.statusCode {
                log.info("Success with code: \(statusCode)")
            } else {
                log.info("Success")
            }
        } else if case .failure(let error) = result {
            log.error(error)
        } else {
            log.warning("Received empty network response for \(target).")
        }
    }
 
    fileprivate func outputItems(_ items: [String]) { }
}

extension CompactNetworkLoggerPlugin {
    public static func reversedPrint(seperator: String, terminator: String, items: Any...) {
        print(items, separator: seperator, terminator: terminator)
    }
}
