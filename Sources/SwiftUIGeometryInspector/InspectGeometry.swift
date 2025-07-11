//
//  SwiftUIView.swift
//  SwiftUIGeomtryInspector
//
//  Created by rickb on 7/9/25.
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var inspectGeometry: Bool = false
}

public extension View {

    func inspectGeometry(_ enable: Bool) -> some View {
        modifier(InspectGeometryViewModifer(enable: enable))
    }
}

struct InspectGeometryViewModifer: ViewModifier {
    @State private var nodes: [GeometryNode] = []
    @State private var selectedNode: GeometryNode?
    let enable: Bool
    
    func body(content: Content) -> some View {
        if enable {
            content
                .overlay {
                    ZStack {
                        ForEach(nodes) { node in
                            Rectangle()
                                .fill(Color.clear)
                                .border(node == selectedNode ? Color.red : Color.blue, width: 1)
                                .offset(x: node.frame.origin.x, y: node.frame.origin.y)
                                .frame(width: node.frame.size.width, height: node.frame.size.height)
                                .onTapGesture {
                                    selectedNode = node
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }

                        if let selectedNode {
                            
                        }
                    }
                    .contentShape(Rectangle())
                }
                .onPreferenceChange(GeometryNodePreferenceKey.self) { nodes in
                    self.nodes = nodes
                }
                .coordinateSpace(name: "GeometryInspector")
                .environment(\.inspectGeometry, enable)
        } else {
            content
        }
    }
}
