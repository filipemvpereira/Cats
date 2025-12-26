//
//  BreedsListAssembly.swift
//  FeatureBreedsList
//

import Swinject
import SwiftUI

public final class BreedsListAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(BreedsListViewModel.self) { _ in
            MainActor.assumeIsolated {
                return BreedsListViewModel()
            }
        }

        container.register(BreedsListView.self) { (resolver) in
            return BreedsListView(
                viewModel: resolver.resolve(BreedsListViewModel.self)!
            )
        }
    }
}
