//
//  LocalStorageError.swift
//  CoreLocalStorage
//

import Foundation

public enum LocalStorageError: LocalizedError, Sendable {
    case initializationFailed(String)
    case saveFailed(String)
    case fetchFailed(String)
    case deleteFailed(String)
    case breedNotFound(String)
    case contextNotAvailable

    public var errorDescription: String? {
        switch self {
        case .initializationFailed(let message):
            return "Storage initialization failed: \(message)"
        case .saveFailed(let message):
            return "Failed to save data: \(message)"
        case .fetchFailed(let message):
            return "Failed to fetch data: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete data: \(message)"
        case .breedNotFound(let id):
            return "Breed not found: \(id)"
        case .contextNotAvailable:
            return "Model context not available"
        }
    }
}
