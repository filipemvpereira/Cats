//
//  CoreResourcesAssembly.swift
//  CoreResources
//

import Foundation
import Swinject

public final class CoreResourcesAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(LocalizedResourcesRepository.self) { _ in
            LocalizedResourcesRepositoryImpl()
        }.inObjectScope(.container)
    }
}
