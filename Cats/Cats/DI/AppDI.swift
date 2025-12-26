//
//  AppDI.swift
//  Cats
//

import CoreUI
import FeatureBreedDetail
import FeatureBreedsList
import Swinject
import SwiftUI

class AppDI {

    private static let shared = AppDI()

    private var assembler: Assembler!

    private init() {}

    static func setup() {
        shared.assembler = Assembler([
            BreedsListAssembly(),
            BreedDetailAssembly()
        ])
    }

    @MainActor
    static func breedsListView(navigator: any Navigator) -> BreedsListView {
        shared.assembler.resolver.resolve(BreedsListView.self)!
    }

    @MainActor
    static func favouritesView(navigator: any Navigator) -> some View {
        Text("Favourites Feature")
            .navigationTitle("Favourites")
    }

    @MainActor
    static func breedDetailView(id: String, navigator: any Navigator) -> BreedDetailView {
        shared.assembler.resolver.resolve(BreedDetailView.self, argument: id)!
    }
}
