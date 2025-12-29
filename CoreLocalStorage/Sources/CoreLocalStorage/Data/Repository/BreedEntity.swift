//
//  BreedEntity.swift
//  CoreLocalStorage
//

import Foundation
import SwiftData

@Model
final class BreedEntity {
    @Attribute(.unique) var id: String
    var name: String
    var origin: String
    var temperament: String
    var breedDescription: String
    var imageUrl: String?
    var isFavorite: Bool
    var lastUpdated: Date

    init(
        id: String,
        name: String,
        origin: String,
        temperament: String,
        breedDescription: String,
        imageUrl: String?,
        isFavorite: Bool = false,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.breedDescription = breedDescription
        self.imageUrl = imageUrl
        self.isFavorite = isFavorite
        self.lastUpdated = lastUpdated
    }
}

extension BreedEntity {
    func toDomain() -> LocalBreed {
        LocalBreed(
            id: id,
            name: name,
            origin: origin,
            temperament: temperament,
            description: breedDescription,
            imageUrl: imageUrl,
            isFavorite: isFavorite,
            lastUpdated: lastUpdated
        )
    }

    static func from(_ breed: LocalBreed) -> BreedEntity {
        BreedEntity(
            id: breed.id,
            name: breed.name,
            origin: breed.origin,
            temperament: breed.temperament,
            breedDescription: breed.description,
            imageUrl: breed.imageUrl,
            isFavorite: breed.isFavorite,
            lastUpdated: breed.lastUpdated
        )
    }
}
