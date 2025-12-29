//
//  FavouritesAssembly.swift
//  FeatureFavourites
//

import CoreBreeds
import CoreResources
import CoreUI
import Swinject
import SwiftUI

public final class FavouritesAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(GetFavouritesUseCase.self) { resolver in
            GetFavouritesUseCaseImpl(
                repository: resolver.resolve(BreedRepository.self)!
            )
        }

        container.register(UnfavouriteUseCase.self) { resolver in
            UnfavouriteUseCaseImpl(
                repository: resolver.resolve(BreedRepository.self)!
            )
        }

        container.register(FavouritesViewModel.self) { resolver in
            FavouritesViewModel(
                getFavouritesUseCase: resolver.resolve(GetFavouritesUseCase.self)!,
                unfavouriteUseCase: resolver.resolve(UnfavouriteUseCase.self)!,
                localizer: resolver.resolve(LocalizedResourcesRepository.self)!
            )
        }

        container.register(FavouritesView.self) { (resolver, navigator: any Navigator) in
            return FavouritesView(
                viewModel: resolver.resolve(FavouritesViewModel.self)!,
                navigator: navigator
            )
        }
    }
}
