//
//  RhythmScene.swift
//  Quaver
//
//  Created by Eduardo Stefanel Paludo on 08/04/23.
//

import SpriteKit

class RhythmScene: SKScene {
    let soundManager = SoundManager()
    var melodyIndex = 0
    var isPlaying = false
    
    var skipButton: SKLabelNode!
    
    var upperText: SKLabelNode!
    var lowerText: SKLabelNode!
    var errorText: SKLabelNode!
    var textIndex = 0
    
    var button: SKShapeNode!
    var buttonText: SKLabelNode!
    
    var quaverMovement: SKAction!
    var dialogueZoom: SKAction!
    var wait: SKAction!
    var fadeIn: SKAction!
    var fadeOut: SKAction!
    var scaleBig: SKAction!
    var scaleSmall: SKAction!
    var scaleBack: SKAction!
    var appear: SKAction!
    var disappear: SKAction!
    var blink: SKAction!
    var turnGreen: SKAction!
    var turnBlack: SKAction!
    
    var quaver: SKSpriteNode!
    var neutralQuaver: SKTexture!
    var happyQuaver: SKTexture!
    
    var line: SKShapeNode!
    var progressCircles = [SKShapeNode]()
    
    var circle: SKShapeNode!
    var upperCircle: SKShapeNode!
    var lowerCircle: SKShapeNode!
    var colloredCircle: SKTexture!
    var tap: SKSpriteNode!
    
    var isInsideCircle = false
    
    var dialogue: SKSpriteNode!
    var dialogues = [SKTexture]()
    var dialogueIndex = 0

