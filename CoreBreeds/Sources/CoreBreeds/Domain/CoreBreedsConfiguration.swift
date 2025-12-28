//
//  CoreBreedsConfiguration.swift
//  CoreBreeds
//

import Foundation

public struct CoreBreedsConfiguration {
    let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    func breedsURL(limit: Int, page: Int) -> String {
        buildURL(path: "/breeds", queryItems: [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "page", value: "\(page)")
        ])
    }

    func breedDetailURL(id: String) -> String {
        buildURL(path: "/breeds/\(id)")
    }

    func breedSearchURL(query: String) -> String {
        buildURL(path: "/breeds/search", queryItems: [
            URLQueryItem(name: "q", value: query)
        ])
    }

    private func buildURL(path: String, queryItems: [URLQueryItem]? = nil) -> String {
        var components = URLComponents(string: baseURL + path)!
        components.queryItems = queryItems
        return components.url!.absoluteString
    }
}
