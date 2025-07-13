//
//  SwiftUIView.swift
//  SwiftUIGeometryInspector
//
//  Created by rickb on 7/13/25.
//

import SwiftUI

public extension View {
    func inspectGeometryToggle(alignment: Alignment = .topTrailing) -> some View {
        modifier(InspectGeometryToggleViewModifier(alignment: alignment))
    }
}

struct InspectGeometryToggleViewModifier: ViewModifier {
    @State private var inspectGeometry = false
    let alignment: Alignment
    func body(content: Content) -> some View {
        content
            .inspectGeometry(inspectGeometry)
            .overlay(alignment: alignment) {
                Button {
                    inspectGeometry.toggle()
                } label: {
                    Image(systemName: inspectGeometry ? "dot.scope" : "scope")
                }
            }
    }
}
