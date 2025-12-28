//
//  NetworkResponse.swift
//  Network
//

import Foundation

public class NetworkResponse {

    public let statusCode: Int
    public let body: Data

    public init(statusCode: Int, body: Data) {
        self.statusCode = statusCode
        self.body = body
    }
}
