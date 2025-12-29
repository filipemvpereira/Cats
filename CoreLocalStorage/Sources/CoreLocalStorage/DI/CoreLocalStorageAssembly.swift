//
//  CoreLocalStorageAssembly.swift
//  CoreLocalStorage
//

import Foundation
import SwiftData
import Swinject

public final class CoreLocalStorageAssembly: Assembly {

    public init() {}
    
    public func assemble(container: Container) {
        container.register(ModelContainer.self) { resolver in
            let schema = Schema([
                BreedEntity.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )

            return try! ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        }

        container.register(LocalStorageRepository.self) { resolver in
            return LocalStorageRepositoryImpl(
                modelContainer: resolver.resolve(ModelContainer.self)!
            )
        }.inObjectScope(.container)
    }
}
