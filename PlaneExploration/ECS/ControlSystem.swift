// Created by Chester for PlaneExploration in 2025

import RealityKit
import SwiftUI

@Observable
class ControlParameters {
    var pitch: Float = 0 // radians
    var roll: Float = 0 // radians
    
    func reset() {
        pitch = 0
        roll = 0
    }
}

struct ControlComponent: Component {
    let parameters: ControlParameters
}

struct FlightStateComponent: Component {
    var yaw = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    var pitchRoll = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
    
    init() {
        FlightStateComponent.registerComponent()
    }
}

class ControlSystem: System {
    static let query = EntityQuery(where: .has(ControlComponent.self))
    required init(scene: RealityKit.Scene) {}
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let controlComponent = entity.components[ControlComponent.self] else {
                return
            }
            
            if entity.components[FlightStateComponent.self] == nil {
                entity.components.set(FlightStateComponent())
            }
            
            var flightState = entity.components[FlightStateComponent.self]!
            
            let parameters = controlComponent.parameters
            let pitch = parameters.pitch
            let roll = parameters.roll
            
            print("Pitch=\(pitch), roll=\(roll)")
            
            let deltaTime = Float(context.deltaTime)
            let turnSpeed: Float = 1
            let maxPitchRoll: Float = 0.7
            
            let yawDelta = simd_quatf(angle: roll * deltaTime * turnSpeed, axis: .upward)
            flightState.yaw = (flightState.yaw * yawDelta).normalized
            
            let newRoll = simd_quatf(angle: -roll * maxPitchRoll, axis: .back)
            let newPitch = simd_quatf(angle: pitch * maxPitchRoll, axis: .left)
            flightState.pitchRoll = simd_slerp(flightState.pitchRoll, newRoll * newPitch, deltaTime * 2).normalized
            
            entity.transform.rotation = (flightState.yaw * flightState.pitchRoll).normalized
            entity.components[FlightStateComponent.self] = flightState
            
            guard let physicsEntity = entity as? HasPhysics else {
                print("Entity has no physics property")
                return
            }
            
            // 主要推力
            let strength: Float = 0.4
            let primaryThrust = entity.transform.matrix.forward * strength * deltaTime
            physicsEntity.addForce(primaryThrust, relativeTo: nil)
            print("Force=\(primaryThrust)")
            
            guard let motion = physicsEntity.physicsMotion else { return }

            // Vertical component
            let shipUp = entity.transform.matrix.upward
            let vertVelocity = dot(motion.linearVelocity, shipUp)

            // Horizontal component
            let shipRight = entity.transform.matrix.right
            let rightVelocity = dot(motion.linearVelocity, shipRight)

            let verticalAssistStrength: Float = 0.4
            let assistiveThrust = -vertVelocity * shipUp * deltaTime * verticalAssistStrength +
                                  -rightVelocity * shipRight * deltaTime * verticalAssistStrength
            physicsEntity.addForce(assistiveThrust, relativeTo: nil)
        }
    }
}
