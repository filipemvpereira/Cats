//
//  BreedDTO.swift
//  CoreBreeds
//

import Foundation

struct BreedDTO: Codable {
    let id: String
    let name: String
    let origin: String?
    let temperament: String?
    let description: String?
    let referenceImageId: String?
    let image: ImageDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case origin
        case temperament
        case description
        case referenceImageId = "reference_image_id"
        case image
    }

    struct ImageDTO: Codable {
        let url: String?
    }

    func toDomain(isFavourite: Bool) -> Breed {
        Breed(
            id: id,
            name: name,
            origin: origin ?? "",
            temperament: temperament ?? "",
            description: description ?? "",
            imageUrl: referenceImageId.map { "https://cdn2.thecatapi.com/images/\($0).jpg" }, //image?.url TODO LIPE
            isFavourite: isFavourite
        )
    }
}
