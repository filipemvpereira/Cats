//
//  BreedDetailViewState.swift
//  FeatureBreedDetail
//

import Foundation

struct BreedDetailViewState {
    let content: Content

    enum Content {
        case loading(String)
        case loaded(Breed)
        case error(String, retryText: String)
    }

    struct Breed {
        let id: String
        let name: String
        let origin: String
        let temperament: String
        let description: String
        let imageUrl: String?
        let isFavourite: Bool
    }
}
