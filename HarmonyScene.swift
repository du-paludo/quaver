//
//  GameScene.swift
//  Quaver
//
//  Created by Eduardo Stefanel Paludo on 03/04/23.
//

import SpriteKit

class HarmonyScene: SKScene {
    let soundManager = SoundManager()
    
    var skipButton: SKLabelNode!
    
    var text: SKLabelNode!
    var errorText: SKLabelNode!
    var isDialogue = false
    
    var outerCircles = [SKShapeNode]()
    var innerCircles = [SKShapeNode]()
    var isInsideCircle = false
    var circleIndex = 0
    
    var referenceCircles = [[SKShapeNode]]()
    var hasTouched = [Bool]()
    var hasTouchedAllCircles = false
    
    var quaverMovement: SKAction!
    var dialogueZoom: SKAction!
    var wait: SKAction!
    var fadeIn: SKAction!
    var fadeOut: SKAction!
    var appear: SKAction!
    var disappear: SKAction!
    var blink: SKAction!
    
    var quaver: SKSpriteNode!
    var happyQuaver: SKTexture!
    var neutralQuaver: SKTexture!
    var circleArrow: SKSpriteNode!
    
    var dialogue: SKSpriteNode!
    var dialogues = [SKTexture]()
    var dialogueIndex = 0
    
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#F2F2F7FF") ?? .white
        setupAnimations()
        setupSkipButton()
        setupText()
        setupCircles()
        DispatchQueue.main.asyncAfter(deadline: .now() + 26) {
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
        text = SKLabelNode(text: "Draw the circle inside the colored area")
        text.position = CGPoint(x: 0, y: frame.minY + 80)
        text.fontName = "Noteworthy"
        text.fontColor = .black
        text.fontSize = 50
        addChild(text)
        
        errorText = SKLabelNode(text: "Try again! Don't leave the colored area")
        errorText.position = CGPoint(x: 0, y: frame.minY + 80)
        errorText.fontName = "Noteworthy"
        errorText.fontColor = .red
        errorText.fontSize = 40
        errorText.alpha = 0
        addChild(errorText)
    }
    
    func switchText() {
        text.text = "Tap anywhere to continue"
        text.position = CGPoint(x: 0, y: frame.minY + 80)
    }
    
    func showError() {
        isInsideCircle = false
        text.run(disappear)
        errorText.run(appear)
    }
    
