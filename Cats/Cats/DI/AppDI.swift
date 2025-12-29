//
//  AppDI.swift
//  Cats
//

import CoreBreeds
import CoreLocalStorage
import CoreResources
import CoreUI
import FeatureBreedDetail
import FeatureBreedsList
import FeatureFavourites
import Network
import Swinject
import SwiftUI

class AppDI {

    private static let shared = AppDI()

    private var assembler: Assembler!

    private init() {}

    static func setup() {
        shared.assembler = Assembler([
            NetworkAssembly(),
            CoreLocalStorageAssembly(),
            CoreResourcesAssembly(),
            CoreBreedsAssembly(
                configuration: CoreBreedsConfiguration(
                    baseURL: "https://api.thecatapi.com/v1"
                )
            ),
            BreedsListAssembly(),
            BreedDetailAssembly(),
            FavouritesAssembly()
        ])
    }

    @MainActor
    static func breedsListView(navigator: any Navigator) -> BreedsListView {
        shared.assembler.resolver.resolve(BreedsListView.self, argument: navigator)!
    }

    @MainActor
    static func favouritesView(navigator: any Navigator) -> FavouritesView {
        shared.assembler.resolver.resolve(FavouritesView.self, argument: navigator)!
    }

    @MainActor
    static func breedDetailView(id: String) -> BreedDetailView {
        shared.assembler.resolver.resolve(BreedDetailView.self, argument: id)!
    }

    static func localizer() -> LocalizedResourcesRepository {
        shared.assembler.resolver.resolve(LocalizedResourcesRepository.self)!
    }
}
