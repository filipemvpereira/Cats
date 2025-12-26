//
//  LoadingView.swift
//  CoreUI
//

import SwiftUI

public struct LoadingView: View {

    public let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}
