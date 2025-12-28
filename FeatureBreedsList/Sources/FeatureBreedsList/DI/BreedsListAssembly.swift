//
//  BreedsListAssembly.swift
//  FeatureBreedsList
//

import CoreBreeds
import CoreResources
import CoreUI
import Swinject
import SwiftUI

public final class BreedsListAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(GetBreedsUseCase.self) { resolver in
            GetBreedsUseCaseImpl(
                repository: resolver.resolve(BreedRepository.self)!
            )
        }

        container.register(ToggleFavouriteUseCase.self) { resolver in
            ToggleFavouriteUseCaseImpl(
                repository: resolver.resolve(BreedRepository.self)!
            )
        }

        container.register(BreedsListViewModel.self) { resolver in
            BreedsListViewModel(
                getBreedsUseCase: resolver.resolve(GetBreedsUseCase.self)!,
                toggleFavouriteUseCase: resolver.resolve(ToggleFavouriteUseCase.self)!,
                localizer: resolver.resolve(LocalizedResourcesRepository.self)!
            )
        }

        container.register(BreedsListView.self) { (resolver, navigator: any Navigator) in
            return BreedsListView(
                viewModel: resolver.resolve(BreedsListViewModel.self)!,
                navigator: navigator
            )
        }
    }
}
