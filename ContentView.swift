import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene: SKScene {
        // Set the sceneSize to iPad Pro (12.9-inch) proportions
        let sceneSize = CGSize(width: 1024, height: 1366)
        let scene = IntroScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        // Anchor point on the middle of the screen
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
