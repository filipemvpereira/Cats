//
//  MockNetworkService.swift
//  CoreTests
//

import Foundation
import Network

public final class MockNetworkService: NetworkService {

    public var mockResponse: NetworkResponse?
    public var mockError: Error?
    public var lastRequest: NetworkRequest?

    public init() {}

    public func request(request: NetworkRequest) async throws -> NetworkResponse {
        lastRequest = request

        if let error = mockError {
            throw error
        }

        guard let response = mockResponse else {
            throw NetworkError.noData
        }

        return response
    }
}
