//
//  BreedDetailAssembly.swift
//  FeatureBreedDetail
//

import CoreBreeds
import CoreResources
import Foundation
import Swinject

public final class BreedDetailAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(GetBreedDetailUseCase.self) { resolver in
            GetBreedDetailUseCaseImpl(
                repository: resolver.resolve(BreedRepository.self)!
            )
        }

        container.register(ToggleFavouriteUseCase.self) { resolver in
            ToggleFavouriteUseCaseImpl(
                repository: resolver.resolve(BreedRepository.self)!
            )
        }

        container.register(BreedDetailViewModel.self) { (resolver, breedId: String) in
            return BreedDetailViewModel(
                breedId: breedId,
                getBreedDetailUseCase: resolver.resolve(GetBreedDetailUseCase.self)!,
                toggleFavouriteUseCase: resolver.resolve(ToggleFavouriteUseCase.self)!,
                localizer: resolver.resolve(LocalizedResourcesRepository.self)!
            )
        }

        container.register(BreedDetailView.self) { (resolver, breedId: String) in
            return BreedDetailView(
                viewModel: resolver.resolve(BreedDetailViewModel.self, argument: breedId)!
            )
        }
    }
}
