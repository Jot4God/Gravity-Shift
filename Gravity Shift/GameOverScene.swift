import SpriteKit

class GameOverScene: SKScene {

    private let finalScore: Int

    private var restartButton = SKShapeNode()
    private var menuButton = SKShapeNode()

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
        createScores()
        createRestartButton()
        createMenuButton()
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
        titleLabel.fontSize = 43
        titleLabel.fontColor = .white
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: size.width * 0.28, y: size.height * 0.58)
        titleLabel.zPosition = 10
        addChild(titleLabel)

        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        subtitleLabel.text = isNewHighScore ? "NEW BEST!" : "GRAVITY SHIFT"
        subtitleLabel.fontSize = 24
        subtitleLabel.fontColor = .cyan
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.verticalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: size.width * 0.28, y: size.height * 0.40)
        subtitleLabel.zPosition = 10
        addChild(subtitleLabel)
    }

    private func createScores() {
        createScoreText(
            title: "SCORE",
            value: "\(finalScore)",
            valueColor: .cyan,
            position: CGPoint(x: size.width * 0.62, y: size.height * 0.61)
        )

        createScoreText(
            title: "BEST",
            value: "\(highScore)",
            valueColor: .yellow,
            position: CGPoint(x: size.width * 0.82, y: size.height * 0.61)
        )
    }

    private func createScoreText(title: String, value: String, valueColor: SKColor, position: CGPoint) {
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        titleLabel.text = title
        titleLabel.fontSize = 16
        titleLabel.fontColor = .gray
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: position.x, y: position.y + 36)
        titleLabel.zPosition = 10
        addChild(titleLabel)

        let valueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        valueLabel.text = value
        valueLabel.fontSize = 40
        valueLabel.fontColor = valueColor
        valueLabel.horizontalAlignmentMode = .center
        valueLabel.verticalAlignmentMode = .center
        valueLabel.position = position
        valueLabel.zPosition = 10
        addChild(valueLabel)
    }

    private func createRestartButton() {
        restartButton = createButton(
            text: "REINICIAR",
            position: CGPoint(x: size.width * 0.62, y: size.height * 0.31),
            fillColor: .cyan,
            strokeColor: .white,
            textColor: .black,
            name: "restartButton"
        )

        addChild(restartButton)
        addPulse(to: restartButton)
    }

    private func createMenuButton() {
        menuButton = createButton(
            text: "MENU",
            position: CGPoint(x: size.width * 0.82, y: size.height * 0.31),
            fillColor: SKColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 0.95),
            strokeColor: .cyan,
            textColor: .cyan,
            name: "menuButton"
        )

        addChild(menuButton)
        addPulse(to: menuButton)
    }

    private func createButton(
        text: String,
        position: CGPoint,
        fillColor: SKColor,
        strokeColor: SKColor,
        textColor: SKColor,
        name: String
    ) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: 160, height: 54), cornerRadius: 16)
        button.name = name
        button.fillColor = fillColor
        button.strokeColor = strokeColor
        button.lineWidth = 3
        button.glowWidth = 6
        button.position = position
        button.zPosition = 10

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 20
        label.fontColor = textColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint.zero
        label.zPosition = 11
        button.addChild(label)

        return button
    }

    private func addPulse(to button: SKShapeNode) {
        let scaleUp = SKAction.scale(to: 1.04, duration: 0.65)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.65)
        button.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)

        if restartButton.contains(location) {
            restartGame()
        } else if menuButton.contains(location) {
            goToMenu()
        }
    }

    private func restartGame() {
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

    private func goToMenu() {
        menuButton.removeAllActions()

        let pressDown = SKAction.scale(to: 0.92, duration: 0.08)
        let pressUp = SKAction.scale(to: 1.0, duration: 0.08)
        let menu = SKAction.run { [weak self] in
            guard let self = self else { return }

            let menuScene = MenuScene(size: self.size)
            menuScene.scaleMode = .resizeFill

            let transition = SKTransition.fade(withDuration: 0.4)
            self.view?.presentScene(menuScene, transition: transition)
        }

        menuButton.run(SKAction.sequence([pressDown, pressUp, menu]))
    }
}
