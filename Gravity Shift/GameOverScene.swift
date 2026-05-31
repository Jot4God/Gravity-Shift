import SpriteKit

class GameOverScene: SKScene {

    private let finalScore: Int
    private var restartButton = SKShapeNode()

    private var highScore = 0
    private var isNewHighScore = false

    init(size: CGSize, finalScore: Int) {
        self.finalScore = finalScore
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        self.finalScore = 0
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.03, blue: 0.08, alpha: 1)

        updateHighScore()

        createStars()
        createTitle()
        createScoreBoxes()
        createRestartButton()
    }

    private func updateHighScore() {
        let savedHighScore = UserDefaults.standard.integer(forKey: "HighScore")

        if finalScore > savedHighScore {
            highScore = finalScore
            isNewHighScore = true
            UserDefaults.standard.set(finalScore, forKey: "HighScore")
        } else {
            highScore = savedHighScore
            isNewHighScore = false
        }
    }

    private func createStars() {
        for _ in 0..<35 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...2))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.3...0.8)

            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )

            star.zPosition = -1
            addChild(star)
        }
    }

    private func createTitle() {
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "GAME OVER"
        titleLabel.fontSize = 42
        titleLabel.fontColor = .white
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: size.width * 0.28, y: size.height * 0.58)
        titleLabel.zPosition = 10
        addChild(titleLabel)

        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitleLabel.text = isNewHighScore ? "NEW BEST!" : "GRAVITY SHIFT"
        subtitleLabel.fontSize = 24
        subtitleLabel.fontColor = isNewHighScore ? .cyan : .cyan
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.verticalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: size.width * 0.28, y: size.height * 0.40)
        subtitleLabel.zPosition = 10
        addChild(subtitleLabel)
    }

    private func createScoreBoxes() {
        let scoreBoxPosition = CGPoint(x: size.width * 0.63, y: size.height * 0.58)
        let bestBoxPosition = CGPoint(x: size.width * 0.82, y: size.height * 0.58)

        createScoreBox(
            title: "SCORE",
            value: "\(finalScore)",
            position: scoreBoxPosition
        )

        createScoreBox(
            title: "BEST",
            value: "\(highScore)",
            position: bestBoxPosition
        )
    }

    private func createScoreBox(title: String, value: String, position: CGPoint) {
        let box = SKShapeNode(rectOf: CGSize(width: 130, height: 88), cornerRadius: 16)
        box.fillColor = SKColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 0.95)
        box.strokeColor = .cyan
        box.lineWidth = 2
        box.glowWidth = 4
        box.position = position
        box.zPosition = 10
        addChild(box)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        titleLabel.text = title
        titleLabel.fontSize = 15
        titleLabel.fontColor = .gray
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: 22)
        titleLabel.zPosition = 11
        box.addChild(titleLabel)

        let valueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        valueLabel.text = value
        valueLabel.fontSize = 32
        valueLabel.fontColor = .cyan
        valueLabel.horizontalAlignmentMode = .center
        valueLabel.verticalAlignmentMode = .center
        valueLabel.position = CGPoint(x: 0, y: -16)
        valueLabel.zPosition = 11
        box.addChild(valueLabel)
    }

    private func createRestartButton() {
        restartButton = SKShapeNode(rectOf: CGSize(width: 210, height: 58), cornerRadius: 18)
        restartButton.fillColor = .cyan
        restartButton.strokeColor = .white
        restartButton.lineWidth = 3
        restartButton.glowWidth = 6
        restartButton.position = CGPoint(x: size.width * 0.725, y: size.height * 0.30)
        restartButton.zPosition = 10
        addChild(restartButton)

        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text = "REINICIAR"
        restartLabel.fontSize = 24
        restartLabel.fontColor = .black
        restartLabel.verticalAlignmentMode = .center
        restartLabel.horizontalAlignmentMode = .center
        restartLabel.position = CGPoint.zero
        restartLabel.zPosition = 11
        restartButton.addChild(restartLabel)

        let scaleUp = SKAction.scale(to: 1.05, duration: 0.65)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.65)
        restartButton.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        restartButton.removeAllActions()

        let pressDown = SKAction.scale(to: 0.92, duration: 0.08)
        let pressUp = SKAction.scale(to: 1.0, duration: 0.08)
        let restart = SKAction.run { [weak self] in
            guard let self = self else { return }

            let gameScene = GameScene(size: self.size)
            gameScene.scaleMode = .resizeFill

            let transition = SKTransition.fade(withDuration: 0.4)
            self.view?.presentScene(gameScene, transition: transition)
        }

        restartButton.run(SKAction.sequence([pressDown, pressUp, restart]))
    }
}
