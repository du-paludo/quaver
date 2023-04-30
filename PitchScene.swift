//
//  PitchScene.swift
//  Quaver
//
//  Created by Eduardo Stefanel Paludo on 08/04/23.
//

import SpriteKit

class PitchScene: SKScene {
    let soundManager = SoundManager()
    
    var skipButton: SKLabelNode!
    
    var lowerText: SKLabelNode!
    var upperText: SKLabelNode!
    
    var circle: SKShapeNode!
    var dragArrow: SKSpriteNode!
    var isInsideCircle = false
    
    var previousLocation: CGPoint!
    var referencePoints = [CGPoint]()
    var hasPlayed = [Bool]()
    var hasPlayedAll = false
    
    var bar: SKSpriteNode!
    var barShape: SKShapeNode!
    var cropNode: SKCropNode!
    var barMask: SKSpriteNode!
    var backgroundBar: SKShapeNode!
    var barLine: SKShapeNode!
    
    var line: SKShapeNode!
    var progressCircles = [SKShapeNode]()
    
    var quaverMovement: SKAction!
    var dialogueZoom: SKAction!
    var moveToCenter: SKAction!
    var wait: SKAction!
    var fadeIn: SKAction!
    var fadeOut: SKAction!
    var scaleBig: SKAction!
    var scaleBack: SKAction!
    
    var quaver: SKSpriteNode!
    var neutralQuaver: SKTexture!
    var happyQuaver: SKTexture!
    
    var dialogue: SKSpriteNode!
    var dialogues = [SKTexture]()
    var dialogueIndex = 0

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#F2F2F7FF") ?? .white
        setupAnimations()
        setupSkipButton()
        setupText()
        setupCircle()
        setupReferencePoints()
        setupLine()
        setupAltitudeBar()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            if (self.dialogueIndex == 0) {
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
        upperText = SKLabelNode(text: "Drag slowly the circle up and down to change the note")
        upperText.position.y = frame.minY + 110
        upperText.fontName = "Noteworthy"
        upperText.fontColor = .black
        upperText.fontSize = 40
        addChild(upperText)
        
        lowerText = SKLabelNode(text: "Control the sound by changing the inclination of the Pencil")
        lowerText.fontName = "Noteworthy"
        lowerText.position.y = frame.minY + 50
        lowerText.fontColor = .black
        lowerText.fontSize = 40
        addChild(lowerText)
    }
    
    func switchText() {
        lowerText.removeFromParent()
        upperText.text = "Tap anywhere to continue"
        upperText.position.y -= 30
    }
    
    func setupCircle() {
        circle = SKShapeNode(circleOfRadius: 60)
        circle.position = CGPoint(x: 0, y: 0)
        circle.fillColor = UIColor(hex: "#417B9EFF")! // Dark blue
        circle.strokeColor = .black
        circle.lineWidth = 4
        addChild(circle)
        
        // Creates arrow indicator
        dragArrow = SKSpriteNode(imageNamed: "upDownArrows")
        dragArrow.position.x = 400
        addChild(dragArrow)
    }
    
    func setupReferencePoints() {
        for i in 0...6 {
            // Creates reference points to help identify where the circle is
            referencePoints.append(CGPoint(x: 0, y: -360 + i * 120))
            // Initialize the point as not played
            hasPlayed.append(false)
        }
    }
    
