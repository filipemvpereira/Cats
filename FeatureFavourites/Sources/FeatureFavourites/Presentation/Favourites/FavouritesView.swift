//
//  FavouritesView.swift
//  FeatureFavourites
//

import CoreResources
import CoreUI
import SwiftUI

public struct FavouritesView: View {

    @StateObject var viewModel: FavouritesViewModel

    private let navigator: any Navigator

    init(viewModel: FavouritesViewModel, navigator: any Navigator) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.navigator = navigator
    }

    public var body: some View {
        FavouritesScreen(
            state: viewModel.state,
            onBreedTap: { breedId in
                navigator.navigate(to: .breedDetail(id: breedId))
            },
            onUnfavouriteTap: { breedId in
                viewModel.unfavourite(breedId: breedId)
            },
            onRetry: {
                Task {
                    await viewModel.retry()
                }
            }
        )
        .task {
            await viewModel.initialize()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
}

struct FavouritesScreen: View {

    let state: FavouritesViewState
    let onBreedTap: (String) -> Void
    let onUnfavouriteTap: (String) -> Void
    let onRetry: () -> Void

    var body: some View {
        contentView
            .navigationTitle(state.title)
    }

    @ViewBuilder
    private var contentView: some View {
        switch state.content {
        case .loading(let message):
            LoadingView(message: message)

        case .loaded(let items, let emptyMessage):
            if items.isEmpty {
                FavouritesEmptyView(emptyMessage: emptyMessage)
            } else {
                favouritesList(items: items)
            }

        case .error(let message, let retryText):
            ErrorView(message: message, retryText: retryText, onRetry: onRetry)
        }
    }

    private func favouritesList(items: [FavouritesViewState.Item]) -> some View {
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
                                        onUnfavouriteTap(item.id)
                                    } label: {
                                        Image(systemName: "star.fill")
                                            .font(.title3)
                                            .foregroundStyle(.yellow)
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
                }
            }
            .padding()
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

struct FavouritesEmptyView: View {
    let emptyMessage: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.slash")
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
    FavouritesScreen(
        state: FavouritesViewState(
            title: "Favourites",
            content: .loading("Loading favourites...")
        ),
        onBreedTap: { _ in },
        onUnfavouriteTap: { _ in },
        onRetry: {}
    )
}

#Preview("Loaded") {
    NavigationStack {
        FavouritesScreen(
            state: FavouritesViewState(
                title: "Favourites",
                content: .loaded(
                    [
                        FavouritesViewState.Item(
                            id: "1",
                            name: "Abyssinian",
                            origin: "Egypt",
                            imageUrl: nil,
                            isFavourite: true
                        ),
                        FavouritesViewState.Item(
                            id: "2",
                            name: "British Shorthair",
                            origin: "United Kingdom",
                            imageUrl: nil,
                            isFavourite: true
                        )
                    ],
                    emptyMessage: "No favourites yet"
                )
            ),
            onBreedTap: { _ in },
            onUnfavouriteTap: { _ in },
            onRetry: {}
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        FavouritesScreen(
            state: FavouritesViewState(
                title: "Favourites",
                content: .loaded(
                    [],
                    emptyMessage: "No favourites yet.\nTap the star on breeds to add them here."
                )
            ),
            onBreedTap: { _ in },
            onUnfavouriteTap: { _ in },
            onRetry: {}
        )
    }
}

#Preview("Error") {
    NavigationStack {
        FavouritesScreen(
            state: FavouritesViewState(
                title: "Favourites",
                content: .error(
                    "Failed to load favourites. Please try again.",
                    retryText: "Retry"
                )
            ),
            onBreedTap: { _ in },
            onUnfavouriteTap: { _ in },
            onRetry: {}
        )
    }
}
