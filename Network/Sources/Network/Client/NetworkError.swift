//
//  NetworkError.swift
//  Network
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case serverError(statusCode: Int)
    case networkError(Error)
}
