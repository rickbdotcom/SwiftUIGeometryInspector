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
    @State private var selectedNode: GeometryNode? {
        didSet {
            var spacings = [GeometryNodeSpacing]()
            if let selectedNode {
                if let top = nodes.top(from: selectedNode) {
                    spacings.append(top)
                }
                if let bottom = nodes.bottom(from: selectedNode) {
                    spacings.append(bottom)
                }
                if let leading = nodes.leading(from: selectedNode) {
                    spacings.append(leading)
                }
                if let trailing = nodes.trailing(from: selectedNode) {
                    spacings.append(trailing)
                }
                self.spacings = spacings
            } else {
                self.spacings = []
            }
        }
    }
    @State private var spacings: [GeometryNodeSpacing] = []
    var connectedNodes: [GeometryNode] {
        spacings.map { $0.connectedNode }
    }
    let enable: Bool
    
    func body(content: Content) -> some View {
        if enable {
            content
                .allowsHitTesting(false)
                .overlay {
                    ZStack {
                        ForEach(nodes) { node in
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .border(
                                    node == selectedNode ? Color.red : Color.blue,
                                    width: node == selectedNode || connectedNodes.contains(node) ? 2 : 1
                                )
                                .frame(width: node.frame.size.width, height: node.frame.size.height)
                                .offset(x: node.frame.minX, y: node.frame.minY)
                                .zIndex(nodes.zIndex(of: node) + (node == selectedNode ? 0.5 : 0))
                                .onTapGesture {
                                    selectedNode = (node == selectedNode) ? nil : node
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }

                        if let node = selectedNode {
                            Text("\(Int(node.frame.size.width))x\(Int(node.frame.size.height))")
                                .font(.caption2)
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 2)
                                .background(Color.red)
                                .offset(x: node.frame.minX, y: node.frame.minY)
                                .allowsHitTesting(false)
                                .zIndex(1000)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }

                        ForEach(spacings) { spacing in
                            GeometryNodeSpacingView(spacing: spacing)
                        }
                    }
                }
                .onPreferenceChange(GeometryNodePreferenceKey.self) { nodes in
                    self.nodes = nodes.reversed()
                }
                .coordinateSpace(name: "GeometryInspector")
                .environment(\.inspectGeometry, enable)
        } else {
            content
        }
    }
}

struct GeometryNodeSpacingView: View {
    let spacing: GeometryNodeSpacing

    var body: some View {
        ZStack {
            Path {
                $0.move(to: spacing.start)
                $0.addLine(to: spacing.end)
            }
            .stroke(.red, lineWidth: 1)

            Text("\(Int(spacing.length))")
                .font(.caption2)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 2)
                .background(Color.red)
                .position(x: (spacing.start.x + spacing.end.x) / 2, y: (spacing.start.y + spacing.end.y) / 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
        .zIndex(1000)
    }
}
