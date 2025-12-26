//
//  BreedDetailViewModel.swift
//  FeatureBreedDetail
//

import Combine
import Foundation

@MainActor
class BreedDetailViewModel: ObservableObject {

    @Published private(set) var state: BreedDetailViewState

    private let breedId: String

    init(breedId: String) {
        self.breedId = breedId
        self.state = BreedDetailViewState(content: .loading("Loading"))
    }

    func initialize() async {
        // TODO: Load breed details from repository
    }

    func retry() async {
        // TODO: Load breed details from repository
    }

    func toggleFavourite() {
        // TODO: Toggle favourite status
    }
}
