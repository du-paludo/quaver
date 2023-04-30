//
//  MelodyScene.swift
//  Quaver
//
//  Created by Eduardo Stefanel Paludo on 07/04/23.
//

import SpriteKit

class MelodyScene: SKScene {
    // Sounds
    let soundManager = SoundManager()
    var melodyIndex = 0
    
    var skipButton: SKLabelNode!

    // Text
    var text: SKLabelNode!
    
    // Assets
    var quaver: SKSpriteNode!
    var neutralQuaver: SKTexture!
    var circle: SKShapeNode!
    
    // Dialogues
    var dialogue = SKSpriteNode()
    var dialogues = [SKTexture]()
    var dialogueIndex = 0
    var isDialogue = false
    
    // Animations
    var quaverMovement: SKAction!
    var dialogueZoom: SKAction!
    var moveUpLeft: SKAction!
    var moveUpRight: SKAction!
    var moveDownLeft: SKAction!
    var moveDownRight: SKAction!
    var moveToCenter: SKAction!
    var fadeIn: SKAction!
    var fadeOut: SKAction!
    var wait: SKAction!
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#F2F2F7FF")! // Light gray
        setupText()
        setupSkipButton()
        setupCircle()
        setupAnimations()
        DispatchQueue.main.asyncAfter(deadline: .now() + 18) {
            if !(self.isDialogue) {
                self.skipButton.alpha = 1
            }
        }
    }
    
    func setupSkipButton() {
        skipButton = SKLabelNode(text: "Skip")
        skipButton.fontName = "Noteworthy"
        skipButton.fontColor = .black
        skipButton.fontSize = 50
        skipButton.alpha = 0
        skipButton.position = CGPoint(x: frame.minX + 80, y: frame.maxY - 90)
        addChild(skipButton)
    }
    
    func setupText() {
        text = SKLabelNode(text: "Tap with the Pencil on the circle")
        text.position = CGPoint(x: 0, y: frame.minY + 80)
        text.fontName = "Noteworthy"
        text.fontColor = .black
        text.fontSize = 50
        addChild(text)
    }

    func switchText() {
        text.text = "Tap anywhere to continue"
    }
    
    // Creates the melody circle
    func setupCircle() {
        circle = SKShapeNode(circleOfRadius: 60)
        circle.position = CGPoint(x: 200, y: 200)
        circle.fillColor = UIColor(hex: "#E6514CFF")! // Red
        circle.strokeColor = .black
        circle.lineWidth = 4
        addChild(circle)
    }
    
    func setupAnimations() {
        quaverMovement = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 30, duration: 1),
            SKAction.moveBy(x: 0, y: -30, duration: 1)]))
        dialogueZoom = SKAction.sequence([SKAction.scale(to: 0.4, duration: 0.2), SKAction.scale(to: 0.5, duration: 0.2)])
        
        moveUpLeft = SKAction.move(to: CGPoint(x: -200, y: 200), duration: 0.3)
        moveUpRight = SKAction.move(to: CGPoint(x: 200, y: 200), duration: 0.3)
        moveDownLeft = SKAction.move(to: CGPoint(x: -200, y: -200), duration: 0.3)
        moveDownRight = SKAction.move(to: CGPoint(x: 200, y: -200), duration: 0.3)
        moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.3)
        fadeIn = SKAction.fadeIn(withDuration: 1)
        fadeOut = SKAction.fadeOut(withDuration: 1)
        wait = SKAction.wait(forDuration: 1)
    }
    
    func setupQuaver() {
        quaver = SKSpriteNode(imageNamed: "happyQuaver")
        quaver.setScale(0.8)
        quaver.position = CGPoint(x: -300, y: -40)
        quaver.alpha = 0
        addChild(quaver)
        
        neutralQuaver = SKTexture(imageNamed: "neutralQuaver")
        
        quaver.run(SKAction.sequence([wait, fadeIn]))
        quaver.run(quaverMovement)
    }
    
    func setupDialogues() {
        dialogue = SKSpriteNode(imageNamed: "melody0")
        dialogue.setScale(0.5)
        dialogue.position = CGPoint(x: 160, y: 40)
        dialogue.alpha = 0
        addChild(dialogue)
        
        for i in 0...3 {
            dialogues.append(SKTexture(imageNamed: "melody\(i)"))
        }
        
        dialogue.run(SKAction.sequence([wait, fadeIn]))
    }
    
    func switchDialogue() {
        dialogueIndex += 1
        dialogue.texture = dialogues[dialogueIndex]
        dialogue.run(dialogueZoom)
    }
    
    func goToDialogues() {
        soundManager.fadeIn(sound: .furElise, withVolume: 2)
        skipButton.alpha = 0
        circle.run(fadeOut)
        switchText()
        setupQuaver()
        setupDialogues()
        isDialogue = true
    }
    
    func goToNextScene() {
        soundManager.fadeOut(sound: .furElise)
        let sceneSize = CGSize(width: self.size.width, height: self.size.height)
        let scene = PitchScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view?.presentScene(scene, transition: SKTransition.fade(with: UIColor(hex: "#F2F2F7FF") ?? .white, duration: 1.2))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Grabs first touch detected
        guard let touch = touches.first else { return }
        // Saves the location of the touch
        let location = touch.location(in: self)
        
        if (skipButton.contains(location)) && (skipButton.alpha == 1) {
            goToDialogues()
        } else if isDialogue {
            switch dialogueIndex {
            case 0:
                quaver.texture = neutralQuaver
            case 1, 2:
                break
            default:
                goToNextScene()
                return
            }
            switchDialogue()
        // If hasn't reached dialogue part, tests if the circle contains the touch location and play the adequate sound based on melodyIndex
        } else if circle.contains(location) {
            switch melodyIndex {
            case 0, 2, 4:
                soundManager.stop(.E4)
                soundManager.play(.E4, withVolume: 0.5)
                circle.run(moveUpLeft)
            case 1, 3:
                soundManager.stop(.Dsharp4)
                soundManager.play(.Dsharp4, withVolume: 0.5)
                circle.run(moveUpRight)
            case 5:
                soundManager.play(.B3, withVolume: 0.5)
                circle.run(moveDownRight)
            case 6:
                soundManager.play(.D4, withVolume: 0.5)
                circle.run(moveDownLeft)
            case 7:
                soundManager.play(.C4, withVolume: 0.5)
                circle.run(moveUpRight)
            case 8:
                soundManager.play(.A3, withVolume: 0.5)
                circle.run(moveToCenter)
            case 9:
                goToDialogues()
            default:
                break
            }
            melodyIndex += 1
        }
    }
}
