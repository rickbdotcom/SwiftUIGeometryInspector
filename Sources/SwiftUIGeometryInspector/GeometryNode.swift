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

struct GeometryNodeSpacing: Identifiable {
    let node: GeometryNode
    let connectedNode: GeometryNode
    let start: CGPoint
    let end: CGPoint
    let length: CGFloat
    var id: String {
        "\(node.id)-\(connectedNode.id):\(start)\(end)"
    }

    init?(
        node: GeometryNode,
        x: CGFloat? = nil,
        y: CGFloat? = nil,
        _ line: (GeometryNode, (CGFloat, CGFloat))?
    ) {
        guard let line else {
            return nil
        }
        self.node = node
        self.connectedNode = line.0
        self.start = .init(x: x ?? line.1.0, y: y ?? line.1.0)
        self.end = .init(x: x ?? line.1.1, y: y ?? line.1.1)
        self.length = line.1.0 - line.1.1
    }
}

extension Sequence where Element == GeometryNode {

    func siblings(of node: GeometryNode) -> [GeometryNode] {
        filter {
            $0.id != node.id && ($0.parentId == node.parentId)
        }
    }

    func parent(of node: GeometryNode) -> [GeometryNode] {
        filter {
            $0.id == node.parentId
        }
    }

    func zIndex(of node: GeometryNode?) -> Double {
        guard let node else {
            return 0
        }
        return zIndex(of: parent(of: node).first) + 1.0
    }

    func find(_ line: (GeometryNode) -> (CGFloat, CGFloat)) -> (GeometryNode, (CGFloat, CGFloat))? {
        map {
            ($0, line($0))
        }.filter {
            $0.1.0 - $0.1.1 > 0
        }.min {
            ($0.1.0 - $0.1.1) < ($1.1.0 - $1.1.1)
        }
    }

    func top(from node: GeometryNode) -> GeometryNodeSpacing? {
        .init(
            node: node,
            x: node.frame.midX,
            siblings(of: node).find {
                (node.frame.minY, $0.frame.maxY)
            } ?? parent(of: node).find {
                (node.frame.minY, $0.frame.minY)
            }
        )
    }

    func bottom(from node: GeometryNode) -> GeometryNodeSpacing? {
        .init(
            node: node,
            x: node.frame.midX,
            siblings(of: node).find {
                ($0.frame.minY, node.frame.maxY)
            } ?? parent(of: node).find {
                ($0.frame.maxY, node.frame.maxY)
            }
        )
    }

    func leading(from node: GeometryNode) -> GeometryNodeSpacing? {
        .init(
            node: node,
            y: node.frame.midY,
            siblings(of: node).find {
                (node.frame.minX, $0.frame.maxX)
            } ?? parent(of: node).find {
                (node.frame.minX, $0.frame.minX)
            }
        )
    }

    func trailing(from node: GeometryNode) -> GeometryNodeSpacing? {
        .init(
            node: node,
            y: node.frame.midY,
            siblings(of: node).find {
                ($0.frame.minX, node.frame.maxX)
            } ?? parent(of: node).find {
                ($0.frame.maxX , node.frame.maxX)
            }
        )
    }
}

public struct GeometryNodePreferenceKey: PreferenceKey {
    public static let defaultValue: [GeometryNode] = []

    public static func reduce(value: inout [GeometryNode], nextValue: () -> [GeometryNode]) {
        value += nextValue()
    }
}