    func setupAltitudeBar() {
        // Creates the bar, its shape and the mask that fulfills the bar
        bar = SKSpriteNode(color: .clear, size: CGSize(width: 80, height: 600))
        bar.position = CGPoint(x: -400, y: 0)
        addChild(bar)
        
        barShape = SKShapeNode(rectOf: CGSize(width: bar.size.width - 4, height: bar.size.height - 4), cornerRadius: 20)
        barShape.fillColor = .white
        barShape.strokeColor = .black
        barShape.lineWidth = 4
        barShape.zPosition = -1
        
        cropNode = SKCropNode()
        cropNode.maskNode = barShape
        bar.addChild(cropNode)
        
        barMask = SKSpriteNode(color: UIColor(hex: "#417B9EFF") ?? .darkGray, size: CGSize(width: 80, height: 0))
        barMask.anchorPoint = CGPoint(x: 0.5, y: 0)
        barMask.position = CGPoint(x: 0, y: -bar.size.height/2)
        cropNode.addChild(barMask)
        
        // Creates the appearence of the altitude bar
        backgroundBar = SKShapeNode(rectOf: CGSize(width: 80, height: 600), cornerRadius: 20)
        backgroundBar.position = CGPoint(x: -400, y: 0)
        backgroundBar.fillColor = .clear
        backgroundBar.strokeColor = .black
        backgroundBar.lineWidth = 4
        
        barLine = SKShapeNode(rectOf: CGSize(width: 80, height: 4))
        barLine.position = CGPoint(x: -400, y: 100)
        barLine.fillColor = .black
        barLine.strokeColor = .clear
        barLine.alpha = 1
        
        addChild(backgroundBar)
        addChild(barLine)
    }
    
    func updateAltitudeBar(_ altitudeAngle: CGFloat) {
        // Defines a ratio between 0 and 1
        let altitudeRatio = altitudeAngle/(CGFloat.pi/2)
        // Adjusts the height of the bar based
        barMask.size.height = bar.size.height * altitudeRatio
        switch altitudeRatio {
        // If the angle is lower than pi/3 (60 degrees), the bar gets half visible
        case 0...2/3:
            barMask.alpha = 0.6
        // If the angle is higher than pi/3, the bar gets fully visible
        case 2/3...1:
            barMask.alpha = 1
        default:
            break
        }
    }
    
    func setupLine() {
        line = SKShapeNode(rectOf: CGSize(width: 4, height: 720))
        line.position.x = 400
        line.fillColor = .black
        line.strokeColor = .clear
        addChild(line)
        
        for i in 0...6 {
            progressCircles.append(SKShapeNode(circleOfRadius: 10))
            progressCircles[i].position.y = referencePoints[i].y
            progressCircles[i].position.x = 400
            progressCircles[i].fillColor = .black
            progressCircles[i].strokeColor = .clear
            addChild(progressCircles[i])
        }
    }
    
