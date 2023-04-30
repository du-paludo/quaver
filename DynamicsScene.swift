//
//  DynamicsScene.swift
//  Quaver
//
//  Created by Eduardo Stefanel Paludo on 08/04/23.
//

import SpriteKit

class DynamicsScene: SKScene {
    let soundManager = SoundManager()
    
    var skipButton: SKLabelNode!
    
    var upperText: SKLabelNode!
    var lowerText: SKLabelNode!
    var errorText: SKLabelNode!
    var isDialogue = false
    
    var quaverMovement: SKAction!
    var dialogueZoom: SKAction!
    var wait: SKAction!
    var fadeIn: SKAction!
    var fadeOut: SKAction!
    var appear: SKAction!
    var disappear: SKAction!
    
    var bar: SKSpriteNode!
    var barShape: SKShapeNode!
    var cropNode: SKCropNode!
    var barMask: SKSpriteNode!
    var backgroundBar: SKShapeNode!
    var barHighLine: SKShapeNode!
    var barLowLine: SKShapeNode!
    
    var quaver: SKSpriteNode!
    var happyQuaver: SKTexture!
    var neutralQuaver: SKTexture!
    var circles = [SKShapeNode]()
    var circleIndex = 0
    var isInsideCircle = false
    
    var dialogue: SKSpriteNode!
    var dialogues = [SKTexture]()
    var dialogueIndex = 0
    
    var maximumForce: CGFloat = 0
    var maximumPossibleForce: CGFloat!
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#F2F2F7FF") ?? .white
        setupText()
        setupAnimations()
        setupSkipButton()
        setupForceBar()
        setupCircles()
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
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
        upperText = SKLabelNode(text: "Press with light pressure on the green circle")
        upperText.position = CGPoint(x: 0, y: frame.minY + 110)
        upperText.fontName = "Noteworthy"
        upperText.fontColor = .black
        upperText.fontSize = 40
        addChild(upperText)
        
        lowerText = SKLabelNode(text: "Release when the pressure bar gets green")
        lowerText.position = CGPoint(x: 0, y: frame.minY + 50)
        lowerText.fontName = "Noteworthy"
        lowerText.fontColor = .black
        lowerText.fontSize = 40
        addChild(lowerText)
        
