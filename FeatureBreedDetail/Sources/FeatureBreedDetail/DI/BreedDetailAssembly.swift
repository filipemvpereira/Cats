//
//  BreedDetailAssembly.swift
//  FeatureBreedDetail
//

import Foundation
import Swinject

public final class BreedDetailAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(BreedDetailViewModel.self) { (_, breedId: String) in
            MainActor.assumeIsolated {
                return BreedDetailViewModel(breedId: breedId)
            }
        }

        container.register(BreedDetailView.self) { (resolver, breedId: String) in
            return BreedDetailView(
                viewModel: resolver.resolve(BreedDetailViewModel.self, argument: breedId)!
            )
        }
    }
}
