//
//  BreedDetailViewState.swift
//  FeatureBreedDetail
//

import Foundation

struct BreedDetailViewState {
    let content: Content

    enum Content {
        case loading(String)
        case loaded(Detail)
        case error(String, retryText: String)
    }

    struct Detail {
        let id: String
        let name: String
        let origin: String
        let temperament: String
        let description: String
        let imageUrl: String?
        let isFavourite: Bool
        let sectionOriginTitle: String
        let sectionTemperamentTitle: String
        let sectionDescriptionTitle: String
    }
}
