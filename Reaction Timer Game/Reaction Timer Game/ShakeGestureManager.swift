//
//  ShakeGestureManager.swift
//  Reaction Timer Game
//
//  Created by Yordan Markov on 20.02.25.
//

import UIKit

// Shake Gesture Detection
extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}

extension Notification.Name {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}
