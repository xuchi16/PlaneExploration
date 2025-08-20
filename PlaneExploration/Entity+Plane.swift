// Created by Chester for PlaneExploration in 2025

import RealityKit
import RealityKitContent

extension Entity {
    static func makePlane() async throws -> ModelEntity {
        let plane = ModelEntity()
        plane.name = "Plane"
        
        let planeModel = try await Entity(named: "Fighter_ship", in: realityKitContentBundle)
        planeModel.name = "PlaneModel"
        plane.addChild(planeModel)
        
        var physicsBody = PhysicsBodyComponent(mode: .dynamic)
        physicsBody.isAffectedByGravity = false
        physicsBody.linearDamping = 0.2
        physicsBody.massProperties.mass = 4
        plane.components.set(physicsBody)
        
        let bodyCollisionShape = ShapeResource.generateCapsule(height: 0.1, radius: 0.015)
            .offsetBy(rotation: .init(angle: .pi / 2, axis: [1, 0, 0]))
        
        let wingsCollisionShape = ShapeResource
            .generateCapsule(height: 0.11, radius: 0.015)
            .offsetBy(rotation: .init(angle: .pi / 2, axis: [1, 0, 0]))
            .offsetBy(rotation: .init(angle: .pi / 2, axis: [0, 1, 0]))
            .offsetBy(translation: [0, 0, 0.02])
        
        plane.components.set(CollisionComponent(
            shapes: [bodyCollisionShape, wingsCollisionShape]
        ))
        
        return plane
    }
    
    static func makeCloud() async throws -> ModelEntity {
        let cloud = ModelEntity()
        cloud.name = "Cloud"
        
        let cloudModel = try await Entity(named: "cloud", in: realityKitContentBundle)
        cloudModel.name = "CloudModel"
        cloud.addChild(cloudModel)
        
        return cloud
    }
    
    func fadeOpacity(from start: Float? = nil, to end: Float, duration: Double) {
        let start = start ?? components[OpacityComponent.self]?.opacity ?? 0
        let fadeInAnimationDefinition = FromToByAnimation(
            from: Float(start),
            to: Float(end),
            duration: duration,
            timing: .easeInOut,
            bindTarget: .opacity
        )
        let fadeInAnimation = try! AnimationResource.generate(with: fadeInAnimationDefinition)
        components.set(OpacityComponent(opacity: start))
        playAnimation(fadeInAnimation)
    }
    
    func playAnimationWithInifiniteLoop() {
        for animation in self.availableAnimations {
            let repeatition = animation.repeat(count: .max)
            let controller = self.playAnimation(repeatition)
            return
        }
    }
}
