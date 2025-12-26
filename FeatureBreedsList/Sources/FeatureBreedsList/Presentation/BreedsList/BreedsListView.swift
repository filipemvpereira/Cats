//
//  BreedsListView.swift
//  FeatureBreedsList
//

import CoreUI
import SwiftUI

public struct BreedsListView: View {

    @StateObject var viewModel: BreedsListViewModel
    @State private var searchText: String = ""

    public var body: some View {
        BreedsListScreen(
            state: viewModel.state,
            onBreedTap: { _ in },
            onFavouriteTap: { _ in },
            onRetry: {
                Task {
                    await viewModel.retry()
                }
            },
            onLoadMore: {
                await viewModel.loadMore()
            }
        )
        .searchable(text: $searchText, prompt: "Search breeds")
        .onChange(of: searchText) { _, newValue in
            viewModel.search(query: newValue)
        }
        .onChange(of: viewModel.state.content) { _, newContent in
            if case .loaded(_, let stateSearchText, _) = newContent {
                searchText = stateSearchText
            }
        }
        .task {
            await viewModel.initialize()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

struct BreedsListScreen: View {

    let state: BreedsListViewState
    let onBreedTap: (String) -> Void
    let onFavouriteTap: (String) -> Void
    let onRetry: () -> Void
    let onLoadMore: () async -> Void

    var body: some View {
        contentView
            .navigationTitle(state.title)
    }

    @ViewBuilder
    private var contentView: some View {
        switch state.content {
        case .loading(let message):
            LoadingView(message: message)

        case .loaded(let items, _, let isLoadingMore):
            breedsList(items: items, isLoadingMore: isLoadingMore)

        case .error(let message, let retryText):
            ErrorView(message: message, retryText: retryText, onRetry: onRetry)
        }
    }

    private func breedsList(items: [BreedsListViewState.Item], isLoadingMore: Bool) -> some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 24
            ) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            onBreedTap(item.id)
                        } label: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundStyle(.gray)
                                )
                                .overlay(alignment: .topTrailing) {
                                    Button {
                                        onFavouriteTap(item.id)
                                    } label: {
                                        Image(systemName: item.isFavourite ? "star.fill" : "star")
                                            .font(.title3)
                                            .foregroundStyle(item.isFavourite ? .yellow : .white)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .fill(.black.opacity(0.3))
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .padding(8)
                                }
                        }
                        .buttonStyle(.plain)

                        Text(item.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .onAppear {
                        if item == items.last {
                            Task {
                                await onLoadMore()
                            }
                        }
                    }
                }

                if isLoadingMore {
                    loadingMoreView
                }
            }
            .padding()
        }
    }

    private var loadingMoreView: some View {
        HStack {
            Spacer()
            ProgressView()
                .padding()
            Spacer()
        }
    }

}

#Preview("Loading") {
    BreedsListScreen(
        state: BreedsListViewState(
            title: "Cat Breeds",
            content: .loading("Loading breeds...")
        ),
        onBreedTap: { _ in },
        onFavouriteTap: { _ in },
        onRetry: {},
        onLoadMore: {}
    )
}

#Preview("Loaded") {
    NavigationStack {
        BreedsListScreen(
            state: BreedsListViewState(
                title: "Cat Breeds",
                content: .loaded(
                    [
                        BreedsListViewState.Item(
                            id: "1",
                            name: "Abyssinian",
                            origin: "Egypt",
                            imageUrl: nil,
                            isFavourite: true
                        ),
                        BreedsListViewState.Item(
                            id: "2",
                            name: "Bengal",
                            origin: "United States",
                            imageUrl: nil,
                            isFavourite: false
                        ),
                        BreedsListViewState.Item(
                            id: "3",
                            name: "British Shorthair",
                            origin: "United Kingdom",
                            imageUrl: nil,
                            isFavourite: true
                        ),
                        BreedsListViewState.Item(
                            id: "4",
                            name: "Maine Coon",
                            origin: "United States",
                            imageUrl: nil,
                            isFavourite: false
                        ),
                        BreedsListViewState.Item(
                            id: "5",
                            name: "Persian",
                            origin: "Iran",
                            imageUrl: nil,
                            isFavourite: false
                        ),
                        BreedsListViewState.Item(
                            id: "6",
                            name: "Siamese",
                            origin: "Thailand",
                            imageUrl: nil,
                            isFavourite: true
                        )
                    ],
                    searchText: ""
                )
            ),
            onBreedTap: { _ in },
            onFavouriteTap: { _ in },
            onRetry: {},
            onLoadMore: {}
        )
    }
}

#Preview("Error") {
    NavigationStack {
        BreedsListScreen(
            state: BreedsListViewState(
                title: "Cat Breeds",
                content: .error(
                    "Failed to load breeds. Please check your internet connection and try again.",
                    retryText: "Retry"
                )
            ),
            onBreedTap: { _ in },
            onFavouriteTap: { _ in },
            onRetry: {},
            onLoadMore: {}
        )
    }
}

#Preview("Loading More") {
    NavigationStack {
        BreedsListScreen(
            state: BreedsListViewState(
                title: "Cat Breeds",
                content: .loaded(
                    [
                        BreedsListViewState.Item(
                            id: "1",
                            name: "Abyssinian",
                            origin: "Egypt",
                            imageUrl: nil,
                            isFavourite: true
                        ),
                        BreedsListViewState.Item(
                            id: "2",
                            name: "Bengal",
                            origin: "United States",
                            imageUrl: nil,
                            isFavourite: false
                        ),
                        BreedsListViewState.Item(
                            id: "3",
                            name: "British Shorthair",
                            origin: "United Kingdom",
                            imageUrl: nil,
                            isFavourite: false
                        ),
                        BreedsListViewState.Item(
                            id: "4",
                            name: "Maine Coon",
                            origin: "United States",
                            imageUrl: nil,
                            isFavourite: true
                        )
                    ],
                    searchText: "",
                    isLoadingMore: true
                )
            ),
            onBreedTap: { _ in },
            onFavouriteTap: { _ in },
            onRetry: {},
            onLoadMore: {}
        )
    }
}
