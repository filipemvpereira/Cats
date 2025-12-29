//
//  LocalBreed.swift
//  CoreLocalStorage
//

import Foundation

public struct LocalBreed: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let origin: String
    public let temperament: String
    public let description: String
    public let imageUrl: String?
    public let isFavorite: Bool
    public let lastUpdated: Date

    public init(
        id: String,
        name: String,
        origin: String,
        temperament: String,
        description: String,
        imageUrl: String?,
        isFavorite: Bool,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.description = description
        self.imageUrl = imageUrl
        self.isFavorite = isFavorite
        self.lastUpdated = lastUpdated
    }
}
