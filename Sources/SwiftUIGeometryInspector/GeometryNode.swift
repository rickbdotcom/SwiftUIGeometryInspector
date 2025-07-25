//
//  SwiftUIView.swift
//  SwiftUIGeomtryInspector
//
//  Created by rickb on 7/8/25.
//

import SwiftUI

struct GeometryNode: Equatable, Identifiable, Sendable {
    let parentId: String?
    let id: String
    let frame: CGRect
}

struct GeometryNodeSpacing: Identifiable {
    let from: GeometryNode
    let to: GeometryNode
    let fromEdge: Edge
    let toEdge: Edge
    var start: CGPoint {
        from.frame.edgePoint(fromEdge)
    }
    var end: CGPoint {
        to.frame.edgePoint(toEdge, from: self.start)
    }
    var length: CGFloat {
        from.frame.distance(fromEdge: fromEdge, to: to.frame, toEdge: toEdge) * fromEdge.direction
    }
    var id: String {
        "\(from.id):\(fromEdge.rawValue)-\(to.id):\(toEdge.rawValue)"
    }

    init(from: GeometryNode, fromEdge: Edge, to: GeometryNode, toEdge: Edge) {
        self.from = from
        self.to = to
        self.fromEdge = fromEdge
        self.toEdge = toEdge
    }
}

extension Sequence where Element == GeometryNode {

    func spacing(from node: GeometryNode, edge: Edge) -> GeometryNodeSpacing? {
        guard let found = nearest(to: node, edge: edge) else {
            return nil
        }
        return .init(from: node, fromEdge: edge, to: found.node, toEdge: found.edge)
    }

    func spacing(
        from node: GeometryNode,
        filter: (GeometryNode, GeometryNode, Edge) -> Bool = {
            $0.frame.intersects($1.frame, on: $2.axis)
        }
    ) -> [GeometryNodeSpacing] {
        let nodes = self.filter { $0 != node }
        var top = nodes.filter { filter(node, $0, .top) }.spacing(from: node, edge: .top)
        var bottom = nodes.filter { filter(node, $0, .bottom) }.spacing(from: node, edge: .bottom)
        if let t = top, let b = bottom {
            if t.to == b.to && t.toEdge == b.toEdge {
                if abs(t.length) < abs(b.length) {
                    bottom = nil
                } else {
                    top = nil
                }
            }
        }
        var leading = nodes.filter { filter(node, $0, .leading) }.spacing(from: node, edge: .leading)
        var trailing = nodes.filter { filter(node, $0, .trailing) }.spacing(from: node, edge: .trailing)
        if let l = leading, let t = trailing {
            if l.to == t.to && t.toEdge == l.toEdge {
                if abs(l.length) < abs(t.length) {
                    trailing = nil
                } else {
                    leading = nil
                }
            }
        }
        var spacings = [GeometryNodeSpacing]()
        if let top {
            spacings.append(top)
        }
        if let bottom {
            spacings.append(bottom)
        }
        if let leading {
            spacings.append(leading)
        }
        if let trailing {
            spacings.append(trailing)
        }
        return spacings
    }

    func nearest(to node: GeometryNode, edge: Edge) -> (node: GeometryNode, edge: Edge)? {
        let distances = map {
            let d1 = ($0, node.frame.distance(fromEdge: edge, to: $0.frame, toEdge: edge) * edge.direction, edge)
            let d2 = ($0, node.frame.distance(fromEdge: edge, to: $0.frame, toEdge: edge.opposite) * edge.direction, edge.opposite)
            return abs(d1.1) < abs(d2.1) ? d1 : d2
        }
        if let found = distances.filter({ $0.1 >= 0 }).min(by: { $0.1 < $1.1 }) {
            return (found.0, found.2)
        }
        if let found = distances.map({ ($0, abs($1), $2) }).min(by: { $0.1 < $1.1 }) {
            return (found.0, found.2)
        }
        return nil
    }

    func intersecting(node: GeometryNode, on axis: Axis) -> [GeometryNode] {
        filter {
            $0.frame.intersects(node.frame, on: axis) && $0 != node
        }
    }

    func excludeChildren(of node: GeometryNode) -> [GeometryNode] {
        filter {
            $0.parentId != node.id && $0 != node
        }
    }

    func siblings(of node: GeometryNode) -> [GeometryNode] {
        filter {
            ($0.parentId == node.parentId) && $0 != node
        }
    }

    func parent(of node: GeometryNode) -> [GeometryNode] {
        filter {
            $0.id == node.parentId && $0 != node
        }
    }

    func zIndex(of node: GeometryNode?) -> Double {
        guard let node else {
            return 0
        }
        return zIndex(of: parent(of: node).first) + 1.0
    }
}


extension CGRect {

    func intersects(_ rect: CGRect, on axis: Axis) -> Bool {
        switch axis {
        case .horizontal:
            (minY...maxY).contains(rect.minY) || (minY...maxY).contains(rect.maxY) ||
            (rect.minY...rect.maxY).contains(minY) || (rect.minY...rect.maxY).contains(maxY)
        case .vertical:
            (minX...maxX).contains(rect.minX) || (minX...maxX).contains(rect.maxX) ||
            (rect.minX...rect.maxX).contains(minX) || (rect.minX...rect.maxX).contains(maxX)
        }
    }

    func edges(from axis: Axis) -> (CGFloat, CGFloat) {
        switch axis {
        case .horizontal:
            (minX, maxX)
        case .vertical:
            (minY, maxY)
        }
    }

    func edge(_ edge: Edge) -> CGFloat {
        switch edge {
        case .leading:
            minX
        case .trailing:
            maxX
        case .top:
            minY
        case .bottom:
            maxY
        }
    }

    func distance(fromEdge: Edge, to: Self, toEdge: Edge) -> CGFloat {
        to.edge(toEdge) - edge(fromEdge)
    }

    func edgePoint(_ edge: Edge) -> CGPoint {
        switch edge.axis {
        case .horizontal:
            .init(x: self.edge(edge), y: self.midY)
        case.vertical:
            .init(x: self.midX, y: self.edge(edge))
        }
    }

    func edgePoint(_ edge: Edge, from: CGPoint) -> CGPoint {
        switch edge.axis {
        case .horizontal:
            .init(x: self.edge(edge), y: from.y)
        case.vertical:
            .init(x: from.x, y: self.edge(edge))
        }
    }
}

extension Edge {

    var direction: Double {
        switch self {
        case .leading:
            -1
        case .trailing:
            1
        case .top:
            -1
        case .bottom:
            1
        }
    }

    var opposite: Edge {
        switch self {
        case .leading:
            .trailing
        case .trailing:
            .leading
        case .top:
            .bottom
        case .bottom:
            .top
        }
    }

    var axis: Axis {
        switch self {
        case .leading, .trailing:
            .horizontal
        case .top, .bottom:
            .vertical
        }
    }
}
