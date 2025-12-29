//
//  Breed.swift
//  CoreBreeds
//

import Foundation

public struct Breed: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let origin: String
    public let temperament: String
    public let description: String
    public let imageUrl: String?
    public let isFavourite: Bool

    public init(
        id: String,
        name: String,
        origin: String,
        temperament: String,
        description: String,
        imageUrl: String?,
        isFavourite: Bool
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.description = description
        self.imageUrl = imageUrl
        self.isFavourite = isFavourite
    }
}
