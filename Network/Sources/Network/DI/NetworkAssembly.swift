//
//  NetworkAssembly.swift
//  Network
//

import Foundation
import Swinject

public class NetworkAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {
        container.register(NetworkService.self) { _ in
            NetworkServiceImpl(
                session: .shared
            )
        }.inObjectScope(.container)
    }
}
