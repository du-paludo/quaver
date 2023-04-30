//
//  IntroScene.swift
//  Quaver
//
//  Created by Eduardo Stefanel Paludo on 07/04/23.
//

import SpriteKit

class IntroScene: SKScene {
    var soundManager = SoundManager()
    
    // Circle and text first exhibited
    var beginCircle: SKShapeNode!
    var beginTexts = [SKLabelNode]()
    
    // Text used for instructions
    var text: SKLabelNode!
    
    // Animations
    var quaverMovement: SKAction!
    var dialogueZoom: SKAction!
    var shrink: SKAction!
    
    // Used to show Quaver
    var quaver: SKSpriteNode!
    var happyQuaver: SKTexture!
    var neutralQuaver: SKTexture!
    
    // Controls dialogues
    var dialogue: SKSpriteNode!
    var dialogues = [SKTexture]()
    var isDialogue = false
    var dialogueIndex = 0
    
    // Function executed when the scene starts
    override func didMove(to view: SKView) {
        setupAnimations()
        setupBegin()
        backgroundColor = UIColor(hex: "#F2F2F7FF") ?? .white
    }
    
    // Setup things used in the beggining
    func setupBegin() {
        soundManager.fadeIn(sound: .swanLakeOrchestra, withVolume: 1.4)

        // Black circle that shrinks
        beginCircle = SKShapeNode(circleOfRadius: 1000)
        beginCircle.fillColor = .black
        beginCircle.strokeColor = .clear
        addChild(beginCircle)
        
        beginTexts.append(SKLabelNode(text: "Please, play in portrait mode"))
        beginTexts[0].position.y = 80
        beginTexts[0].fontSize = 80
        
        beginTexts.append(SKLabelNode(text: "and use an Apple Pencil"))
        beginTexts[1].position.y = -80
        beginTexts[1].fontSize = 80
        
        beginTexts.append(SKLabelNode(text: "Tap anywhere to begin"))
        beginTexts[2].position.y = frame.minY + 80
        beginTexts[2].fontSize = 50
        
        for text in beginTexts {
            text.fontName = "Noteworthy"
            text.fontColor = .white
            addChild(text)
        }
    }
    
    func setupAnimations() {
        quaverMovement = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 30, duration: 1),
            SKAction.moveBy(x: 0, y: -30, duration: 1)]))
        dialogueZoom = SKAction.sequence([SKAction.scale(to: 0.4, duration: 0.2), SKAction.scale(to: 0.5, duration: 0.2)])
        shrink = SKAction.scale(to: 0, duration: 0.2)
    }
    
    func setupText() {
        text = SKLabelNode(text: "Tap anywhere to continue")
        text.position = CGPoint(x: 0, y: frame.minY + 80)
        text.fontName = "Noteworthy"
        text.fontColor = .black
        text.fontSize = 50
        addChild(text)
    }
    
    func setupQuaver() {
        quaver = SKSpriteNode(imageNamed: "neutralQuaver")
        quaver.setScale(0.8)
        quaver.position = CGPoint(x: -300, y: -40)
        addChild(quaver)
        
        happyQuaver = SKTexture(imageNamed: "happyQuaver")
        
        quaver.run(quaverMovement)
    }
    
    func setupDialogues() {
        dialogue = SKSpriteNode(imageNamed: "intro0")
        dialogue.position = CGPoint(x: 160, y: 40)
        dialogue.setScale(0.5)
        addChild(dialogue)
        
        for i in 0...2 {
            dialogues.append(SKTexture(imageNamed: "intro\(i)"))
        }
    }
    
    // Switches dialogues textures
    func switchDialogue() {
        dialogueIndex += 1
        dialogue.texture = dialogues[dialogueIndex]
        dialogue.run(dialogueZoom)
    }
    
    // Changes to dialogue part
    func goToDialogues() {
        beginTexts[0].removeFromParent()
        beginTexts[1].removeFromParent()
        beginTexts[2].removeFromParent()
        setupText()
        setupQuaver()
        setupDialogues()
        isDialogue = true
    }
    
    // Changes to next scene
    func goToNextScene() {
        soundManager.fadeOut(sound: .swanLakeOrchestra)
        let sceneSize = CGSize(width: self.size.width, height: self.size.height)
        let scene = MelodyScene(size: sceneSize)
        scene.scaleMode = .aspectFit
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.view?.presentScene(scene, transition: SKTransition.fade(with: UIColor(hex: "#F2F2F7FF") ?? .white, duration: 1.2))
    }
    
    // Function executed when a touch was detected
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Enters this if dialogues haven't started
        if (!isDialogue) {
            beginCircle.run(SKAction.sequence([shrink, SKAction.run {
                self.goToDialogues()
            }]))
        }
        // Otherwise, executes this part
        else {
            // Runs through all dialogues
            switch dialogueIndex {
            case 0:
                break
            case 1:
                // If is in second dialogue (index 1), changes texture before applying new dialogue
                quaver.texture = happyQuaver
            default:
                // If has reached the last dialogue, switch to next scene
                goToNextScene()
                return
            }
            // If hasn't reached the last dialogue, switch to the next one
            switchDialogue()
        }
    }
}
