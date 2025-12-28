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
        case .loaded(let detail):
            loadedContent(detail: detail)
        case .error(let message, let retryText):
            ErrorView(
                message: message,
                retryText: retryText,
                onRetry: onRetry
            )
        }
    }

    private func loadedContent(detail: BreedDetailViewState.Detail) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                ImageView(
                    imageUrl: detail.imageUrl,
                    maxWidth: 300,
                    cornerRadius: 16
                )
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 20) {
                    infoSection(title: detail.sectionOriginTitle, content: detail.origin)
                    infoSection(title: detail.sectionTemperamentTitle, content: detail.temperament)
                    infoSection(title: detail.sectionDescriptionTitle, content: detail.description)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .navigationTitle(detail.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onToggleFavourite()
                } label: {
                    Image(systemName: detail.isFavourite ? "star.fill" : "star")
                        .foregroundStyle(detail.isFavourite ? .yellow : .gray)
                }
            }
        }
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

struct ImageView: View {
    let imageUrl: String?
    let maxWidth: CGFloat
    let cornerRadius: CGFloat

    var body: some View {
        AsyncImage(url: imageUrl.flatMap { URL(string: $0) }) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: maxWidth)
                    .overlay {
                        ProgressView()
                    }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: maxWidth, height: maxWidth)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            case .failure:
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: maxWidth)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                    }
            @unknown default:
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: maxWidth)
            }
        }
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
                    BreedDetailViewState.Detail(
                        id: "1",
                        name: "Abyssinian",
                        origin: "Egypt",
                        temperament: "Active, Energetic, Independent, Intelligent, Gentle",
                        description: "The Abyssinian is easy to care for, and a joy to have in your home. They're affectionate cats and love both people and other animals.",
                        imageUrl: nil,
                        isFavourite: false,
                        sectionOriginTitle: "Origin",
                        sectionTemperamentTitle: "Temperament",
                        sectionDescriptionTitle: "Description"
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
                    BreedDetailViewState.Detail(
                        id: "2",
                        name: "Persian",
                        origin: "Iran (Persia)",
                        temperament: "Affectionate, loyal, Sedate, Quiet",
                        description: "The Persian is a long-haired breed of cat characterized by its round face and short muzzle. It is also known as the Persian Longhair.",
                        imageUrl: nil,
                        isFavourite: true,
                        sectionOriginTitle: "Origin",
                        sectionTemperamentTitle: "Temperament",
                        sectionDescriptionTitle: "Description"
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