    var timeTouchBegan: TimeInterval!
    var touchDuration: TimeInterval!
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: "#F2F2F7FF")!
        setupAnimations()
        setupSkipButton()
        setupText()
        setupCircle()
        setupLine()
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            if (self.textIndex != 2) {
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
        upperText = SKLabelNode(text: "Tap the circle to hear the song. Try to memorize it!")
        upperText.position.y = frame.minY + 80
        upperText.fontName = "Noteworthy"
        upperText.fontColor = .black
        upperText.fontSize = 40
        addChild(upperText)
        
        lowerText = SKLabelNode(text: "Hold the touch for long sounds and just tap for short ones")
        lowerText.position.y = frame.minY + 50
        lowerText.fontName = "Noteworthy"
        lowerText.fontColor = .black
        lowerText.fontSize = 38
        
        errorText = SKLabelNode(text: "Try again! Listen carefully to the duration of sounds")
        errorText.position.y = frame.minY + 80
        errorText.fontColor = .red
        errorText.fontSize = 40
        errorText.fontName = "Noteworthy"
        errorText.alpha = 0
        addChild(errorText)
    }
    
    // Changes the text based on current state of the scene
    func switchText() {
        switch textIndex {
        case 1:
            upperText.text = "Now, play the same sequence in the circle"
            upperText.position.y = frame.minY + 110
            addChild(lowerText)
        case 2:
            upperText.text = "Tap anywhere to continue"
            upperText.position.y = frame.minY + 80
            if (lowerText.inParentHierarchy(self)) {
                lowerText.removeFromParent()
            }
        default:
            break
        }
    }
    
    // Resets the melody index and shows error text
    func showError() {
        melodyIndex = 0
        for i in 0...5 {
            progressCircles[i].fillColor = .black
        }
        upperText.run(disappear)
        lowerText.run(disappear)
        errorText.run(appear)
    }
    
    // Creates button to play again
    func setupButton() {
        button = SKShapeNode(rect: CGRect(origin: CGPoint(x: -150, y: frame.maxY - 265), size: CGSize(width: 300, height: 80)), cornerRadius: 20)
        button.fillColor = .white
        button.strokeColor = .black
        button.lineWidth = 2
        addChild(button)
        
        buttonText = SKLabelNode(text: "Hear song again")
        buttonText.position.y = frame.maxY - 240
        buttonText.fontName = "Noteworthy"
        buttonText.fontSize = 40
        buttonText.fontColor = .black
        addChild(buttonText)
    }
    
    // Creates middle circle with tap gesture
    func setupCircle() {
        circle = SKShapeNode(circleOfRadius: 140)
        circle.position = CGPoint(x: 0, y: 0)
        circle.fillColor = .black
        circle.strokeColor = .black
        circle.lineWidth = 4
        addChild(circle)
        
        /* tap = SKSpriteNode(imageNamed: "tap")
        circle.addChild(tap)
        tap.run(blink) */
    }
    
    // Creates line with progress in the top
    func setupLine() {
        line = SKShapeNode(rectOf: CGSize(width: 500, height: 4))
        line.position.y = frame.maxY - 120
        line.fillColor = .black
        line.strokeColor = .clear
        addChild(line)

        for i in 0...5 {
            switch i {
            case 0, 5:
                progressCircles.append(SKShapeNode(rectOf: CGSize(width: 40, height: 20), cornerRadius: 10))
            case 1, 2, 3, 4:
                progressCircles.append(SKShapeNode(circleOfRadius: 10))
            default:
                break
            }
            progressCircles[i].position = CGPoint(x: -250 + 100 * i, y: Int(frame.maxY - 120))
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
        
        wait = SKAction.wait(forDuration: 1)
        fadeIn = SKAction.fadeIn(withDuration: 1)
        fadeOut = SKAction.fadeOut(withDuration: 1)
        scaleBig = SKAction.scale(to: 1.4, duration: 0.2)
        scaleSmall = SKAction.scale(to: 1.2, duration: 0.2)
        scaleBack = SKAction.scale(to: 1, duration: 0.2)
        appear = SKAction.sequence([SKAction.fadeIn(withDuration: 0), SKAction.wait(forDuration: 1.8), SKAction.fadeOut(withDuration: 0)])
        disappear = SKAction.sequence([SKAction.fadeOut(withDuration: 0), SKAction.wait(forDuration: 1.8), SKAction.fadeIn(withDuration: 0)])
        blink = SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 2), SKAction.fadeIn(withDuration: 2)]))
        
        turnGreen = SKAction.colorTransitionAction(fromColor: .black, toColor: UIColor(hex: "#81A060FF")!)
        turnBlack = SKAction.colorTransitionAction(fromColor: UIColor(hex: "#81A060FF")!, toColor: .black)
    }
    
    func setupQuaver() {
        quaver = SKSpriteNode(imageNamed: "happyQuaver")
        quaver.position = CGPoint(x: -300, y: -40)
        quaver.setScale(0.8)
        quaver.alpha = 0
        addChild(quaver)
        
        neutralQuaver = SKTexture(imageNamed: "neutralQuaver")
        happyQuaver = SKTexture(imageNamed: "happyQuaver")
        
        quaver.run(SKAction.sequence([wait, fadeIn]))
        quaver.run(quaverMovement)
    }
    
    func setupDialogues() {
        dialogue = SKSpriteNode(imageNamed: "rhythm0")
        dialogue.position = CGPoint(x: 160, y: 40)
        dialogue.setScale(0.5)
        dialogue.alpha = 0
        addChild(dialogue)
        
        for i in 0...4 {
            dialogues.append(SKTexture(imageNamed: "rhythm\(i)"))
        }
        
        dialogue.run(SKAction.sequence([wait, fadeIn]))
        dialogue.run(dialogueZoom)
    }
    
    func switchDialogue() {
        dialogueIndex += 1
        dialogue.texture = dialogues[dialogueIndex]
        dialogue.run(dialogueZoom)
    }
    
    // Play the melody and animate the circle
    func playSong() {
        isPlaying = true
        soundManager.play(.swanLake, withVolume: 0.6)
        circle.run(turnGreen)
        circle.run(SKAction.sequence([scaleBig, wait, scaleBack,
                                      scaleSmall, scaleBack,
                                      scaleSmall, scaleBack,
                                      scaleSmall, scaleBack,
                                      scaleSmall, scaleBack,
                                      scaleBig, wait, scaleBack,
                                      turnBlack, SKAction.run { self.isPlaying = false }]))
    }
    
    func goToGame() {
        //tap.removeFromParent()
        textIndex = 1
        switchText()
        setupButton()
        playSong()
    }
    
    func goToDialogues() {
        soundManager.fadeIn(sound: .cortaJaca, withVolume: 0.8)
        line.run(fadeOut)
        for i in 0...5 {
            progressCircles[i].run(fadeOut)
        }
        skipButton.alpha = 0
        circle.run(fadeOut)
        textIndex = 2
        switchText()
        setupQuaver()
        setupDialogues()
    }
    
    func goToNextScene() {
        soundManager.fadeOut(sound: .cortaJaca)
        let sceneSize = CGSize(width: self.size.width, height: self.size.height)
        let scene = HarmonyScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view?.presentScene(scene, transition: SKTransition.fade(with: UIColor(hex: "#F2F2F7FF") ?? .white, duration: 1.2))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        switch textIndex {
        // First instruction
        case 0:
            // Executes if the circle is clicked for the first time
            if (circle.contains(location)) && (!isPlaying) {
                goToGame()
            }
        // Second instruction
        case 1:
            // Executes if the button to play again is touched
            if (button.contains(location)) && (!isPlaying) {
                playSong()
            // If the circle is touched and the melody isn't playing
            } else if (circle.contains(location)) && (!isPlaying) {
                isInsideCircle = true
                // Saves the time when the touch began
                timeTouchBegan = touch.timestamp
                // Plays the proper sounds and animations based on melodyIndex
                switch melodyIndex {
                case 0, 5:
                    soundManager.stop(.Fsharp4)
                    soundManager.play(.Fsharp4, withVolume: 0.6)
                    circle.run(scaleBig)
                case 1:
                    soundManager.play(.B3x, withVolume: 0.6)
                    circle.run(SKAction.sequence([scaleSmall, scaleBack]))
                case 2:
                    soundManager.play(.Csharp4, withVolume: 0.6)
                    circle.run(SKAction.sequence([scaleSmall, scaleBack]))
                case 3:
                    soundManager.play(.D4x, withVolume: 0.6)
                    circle.run(SKAction.sequence([scaleSmall, scaleBack]))
                case 4:
                    soundManager.play(.E4x, withVolume: 0.6)
                    circle.run(SKAction.sequence([scaleSmall, scaleBack]))
                default:
                    break
                }
            }
        // Dialogue part
        case 2:
            switch dialogueIndex {
            case 0:
                quaver.texture = neutralQuaver
            case 1, 2:
                break
            case 3:
                quaver.texture = happyQuaver
            default:
                goToNextScene()
                return
            }
            switchDialogue()
        default:
            break
        }
        
        if (skipButton.contains(location)) && (skipButton.alpha == 1) {
            goToDialogues()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if (isInsideCircle) && (!isPlaying) && (textIndex == 1) {
            // Ssves the duration of the touch
            touchDuration = touch.timestamp - timeTouchBegan
            switch melodyIndex {
            // If is the first note, show error if it's too short or too long
            case 0:
                circle.run(scaleBack)
                if (touchDuration < 0.4) || (touchDuration > 2) {
                    showError()
                    return
                }
            // If is one of the middle notes, show error if it's too long
            case 1, 2, 3, 4:
                if (touchDuration > 0.4) {
                    showError()
                    return
                }
            // If is the last note and timing was right, go to dialogues
            case 5:
                circle.run(scaleBack)
                if (touchDuration < 0.4) || (touchDuration > 2) {
                    showError()
                    return
                } else {
                    button.run(fadeOut)
                    buttonText.run(fadeOut)
                    goToDialogues()
                }
            default:
                break
            }
            // If timing was correct, progress circle of the respective note gets colored
            progressCircles[melodyIndex].fillColor = UIColor(hex: "#81A060FF")!
            melodyIndex += 1
            isInsideCircle = false
        }
    }
}
