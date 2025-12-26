//
//  BreedsListViewState.swift
//  FeatureBreedsList
//

import Foundation

struct BreedsListViewState {
    let title: String
    let content: Content

    enum Content: Equatable {
        case loading(String)
        case loaded([Item], searchText: String, isLoadingMore: Bool = false)
        case error(String, retryText: String)
    }

    struct Item: Identifiable, Hashable {
        let id: String
        let name: String
        let origin: String
        let imageUrl: String?
        let isFavourite: Bool
    }
}
