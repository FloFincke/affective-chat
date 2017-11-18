//
//  DLog.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 15.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation

func dlog(_ format: String = "", file: String = #file, function: String = #function, line: Int = #line) {
    dlogArgs(format: format, [], file: file, function: function, line: line)
}

// swiftlint:disable:next line_length
func dlogArgs(format: String = "", _ args: [CVarArg] = [], file: String = #file, function: String = #function, line: Int = #line) {
    #if DEBUG
        // swiftlint:disable:next line_length
        let s = String(format: "[\(((file as NSString).lastPathComponent as NSString).deletingPathExtension)[\(line)] \(function)] \(format)", arguments: args)
        print(s)
    #endif

    //    CLSLogv(format, getVaList(args))
}
