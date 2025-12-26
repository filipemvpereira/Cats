//
//  BreedsListViewModel.swift
//  FeatureBreedsList
//

import Combine
import Foundation

@MainActor
class BreedsListViewModel: ObservableObject {

    @Published private(set) var state: BreedsListViewState

    init() {
        self.state = BreedsListViewState(
            title: "Cat Breeds",
            content: .loading("Loading breeds...")
        )
    }

    func initialize() async {
        // TODO: Load breeds from repository
    }

    func refresh() async {
        // TODO: Refresh breeds
    }

    func retry() async {
        // TODO: Retry loading
    }

    func loadMore() async {
        // TODO: Load more breeds (pagination)
    }

    func search(query: String) {
        // TODO: Filter breeds by name
        guard case .loaded(let items, _, let isLoadingMore) = state.content else {
            return
        }
        state = BreedsListViewState(
            title: state.title,
            content: .loaded(items, searchText: query, isLoadingMore: isLoadingMore)
        )
    }
}