        errorText = SKLabelNode(text: "Try again! Let go when the bar contains the right pressure")
        errorText.position = CGPoint(x: 0, y: frame.minY + 80)
        errorText.fontName = "Noteworthy"
        errorText.fontColor = .red
        errorText.fontSize = 40
        errorText.alpha = 0
        addChild(errorText)
        
    }
    
    func removeText() {
        lowerText.removeFromParent()
        upperText.removeFromParent()
    }
    
    func setupForceBar() {
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
        
        barMask = SKSpriteNode(color: .green, size: CGSize(width: 80, height: 0))
        barMask.anchorPoint = CGPoint(x: 0.5, y: 0)
        barMask.position = CGPoint(x: 0, y: -bar.size.height/2)
        cropNode.addChild(barMask)
        
        backgroundBar = SKShapeNode(rectOf: CGSize(width: 80, height: 600), cornerRadius: 20)
        backgroundBar.position = CGPoint(x: -400, y: 0)
        backgroundBar.fillColor = .clear
        backgroundBar.strokeColor = .black
        backgroundBar.lineWidth = 4
        
        barHighLine = SKShapeNode(rectOf: CGSize(width: 80, height: 4))
        barHighLine.position = CGPoint(x: -400, y: 100)
        barHighLine.fillColor = .black
        barHighLine.strokeColor = .clear
        barHighLine.alpha = 1
        
        barLowLine = SKShapeNode(rectOf: CGSize(width: 80, height: 4))
        barLowLine.position = CGPoint(x: -400, y: -100)
        barLowLine.fillColor = .black
        barLowLine.strokeColor = .clear
        barLowLine.alpha = 1
        
        addChild(backgroundBar)
        addChild(barHighLine)
        addChild(barLowLine)
    }
    
    func updateForceBar(_ force: CGFloat) {
        let forceRatio = force/3.6
        barMask.size.height = bar.size.height * forceRatio
        switch forceRatio {
        // If light pressure has been applied, change the bar color to green
        case 0...1/3:
            barMask.color = .green
        // If medium pressure, change to yellow
        case 1/3...2/3:
            barMask.color = .yellow
        // If high pressure, change to red
        case 2/3...1:
            barMask.color = .red
        default:
            break
        }
    }
    
    func setupCircles() {
        for i in 0...14 {
            circles.append(SKShapeNode(circleOfRadius: 40))
            circles[i].position = randomPosition()
            circles[i].fillColor = randomColor()
            circles[i].strokeColor = .black
            circles[i].lineWidth = 4
        }
        circles[0].fillColor = .green
        circles[1].fillColor = .yellow
        circles[2].fillColor = .red
        addChild(circles[0])
    }
    
    func switchCircle() {
        switch circleIndex {
        case 0:
            upperText.text = "Press with medium pressure on the yellow circle"
            lowerText.text = "Release when the pressure bar gets yellow"
        case 1:
            upperText.text = "Press with high pressure on the red circle"
            lowerText.text = "Release when the pressure bar gets red"
        case 2:
            upperText.text = "Press with light pressure on the green circles,"
            lowerText.text = "medium on the yellow ones and high on the red ones"
        case 3...13:
            break
        default:
            goToDialogues()
            return
        }
        circles[circleIndex].removeFromParent()
        circleIndex += 1
        addChild(circles[circleIndex])
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
    }
    
    func randomPosition() -> CGPoint {
        let x = CGFloat.random(in: (frame.minX + 240)...(frame.maxX - 80))
        let y = CGFloat.random(in: (frame.minY + 240)...(frame.maxY - 80))
        return CGPoint(x: x, y: y)
    }
    
    func randomColor() -> UIColor {
        let colors = [UIColor.green, .yellow, .red]
        return colors.randomElement()!
    }
    
    func setupQuaver() {
        quaver = SKSpriteNode(imageNamed: "happyQuaver")
        quaver.setScale(0.8)
        quaver.position = CGPoint(x: -300, y: -40)
        quaver.alpha = 0
        addChild(quaver)
        
        neutralQuaver = SKTexture(imageNamed: "neutralQuaver")
        happyQuaver = SKTexture(imageNamed: "happyQuaver")
        
        quaver.run(SKAction.sequence([wait, fadeIn]))
        quaver.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 30, duration: 1),
            SKAction.moveBy(x: 0, y: -30, duration: 1)])))
    }
    
    func setupDialogues() {
        dialogue = SKSpriteNode(imageNamed: "dynamics0")
        dialogue.setScale(0.5)
        dialogue.position = CGPoint(x: 160, y: 40)
        dialogue.alpha = 0
        addChild(dialogue)
        
        for i in 0...4 {
            dialogues.append(SKTexture(imageNamed: "dynamics\(i)"))
        }
        
        // Execute the final sequence of dialogues
        dialogue.run(SKAction.sequence([
            wait, fadeIn,
            SKAction.wait(forDuration: 3.6),
            SKAction.run { self.quaver.texture = self.neutralQuaver },
            SKAction.setTexture(dialogues[1]),
            SKAction.wait(forDuration: 3.6),
            SKAction.setTexture(dialogues[2]),
            SKAction.wait(forDuration: 4),
            SKAction.setTexture(dialogues[3]),
            SKAction.wait(forDuration: 3.8),
            SKAction.setTexture(dialogues[4]),
            SKAction.run {
                self.quaver.texture = self.happyQuaver
            },
            SKAction.wait(forDuration: 3.8),
            SKAction.run {
                let endCircle = SKShapeNode(circleOfRadius: 10)
                endCircle.fillColor = .black
                endCircle.strokeColor = .clear
                self.addChild(endCircle)
                endCircle.run(SKAction.scale(to: 200, duration: 0.6))
            },
            SKAction.run {
                let endText = SKLabelNode(text: "Thanks for playing!")
                endText.fontName = "Noteworthy"
                endText.fontSize = 80
                self.addChild(endText)
            }]))
    }
    
    func showError() {
        upperText.run(disappear)
        lowerText.run(disappear)
        errorText.run(appear)
    }
    
    func goToDialogues() {
        soundManager.fadeIn(sound: .pathetique)
        isDialogue = true
        removeText()
        setupQuaver()
        setupDialogues()
        skipButton.alpha = 0
        barLowLine.run(fadeOut)
        barHighLine.run(fadeOut)
        backgroundBar.run(fadeOut)
        circles[circleIndex].run(fadeOut)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if (skipButton.contains(location)) && (skipButton.alpha == 1) {
            skipButton.removeFromParent()
            goToDialogues()
        } else if (circles[circleIndex].contains(location)) && (!isDialogue) {
            maximumPossibleForce = touch.maximumPossibleForce
            maximumForce = 0
            isInsideCircle = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var force = touch.force

        if isInsideCircle {
            if force > maximumForce {
                maximumForce = force
            }
            if force > 3.6 {
                force = 3.6
            }
            updateForceBar(force)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard touches.first != nil else { return }
        
        if (isInsideCircle) && (!isDialogue) {
            let sound: SoundManager.Sound
            let forceRatio = maximumForce/maximumPossibleForce
            updateForceBar(0)
            
            switch circleIndex {
            case 0, 14:
                sound = .Eflat3
            case 1, 13:
                sound = .F3
            case 2, 12:
                sound = .G3x
            case 3, 11:
                sound = .Aflat3
            case 4, 10:
                sound = .Bflat3
            case 5, 9:
                sound = .C4x
            case 6, 8:
                sound = .D4x
            case 7:
                sound = .Eflat4
            default:
                sound = .C0
            }
            switch circles[circleIndex].fillColor {
            case .green:
                if forceRatio < 1/3 {
                    soundManager.play(sound, withVolume: 0.2)
                    switchCircle()
                } else {
                    showError()
                }
            case .yellow:
                if (forceRatio > 1/3) && (forceRatio < 2/3) {
                    soundManager.play(sound, withVolume: 0.5)
                    switchCircle()
                } else {
                    showError()
                }
            case .red:
                if (forceRatio > 2/3) {
                    soundManager.play(sound, withVolume: 0.8)
                    switchCircle()
                } else {
                    showError()
                }
            default:
                break
            }
            isInsideCircle = false
        }
    }
}
