//
//  ErrorView.swift
//  CoreUI
//

import SwiftUI

public struct ErrorView: View {

    public let message: String
    public let retryText: String
    public let onRetry: () -> Void

    public init(message: String, retryText: String, onRetry: @escaping () -> Void) {
        self.message = message
        self.retryText = retryText
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)

            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: onRetry) {
                Text(retryText)
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(8)
            }
        }
    }
}
