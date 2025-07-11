//
//  SwiftUIView.swift
//  SwiftUIGeomtryInspector
//
//  Created by rickb on 7/8/25.
//

import SwiftUI

public struct GeometryNode: Equatable, Identifiable, Sendable {
    public let parentId: String?
    public let id: String
    public let frame: CGRect
}

public struct GeometryNodePreferenceKey: PreferenceKey {
    public static let defaultValue: [GeometryNode] = []

    public static func reduce(value: inout [GeometryNode], nextValue: () -> [GeometryNode]) {
        value += nextValue()
    }
}
