//
//  NetworkService.swift
//  Network
//

import Foundation

public protocol NetworkService {
    func request(request: NetworkRequest) async throws -> NetworkResponse
}

final class NetworkServiceImpl: NetworkService {

    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func request(request: NetworkRequest) async throws -> NetworkResponse {
        guard let url = URL(string: request.url) else {
            print("[Network] ❌ Invalid URL: \(request.url)")
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .returnCacheDataElseLoad

        switch request.method {
        case .get:
            urlRequest.httpMethod = "GET"
        case .post:
            urlRequest.httpMethod = "POST"
        }

        urlRequest.httpBody = request.body

        logRequest(urlRequest)

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[Network] ❌ Invalid response type")
                throw NetworkError.invalidResponse
            }

            logResponse(httpResponse, data: data)

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            return NetworkResponse(statusCode: httpResponse.statusCode, body: data)
        } catch let error as NetworkError {
            throw error
        } catch {
            print("[Network] ❌ Network error: \(error.localizedDescription)")
            throw NetworkError.networkError(error)
        }
    }

    //TODO LIPE
    private func logRequest(_ request: URLRequest) {
        print("\n[Network] 🚀 Request")
        print("URL: \(request.url?.absoluteString ?? "N/A")")
        print("Method: \(request.httpMethod ?? "N/A")")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("Headers: \(headers)")
        }

        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("")
    }

    //TODO LIPE
    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        print("\n[Network] ✅ Response")
        print("URL: \(response.url?.absoluteString ?? "N/A")")
        print("Status Code: \(response.statusCode)")

        if let headers = response.allHeaderFields as? [String: Any], !headers.isEmpty {
            print("Headers: \(headers)")
        }

        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON Response:\n\(jsonString)")
        } else if let bodyString = String(data: data, encoding: .utf8) {
            print("Response: \(bodyString)")
        } else {
            print("Response: \(data.count) bytes")
        }
        print("")
    }
}
