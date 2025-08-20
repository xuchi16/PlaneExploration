// Created by Chester for PlaneExploration in 2025

import RealityKit
import RealityKitContent
import SwiftUI

struct ImmersiveView: View {
    @State private var viewModel = ImmersiveViewModel()

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
            }

            content.add(viewModel.rootEntity)
            
            // Hand tracking
            HandControlProviderSystem.registerSystem()
            viewModel.rootEntity.addChild(Entity.makeHandTrackingEntities())
            
            // Control system
            ControlSystem.registerSystem()
        }
        .task {
            do {
                _ = try await viewModel.spawnPlane()
            } catch {
                print("Failed to spawn the plane")
            }
        }
        .task {
            do {
                _ = try await viewModel.spawnMultipleCloud()
            } catch {
                print("Failed to spawn the plane")
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
