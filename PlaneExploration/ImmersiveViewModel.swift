// Created by Chester for PlaneExploration in 2025

import ARKit
import Foundation
import RealityKit

@MainActor
class ImmersiveViewModel {
    let rootEntity = Entity()
    var plane: ModelEntity?
    var clouds: Entity = .init()

    init() {
        setupRoot()
    }

    func setupRoot() {
        rootEntity.name = "Root"
        rootEntity.addChild(clouds)
    }

    func spawnPlane() async throws -> ModelEntity {
        let plane = try await createPlane()
        plane.position = [-2, 1.5, -1.5]
        plane.fadeOpacity(from: 0, to: 1, duration: 1)
        return plane
    }

    func spawnCloud() async throws {
        let cloud = try await createCloud()
        cloud.position = [
            .random(in: -4...4),
            .random(in: 0.5...2),
            .random(in: -4...(-1))
        ]
        cloud.orientation = simd_quatf(
            angle: .random(in: 0...(2 * .pi)),
            axis: [0, 1, 0]
        )
        clouds.addChild(cloud)
    }

    func spawnMultipleCloud(count: Int = 10) async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0 ..< count {
                group.addTask {
                    try await self.spawnCloud()
                }
            }
        }
    }

    private func createPlane() async throws -> ModelEntity {
        let plane = try await Entity.makePlane()
        plane.scale *= 10
        
        // Configure the components
        plane.components.set(PhysicsMotionComponent())
        plane.components.set(ControlComponent(parameters: .init()))

        rootEntity.addChild(plane)
        plane.playAnimationWithInifiniteLoop()
        self.plane = plane
        return plane
    }

    private func createCloud() async throws -> ModelEntity {
        let cloud = try await Entity.makeCloud()
        cloud.scale *= 0.1
        return cloud
    }
}
