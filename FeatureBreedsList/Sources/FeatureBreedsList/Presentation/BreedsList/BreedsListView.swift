//
//  BreedsListView.swift
//  FeatureBreedsList
//

import CoreResources
import CoreUI
import SwiftUI

public struct BreedsListView: View {

    @StateObject var viewModel: BreedsListViewModel
    @State private var searchText: String = ""

    private let navigator: any Navigator

    init(viewModel: BreedsListViewModel, navigator: any Navigator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.navigator = navigator
    }

    public var body: some View {
        BreedsListScreen(
            state: viewModel.state,
            onBreedTap: { breedId in
                navigator.navigate(to: .breedDetail(id: breedId))
            },
            onFavouriteTap: { breedId in
                viewModel.toggleFavourite(breedId: breedId)
            },
            onRetry: {
                Task {
                    await viewModel.retry()
                }
            },
            onLoadMore: {
                await viewModel.loadMore()
            }
        )
        .searchable(text: $searchText, prompt: searchPlaceholder)
        .onChange(of: searchText) { _, newValue in
            Task {
                await viewModel.search(query: newValue)
            }
        }
        .onChange(of: viewModel.state.content) { _, newContent in
            if case .loaded(_, let stateSearchText, _, _, _) = newContent {
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

    private var searchPlaceholder: String {
        if case .loaded(_, _, let placeholder, _, _) = viewModel.state.content {
            return placeholder
        }
        return ""
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

        case .loaded(let items, _, _, let emptyMessage, let isLoadingMore):
            if items.isEmpty {
                BreedsListEmptyView(emptyMessage: emptyMessage)
            } else {
                breedsList(items: items, isLoadingMore: isLoadingMore)
            }

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
                            ImageView(imageUrl: item.imageUrl, cornerRadius: 12)
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

struct ImageView: View {
    let imageUrl: String?
    let cornerRadius: CGFloat

    var body: some View {
        AsyncImage(url: imageUrl.flatMap { URL(string: $0) }) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        ProgressView()
                    }
            case .success(let image):
                GeometryReader { geometry in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                }
                .aspectRatio(1, contentMode: .fit)
            case .failure:
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    }
            @unknown default:
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
            }
        }
    }
}

struct BreedsListEmptyView: View {
    let emptyMessage: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundStyle(.gray)

            Text(emptyMessage)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    searchText: "",
                    searchPlaceholder: "Search breeds",
                    emptyMessage: "No breeds found"
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
                    searchPlaceholder: "Search breeds",
                    emptyMessage: "No breeds found",
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

#Preview("Empty") {
    NavigationStack {
        BreedsListScreen(
            state: BreedsListViewState(
                title: "Cat Breeds",
                content: .loaded(
                    [],
                    searchText: "",
                    searchPlaceholder: "Search breeds",
                    emptyMessage: "No breeds found"
                )
            ),
            onBreedTap: { _ in },
            onFavouriteTap: { _ in },
            onRetry: {},
            onLoadMore: {}
        )
    }
}