    func setupCircles() {
        var position: CGPoint
        
        // Initialize circles with random positions and colors
        for i in 0...7 {
            position = randomPosition()
            outerCircles.append(SKShapeNode(circleOfRadius: 160))
            outerCircles[i].position = position
            outerCircles[i].fillColor = UIColor(cgColor: randomColor())
            outerCircles[i].strokeColor = .black
            
            innerCircles.append(SKShapeNode(circleOfRadius: 100))
            innerCircles[i].position = position
            innerCircles[i].fillColor = .white
            innerCircles[i].strokeColor = .black
            
            addReferenceCircles(for: i, at: position)
        }
        
        outerCircles[0].fillColor = UIColor(hex: "#AFE0DFFF")!
        
        for _ in 0...3 {
            hasTouched.append(false)
        }
        
        circleArrow = SKSpriteNode(imageNamed: "circleArrow")
        circleArrow.position = outerCircles[0].position
        addChild(outerCircles[0])
        addChild(innerCircles[0])
        addChild(circleArrow)
        
        circleArrow.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 2), SKAction.fadeIn(withDuration: 2)])))
    }
    
    func switchCircle() {
        switch circleIndex {
        case 0:
            soundManager.play(.Am, withVolume: 0.6)
            circleArrow.removeFromParent()
        case 1:
            soundManager.play(.Dm7, withVolume: 0.6)
        case 2:
            soundManager.play(.G7, withVolume: 0.6)
        case 3:
            soundManager.play(.Cmaj, withVolume: 0.6)
        case 4:
            soundManager.play(.Fmaj, withVolume: 0.6)
        case 5:
            soundManager.play(.Dm7, withVolume: 0.6)
        case 6:
            soundManager.play(.E7, withVolume: 0.6)
        case 7:
            soundManager.play(.Amx, withVolume: 0.6)
            goToDialogues()
            return
        default:
            break
        }
        innerCircles[circleIndex].removeFromParent()
        outerCircles[circleIndex].removeFromParent()
        circleIndex += 1
        addChild(outerCircles[circleIndex])
        addChild(innerCircles[circleIndex])
    }
    
    // Creates four invisibles circles that must be touched to draw the bigger circle
    func addReferenceCircles(for index: Int, at position: CGPoint) {
        var tempArray = [SKShapeNode]()
        
        for i in 0...3 {
            tempArray.append(SKShapeNode(circleOfRadius: 30))
            tempArray[i].alpha = 0
        }
        
        tempArray[0].position = CGPoint(x: position.x, y: position.y - 130)
        tempArray[1].position = CGPoint(x: position.x + 130, y: position.y)
        tempArray[2].position = CGPoint(x: position.x, y: position.y + 130)
        tempArray[3].position = CGPoint(x: position.x - 130, y: position.y)
        
        for i in 0...3 {
            addChild(tempArray[i])
        }
        
        referenceCircles.append(tempArray)
    }

    func randomPosition() -> CGPoint {
        let x = CGFloat.random(in: (frame.minX + 180)...(frame.maxX - 180))
        let y = CGFloat.random(in: (frame.minY + 320)...(frame.maxY - 180))
        return CGPoint(x: x, y: y)
    }
    
    func randomColor() -> CGColor {
        return CGColor(
                    red: .random(in: 0...1),
                    green: .random(in: 0...1),
                    blue: .random(in: 0...1),
                    alpha: 1.0
                )
    }
    
    func setupAnimations() {
        quaverMovement = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 30, duration: 1),
            SKAction.moveBy(x: 0, y: -30, duration: 1)]))
        dialogueZoom = SKAction.sequence([SKAction.scale(to: 0.4, duration: 0.2), SKAction.scale(to: 0.5, duration: 0.2)])
        
        wait = SKAction.wait(forDuration: 1)
        fadeIn = SKAction.fadeIn(withDuration: 1)
        fadeOut = SKAction.fadeOut(withDuration: 1)
        appear = SKAction.sequence([SKAction.fadeIn(withDuration: 0), SKAction.wait(forDuration: 1.8), SKAction.fadeOut(withDuration: 0)])
        disappear = SKAction.sequence([SKAction.fadeOut(withDuration: 0), SKAction.wait(forDuration: 1.8), SKAction.fadeIn(withDuration: 0)])
        blink = SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 2), SKAction.fadeIn(withDuration: 2)]))
        
    }
    
    func setupQuaver() {
        quaver = SKSpriteNode(imageNamed: "neutralQuaver")
        quaver.setScale(0.8)
        quaver.position = CGPoint(x: -300, y: -40)
        quaver.alpha = 0
        addChild(quaver)
        
        happyQuaver = SKTexture(imageNamed: "happyQuaver")
        
        quaver.run(SKAction.sequence([wait, fadeIn]))
        quaver.run(quaverMovement)
    }
    
    func setupDialogues() {
        dialogue = SKSpriteNode(imageNamed: "harmony0")
        dialogue.setScale(0.5)
        dialogue.position = CGPoint(x: 160, y: 40)
        dialogue.alpha = 0
        addChild(dialogue)
        
        for i in 0...3 {
            dialogues.append(SKTexture(imageNamed: "harmony\(i)"))
        }
        
        dialogue.run(SKAction.sequence([wait, fadeIn]))
    }
    
    func switchDialogue() {
        dialogueIndex += 1
        dialogue.texture = dialogues[dialogueIndex]
        dialogue.run(dialogueZoom)
    }
    
    func goToDialogues() {
        soundManager.fadeIn(sound: .clairDeLune)
        skipButton.alpha = 0
        innerCircles[circleIndex].run(fadeOut)
        outerCircles[circleIndex].run(fadeOut)
        isDialogue = true
        switchText()
        setupQuaver()
        setupDialogues()
    }
    
    func goToNextScene() {
        soundManager.fadeOut(sound: .clairDeLune)
        let sceneSize = CGSize(width: self.size.width, height: self.size.height)
        let scene = DynamicsScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view?.presentScene(scene, transition: SKTransition.fade(with: UIColor(hex: "#F2F2F7FF") ?? .white, duration: 1.2))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if (skipButton.contains(location)) && (skipButton.alpha == 1) {
            if (circleArrow.inParentHierarchy(self)) {
                circleArrow.removeFromParent()
            }
            goToDialogues()
        }
        // Executes if it's in the dialogue part
        else if isDialogue {
            switch dialogueIndex {
            case 0, 1:
                switchDialogue()
            case 2:
                quaver.texture = happyQuaver
                switchDialogue()
            default:
                goToNextScene()
            }
        // Else, tests if the touch location is inside the outer circle and outside the inner circle
        } else {
            hasTouchedAllCircles = false
            if ((outerCircles[circleIndex].contains(location)) && (!innerCircles[circleIndex].contains(location))) {
                isInsideCircle = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if !isDialogue {
            // If touch location is outside the allowed area, show error
            if (!outerCircles[circleIndex].contains(location)) || (innerCircles[circleIndex].contains(location)) {
                showError()
            } else if isInsideCircle {
                // Tests if one of the reference circles contains the touch location and mark that circle as touched
                for (index, point) in referenceCircles[circleIndex].enumerated() {
                    if point.contains(location) {
                        hasTouched[index] = true
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDialogue {
            var hasTouchedAllCircles = true
            
            // Tests if every reference circle was touched
            for (index, circle) in hasTouched.enumerated() {
                if (circle == false) {
                    hasTouchedAllCircles = false
                } else {
                    hasTouched[index] = false
                }
            }
            
            // If all reference circles were touched, switch circle
            if (hasTouchedAllCircles) && (isInsideCircle) {
                hasTouchedAllCircles = false
                switchCircle()
            } else {
                showError()
            }
        }
    }
}