    func setupAnimations() {
        quaverMovement = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 30, duration: 1),
            SKAction.moveBy(x: 0, y: -30, duration: 1)]))
        dialogueZoom = SKAction.sequence([SKAction.scale(to: 0.4, duration: 0.2), SKAction.scale(to: 0.5, duration: 0.2)])
        
        moveToCenter = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.3)
        wait = SKAction.wait(forDuration: 1)
        fadeIn = SKAction.fadeIn(withDuration: 1)
        fadeOut = SKAction.fadeOut(withDuration: 1)
        scaleBig = SKAction.scale(to: 1.2, duration: 0.2)
        scaleBack = SKAction.scale(to: 1, duration: 0.2)
    }
    
    func setupQuaver() {
        quaver = SKSpriteNode(imageNamed: "happyQuaver")
        quaver.position = CGPoint(x: -300, y: -40)
        quaver.setScale(0.8)
        quaver.alpha = 0
        addChild(quaver)
        
        neutralQuaver = SKTexture(imageNamed: "neutralQuaver")
        
        quaver.run(SKAction.sequence([wait, fadeIn]))
        quaver.run(quaverMovement)
    }
    
    func setupDialogues() {
        dialogue = SKSpriteNode(imageNamed: "pitch0")
        dialogue.setScale(0.5)
        dialogue.position = CGPoint(x: 160, y: 40)
        dialogue.alpha = 0
        addChild(dialogue)
        
        for i in 0...2 {
            dialogues.append(SKTexture(imageNamed: "pitch\(i)"))
        }
        
        dialogue.run(SKAction.sequence([wait, fadeIn]))
    }
    
    func switchDialogue() {
        dialogue.texture = dialogues[dialogueIndex]
        dialogue.run(dialogueZoom)
        dialogueIndex += 1
    }
    
    func goToDialogues() {
        soundManager.fadeIn(sound: .winterWind)
        line.run(fadeOut)
        for i in 0...6 {
            progressCircles[i].run(fadeOut)
        }
        circle.run(SKAction.sequence([moveToCenter, fadeOut]))
        skipButton.alpha = 0
        dragArrow.run(fadeOut)
        barLine.run(fadeOut)
        backgroundBar.run(fadeOut)
        setupQuaver()
        setupDialogues()
        dialogueIndex += 1
    }
    
    func goToNextScene() {
        soundManager.fadeOut(sound: .winterWind)
        let sceneSize = CGSize(width: self.size.width, height: self.size.height)
        let scene = RhythmScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view?.presentScene(scene, transition: SKTransition.fade(with: UIColor(hex: "#F2F2F7FF") ?? .white, duration: 1.2))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if (skipButton.contains(location)) && (skipButton.alpha == 1) {
            hasPlayedAll = true
            switchText()
            goToDialogues()
        } else if (circle.contains(location)) && (circle.alpha != 0) {
            isInsideCircle = true
            circle.run(scaleBig)
            previousLocation = location
        }
        // If has played all sounds
        else if hasPlayedAll {
            switch dialogueIndex {
            case 0:
                goToDialogues()
            case 1:
                quaver.texture = neutralQuaver
                switchDialogue()
            case 2:
                switchDialogue()
            default:
                goToNextScene()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        // Saves the altitude angle of the touch
        let altitudeAngle = touch.altitudeAngle

        // If touch was inside circle when started
        if isInsideCircle {
            // If the touch location is higher than the previous location and the circle is within borders, increase its y position
            if (location.y > previousLocation.y) && (circle.position.y <= 360) {
                circle.position.y +=  (location.y - previousLocation.y)
                if circle.position.y > 360 {
                    circle.position.y = 360
                }
            // If it's lower, decrease its y position
            } else if (location.y < previousLocation.y) && (circle.position.y >= -360) {
                circle.position.y -= (previousLocation.y - location.y)
                if (circle.position.y < -360) {
                    circle.position.y = -360
                }
            }
            
            // Executes if the altitudeAngle is higher than pi/3 (60 degrees)
            if altitudeAngle > CGFloat.pi / 3 {
                circle.alpha = 1
                // Test if the circle contains each of the referencePoints
                for (index, referencePoint) in referencePoints.enumerated() {
                    if circle.contains(referencePoint) {
                        // If it contains, marks the point as played and plays the right sound
                        hasPlayed[index] = true
                        progressCircles[index].fillColor = UIColor(hex: "#417B9EFF")!
                        switch index {
                        case 0:
                            soundManager.play(.C0, withVolume: 0.6)
                        case 1:
                            soundManager.play(.C1, withVolume: 0.6)
                        case 2:
                            soundManager.play(.C2, withVolume: 0.6)
                        case 3:
                            soundManager.play(.C3, withVolume: 0.6)
                        case 4:
                            soundManager.play(.C4, withVolume: 0.6)
                        case 5:
                            soundManager.play(.C5, withVolume: 0.6)
                        case 6:
                            soundManager.play(.C6, withVolume: 0.6)
                        default:
                            break
                        }
                    }
                }
            } else {
                circle.alpha = 0.6
            }
            
            // Tests if all sounds were played
            if (!hasPlayedAll) && (hasPlayed.filter({ $0 == false }).isEmpty) {
                hasPlayedAll = true
                switchText()
            }
            
            updateAltitudeBar(altitudeAngle)
            previousLocation = location
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Resets the altitude bar
        updateAltitudeBar(0)
        if isInsideCircle {
            circle.run(scaleBack)
            isInsideCircle = false
        }
    }
}
