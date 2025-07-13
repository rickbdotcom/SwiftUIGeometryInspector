//
//  ContentView.swift
//  GeomTest
//
//  Created by rickb on 7/9/25.
//

import SwiftUI
import SwiftUIGeometryInspector

struct ContentView: View {
    @State private var inspectGeometry = false

    var body: some View {
        VStack {
            Toggle(isOn: $inspectGeometry) {
                Text("Inspect Geometry")
            }
            .padding()
            VStack {
                HStack {
                    VStack(spacing: 16) {
                        Image(systemName: "globe")
                            .imageScale(.large)
                            .foregroundStyle(.tint)
                            .recordGeometry()
                            .padding()

                        Text("Hello, world!")
                            .fixedSize()
                            .multilineTextAlignment(.leading)
                            .recordGeometry()
                            .padding(.horizontal)

                        Text("Hello, galaxy!")
                            .fixedSize()
                            .multilineTextAlignment(.leading)
                            .recordGeometry()

                        Text("Untracked")
                    }
                    .recordGeometry()

                    Text("Horizontal 1")
                        .padding()
                        .recordGeometry()

                    Text("Horizontal 2")
                        .padding()
                        .recordGeometry()
                }
                .recordGeometry()
                .padding()
                .recordGeometry()

                HStack(spacing: -10) {
                    Text("Overlap 1")
                        .padding()
                        .recordGeometry()

                    Text("Overlap 2")
                        .padding()
                        .recordGeometry()
                }
            }
            .inspectGeometry(inspectGeometry)
        }
    }
}

#Preview {
    ContentView()
}

