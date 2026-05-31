import SpriteKit

class MenuScene: SKScene {

    private var startButton = SKShapeNode()
    private var startLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.03, blue: 0.08, alpha: 1)

        createBackgroundStars()
        createTitle()
        createHighScoreBox()
        createStartButton()
    }

    private func createBackgroundStars() {
        let spawnStars = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    self?.spawnStar()
                },
                SKAction.wait(forDuration: 0.08)
            ])
        )

        run(spawnStars)
    }

    private func spawnStar() {
        let radius = CGFloat.random(in: 1...3)

        let star = SKShapeNode(circleOfRadius: radius)
        star.fillColor = .white
        star.strokeColor = .clear
        star.alpha = CGFloat.random(in: 0.25...0.8)
        star.position = CGPoint(
            x: size.width + 10,
            y: CGFloat.random(in: 20...(size.height - 20))
        )
        star.zPosition = -10

        addChild(star)

        let speed = CGFloat.random(in: 80...180)
        let distance = size.width + 40
        let duration = TimeInterval(distance / speed)

        let move = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let remove = SKAction.removeFromParent()

        star.run(SKAction.sequence([move, remove]))
    }

    private func createTitle() {
        let gravityLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gravityLabel.text = "GRAVITY"
        gravityLabel.fontSize = 50
        gravityLabel.fontColor = .white
        gravityLabel.horizontalAlignmentMode = .center
        gravityLabel.verticalAlignmentMode = .center
        gravityLabel.position = CGPoint(x: size.width * 0.30, y: size.height * 0.58)
        gravityLabel.zPosition = 10
        addChild(gravityLabel)

        let shiftLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shiftLabel.text = "SHIFT"
        shiftLabel.fontSize = 50
        shiftLabel.fontColor = .cyan
        shiftLabel.horizontalAlignmentMode = .center
        shiftLabel.verticalAlignmentMode = .center
        shiftLabel.position = CGPoint(x: size.width * 0.30, y: size.height * 0.40)
        shiftLabel.zPosition = 10
        addChild(shiftLabel)

        let moveUp = SKAction.moveBy(x: 0, y: 5, duration: 0.8)
        let moveDown = SKAction.moveBy(x: 0, y: -5, duration: 0.8)
        let floating = SKAction.repeatForever(SKAction.sequence([moveUp, moveDown]))

        gravityLabel.run(floating)
        shiftLabel.run(floating)
    }

    private func createHighScoreBox() {
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")

        let box = SKShapeNode(rectOf: CGSize(width: 210, height: 72), cornerRadius: 16)
        box.fillColor = SKColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 0.95)
        box.strokeColor = .cyan
        box.lineWidth = 2
        box.glowWidth = 4
        box.position = CGPoint(x: size.width * 0.72, y: size.height * 0.62)
        box.zPosition = 10
        addChild(box)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        titleLabel.text = "BEST SCORE"
        titleLabel.fontSize = 15
        titleLabel.fontColor = .gray
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 18)
        titleLabel.zPosition = 11
        box.addChild(titleLabel)

        let valueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        valueLabel.text = "\(highScore)"
        valueLabel.fontSize = 30
        valueLabel.fontColor = .cyan
        valueLabel.verticalAlignmentMode = .center
        valueLabel.horizontalAlignmentMode = .center
        valueLabel.position = CGPoint(x: 0, y: -16)
        valueLabel.zPosition = 11
        box.addChild(valueLabel)
    }

    private func createStartButton() {
        startButton = SKShapeNode(rectOf: CGSize(width: 210, height: 58), cornerRadius: 18)
        startButton.fillColor = .cyan
        startButton.strokeColor = .white
        startButton.lineWidth = 3
        startButton.glowWidth = 6
        startButton.position = CGPoint(x: size.width * 0.72, y: size.height * 0.36)
        startButton.zPosition = 10
        addChild(startButton)

        startLabel.text = "JOGAR"
        startLabel.fontSize = 25
        startLabel.fontColor = .black
        startLabel.verticalAlignmentMode = .center
        startLabel.horizontalAlignmentMode = .center
        startLabel.position = CGPoint.zero
        startLabel.zPosition = 11
        startButton.addChild(startLabel)

        let scaleUp = SKAction.scale(to: 1.05, duration: 0.65)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.65)
        startButton.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
    }

    private func startGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .resizeFill

        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startButton.removeAllActions()

        let pressDown = SKAction.scale(to: 0.92, duration: 0.08)
        let pressUp = SKAction.scale(to: 1.0, duration: 0.08)
        let start = SKAction.run { [weak self] in
            self?.startGame()
        }

        startButton.run(SKAction.sequence([pressDown, pressUp, start]))
    }
}
