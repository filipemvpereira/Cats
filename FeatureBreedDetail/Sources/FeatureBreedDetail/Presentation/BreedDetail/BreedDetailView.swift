//
//  BreedDetailView.swift
//  FeatureBreedDetail
//

import CoreUI
import SwiftUI

public struct BreedDetailView: View {

    @StateObject var viewModel: BreedDetailViewModel

    public var body: some View {
        BreedDetailScreen(
            state: viewModel.state,
            onToggleFavourite: { viewModel.toggleFavourite() },
            onRetry: { Task { await viewModel.retry() } }
        )
        .task { await viewModel.initialize() }
    }
}

struct BreedDetailScreen: View {
    let state: BreedDetailViewState
    let onToggleFavourite: () -> Void
    let onRetry: () -> Void

    var body: some View {
        switch state.content {
        case .loading(let message):
            LoadingView(message: message)
        case .loaded(let breed):
            loadedContent(breed: breed)
        case .error(let message, let retryText):
            ErrorView(
                message: message,
                retryText: retryText,
                onRetry: onRetry
            )
        }
    }

    private func loadedContent(breed: BreedDetailViewState.Breed) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                breedImage(url: breed.imageUrl)

                VStack(alignment: .leading, spacing: 20) {
                    infoSection(title: "Origin", content: breed.origin)
                    infoSection(title: "Temperament", content: breed.temperament)
                    infoSection(title: "Description", content: breed.description)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle(breed.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onToggleFavourite()
                } label: {
                    Image(systemName: breed.isFavourite ? "star.fill" : "star")
                        .foregroundStyle(breed.isFavourite ? .yellow : .gray)
                }
            }
        }
    }

    private func breedImage(url: String?) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.2))
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: 300)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
    }

    private func infoSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(content)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Loading") {
    NavigationStack {
        BreedDetailScreen(
            state: BreedDetailViewState(content: .loading("Loading")),
            onToggleFavourite: {},
            onRetry: {}
        )
    }
}

#Preview("Loaded") {
    NavigationStack {
        BreedDetailScreen(
            state: BreedDetailViewState(
                content: .loaded(
                    BreedDetailViewState.Breed(
                        id: "1",
                        name: "Abyssinian",
                        origin: "Egypt",
                        temperament: "Active, Energetic, Independent, Intelligent, Gentle",
                        description: "The Abyssinian is easy to care for, and a joy to have in your home. They're affectionate cats and love both people and other animals.",
                        imageUrl: nil,
                        isFavourite: false
                    )
                )
            ),
            onToggleFavourite: {},
            onRetry: {}
        )
    }
}

#Preview("Loaded - Favourite") {
    NavigationStack {
        BreedDetailScreen(
            state: BreedDetailViewState(
                content: .loaded(
                    BreedDetailViewState.Breed(
                        id: "2",
                        name: "Persian",
                        origin: "Iran (Persia)",
                        temperament: "Affectionate, loyal, Sedate, Quiet",
                        description: "The Persian is a long-haired breed of cat characterized by its round face and short muzzle. It is also known as the Persian Longhair.",
                        imageUrl: nil,
                        isFavourite: true
                    )
                )
            ),
            onToggleFavourite: {},
            onRetry: {}
        )
    }
}

#Preview("Error") {
    NavigationStack {
        BreedDetailScreen(
            state: BreedDetailViewState(
                content: .error(
                    "Failed to load breed details. Please check your connection and try again.",
                    retryText: "Retry"
                )
            ),
            onToggleFavourite: {},
            onRetry: {}
        )
    }
}
