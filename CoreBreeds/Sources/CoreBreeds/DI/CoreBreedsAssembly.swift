//
//  CoreBreedsAssembly.swift
//  CoreBreeds
//

import CoreLocalStorage
import Foundation
import Network
import Swinject

public final class CoreBreedsAssembly: Assembly {

    private let configuration: CoreBreedsConfiguration

    public init(configuration: CoreBreedsConfiguration) {
        self.configuration = configuration
    }

    public func assemble(container: Container) {
        container.register(CoreBreedsConfiguration.self) { _ in
            self.configuration
        }

        container.register(JSONDecoder.self) { _ in
            return JSONDecoder()
        }

        container.register(BreedRepository.self) { resolver in
            return BreedRepositoryImpl(
                networkService: resolver.resolve(NetworkService.self)!,
                configuration: resolver.resolve(CoreBreedsConfiguration.self)!,
                decoder: resolver.resolve(JSONDecoder.self)!,
                localStorage: resolver.resolve(LocalStorageRepository.self)!
            )
        }.inObjectScope(.container)
    }
}
