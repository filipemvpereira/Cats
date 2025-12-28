//
//  LocalizedResourcesRepository.swift
//  CoreResources
//

import Foundation

public protocol LocalizedResourcesRepository {
    func getString(_ key: LocalizedKey) -> String
}

final class LocalizedResourcesRepositoryImpl: LocalizedResourcesRepository {

    func getString(_ key: LocalizedKey) -> String {
        NSLocalizedString(key.stringKey, bundle: .module, comment: "")
    }
}
