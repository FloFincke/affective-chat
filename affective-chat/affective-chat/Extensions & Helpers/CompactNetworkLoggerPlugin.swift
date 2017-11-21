//
//  CompactNetworkLoggerPlugin.swift
//  SSI 3.0
//
//  Created by Vincent Füseschi on 11.10.17.
//  Copyright © 2017 Codivo. All rights reserved.
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
//        if let request = request as? CustomDebugStringConvertible, cURL {
//            output(separator, terminator, request.debugDescription)
//            return
//        }
//        outputItems(logNetworkRequest(request.request as URLRequest?))
        if let url = request.request?.url {
            log.info(url)
        }

        log.info(request.request?.httpBody)
    }

    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        if case .success(let response) = result {
            log.info(result)
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
