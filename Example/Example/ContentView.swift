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
                    .padding()
            }

            HStack {
                VStack(spacing: 16) {
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                        .recordGeometry("globe")

                    Text("Hello, world!")
                        .recordGeometry("hello")

                    Text("Untracked")
                }
            }
            .padding()
            .inspectGeometry(inspectGeometry)
        }
    }
}

#Preview {
    ContentView()
}

