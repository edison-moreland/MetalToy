//
//  LazyView.swift
//  metaltoy
//
//  Created by Edison Moreland on 1/15/23.
//

import SwiftUI

public struct LazyView<Content: View>: View {
    private let build: () -> Content
    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    public var body: Content {
        build()
    }
}
