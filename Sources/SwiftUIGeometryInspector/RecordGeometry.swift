//
//  SwiftUIView.swift
//  SwiftUIGeomtryInspector
//
//  Created by rickb on 7/8/25.
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var geometryIdentifier: String? = nil
}

public extension View {

    func recordGeometry() -> some View {
        modifier(RecordGeometryViewModifer())
    }
}

struct RecordGeometryViewModifer: ViewModifier {
    @Environment(\.inspectGeometry) private var inspectGeometry
    @Environment(\.geometryIdentifier) private var geometryIdentifier
    let id = UUID().uuidString

    func body(content: Content) -> some View {
        if inspectGeometry {
            content.overlay {
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: GeometryNodePreferenceKey.self,
                            value: [.init(
                                parentId: geometryIdentifier,
                                id: id,
                                frame: geometry.frame(in: .named("GeometryInspector"))
                            )]
                        )
                }
            }
            .environment(\.geometryIdentifier, id)
        } else {
            content
        }
    }
}
