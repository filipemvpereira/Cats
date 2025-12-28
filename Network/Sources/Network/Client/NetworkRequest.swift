//
//  NetworkRequest.swift
//  Network
//

import Foundation

public class NetworkRequest {

    public enum HttpMethod {
        case get
        case post
    }

    public let method: HttpMethod
    public let url: String
    public let body: Data?

    public init(
        method: HttpMethod,
        url: String,
        body: Data? = nil
    ) {
        self.method = method
        self.url = url
        self.body = body
    }
}
