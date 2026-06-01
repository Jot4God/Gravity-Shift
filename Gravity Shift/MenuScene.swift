import SpriteKit

class MenuScene: SKScene {

    private var startButton = SKShapeNode()
    private var playerButton = SKShapeNode()

    private var coinsValueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var shopPanel: SKNode?

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.03, blue: 0.08, alpha: 1)

        createBackgroundStars()
        createTitle()
        createStats()
        createStartButton()
        createPlayerButton()
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
        gravityLabel.fontSize = 52
        gravityLabel.fontColor = .white
        gravityLabel.horizontalAlignmentMode = .center
        gravityLabel.verticalAlignmentMode = .center
        gravityLabel.position = CGPoint(x: size.width * 0.28, y: size.height * 0.60)
        gravityLabel.zPosition = 10
        addChild(gravityLabel)

        let shiftLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shiftLabel.text = "SHIFT"
        shiftLabel.fontSize = 52
        shiftLabel.fontColor = .cyan
        shiftLabel.horizontalAlignmentMode = .center
        shiftLabel.verticalAlignmentMode = .center
        shiftLabel.position = CGPoint(x: size.width * 0.28, y: size.height * 0.41)
        shiftLabel.zPosition = 10
        addChild(shiftLabel)

        let moveUp = SKAction.moveBy(x: 0, y: 5, duration: 0.8)
        let moveDown = SKAction.moveBy(x: 0, y: -5, duration: 0.8)
        let floating = SKAction.repeatForever(SKAction.sequence([moveUp, moveDown]))

        gravityLabel.run(floating)
        shiftLabel.run(floating)
    }

    private func createStats() {
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")

        let bestTitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        bestTitle.text = "BEST"
        bestTitle.fontSize = 15
        bestTitle.fontColor = .gray
        bestTitle.horizontalAlignmentMode = .center
        bestTitle.verticalAlignmentMode = .center
        bestTitle.position = CGPoint(x: size.width * 0.62, y: size.height * 0.72)
        bestTitle.zPosition = 10
        addChild(bestTitle)

        let bestValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        bestValue.text = "\(highScore)"
        bestValue.fontSize = 34
        bestValue.fontColor = .cyan
        bestValue.horizontalAlignmentMode = .center
        bestValue.verticalAlignmentMode = .center
        bestValue.position = CGPoint(x: size.width * 0.62, y: size.height * 0.62)
        bestValue.zPosition = 10
        addChild(bestValue)

        let coinsTitle = SKLabelNode(fontNamed: "AvenirNext-Regular")
        coinsTitle.text = "COINS"
        coinsTitle.fontSize = 15
        coinsTitle.fontColor = .gray
        coinsTitle.horizontalAlignmentMode = .center
        coinsTitle.verticalAlignmentMode = .center
        coinsTitle.position = CGPoint(x: size.width * 0.82, y: size.height * 0.72)
        coinsTitle.zPosition = 10
        addChild(coinsTitle)

        coinsValueLabel.text = "\(Coins.shared.balance)"
        coinsValueLabel.fontSize = 34
        coinsValueLabel.fontColor = .yellow
        coinsValueLabel.horizontalAlignmentMode = .center
        coinsValueLabel.verticalAlignmentMode = .center
        coinsValueLabel.position = CGPoint(x: size.width * 0.82, y: size.height * 0.62)
        coinsValueLabel.zPosition = 10
        addChild(coinsValueLabel)
    }

    private func createStartButton() {
        startButton = createMenuButton(
            text: "JOGAR",
            position: CGPoint(x: size.width * 0.62, y: size.height * 0.34),
            fillColor: .cyan,
            strokeColor: .white,
            textColor: .black,
            name: "startButton"
        )

        addChild(startButton)
        addPulse(to: startButton)
    }

    private func createPlayerButton() {
        playerButton = createMenuButton(
            text: "PLAYER",
            position: CGPoint(x: size.width * 0.82, y: size.height * 0.34),
            fillColor: SKColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 0.95),
            strokeColor: .cyan,
            textColor: .cyan,
            name: "playerButton"
        )

        addChild(playerButton)
        addPulse(to: playerButton)
    }

    private func createMenuButton(
        text: String,
        position: CGPoint,
        fillColor: SKColor,
        strokeColor: SKColor,
        textColor: SKColor,
        name: String
    ) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: 150, height: 58), cornerRadius: 18)
        button.name = name
        button.fillColor = fillColor
        button.strokeColor = strokeColor
        button.lineWidth = 3
        button.glowWidth = 6
        button.position = position
        button.zPosition = 10

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 21
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

    private func startGame() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = .resizeFill

        let transition = SKTransition.fade(withDuration: 0.5)
        view?.presentScene(gameScene, transition: transition)
    }

    // MARK: - Player Shop

    private func openPlayerShop() {
        if shopPanel != nil { return }

        let container = SKNode()
        container.zPosition = 100
        shopPanel = container
        addChild(container)

        let overlay = SKSpriteNode(
            color: SKColor.black.withAlphaComponent(0.68),
            size: size
        )
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 100
        container.addChild(overlay)

        let panel = SKShapeNode(
            rectOf: CGSize(width: size.width * 0.78, height: size.height * 0.78),
            cornerRadius: 22
        )
        panel.fillColor = SKColor(red: 0.04, green: 0.04, blue: 0.10, alpha: 1)
        panel.strokeColor = .cyan
        panel.lineWidth = 3
        panel.glowWidth = 5
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        panel.zPosition = 101
        container.addChild(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "PLAYERS"
        title.fontSize = 30
        title.fontColor = .white
        title.verticalAlignmentMode = .center
        title.horizontalAlignmentMode = .center
        title.position = CGPoint(x: 0, y: size.height * 0.25)
        title.zPosition = 102
        panel.addChild(title)

        let coinsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        coinsLabel.text = "COINS: \(Coins.shared.balance)"
        coinsLabel.fontSize = 18
        coinsLabel.fontColor = .yellow
        coinsLabel.verticalAlignmentMode = .center
        coinsLabel.horizontalAlignmentMode = .center
        coinsLabel.position = CGPoint(x: 0, y: size.height * 0.16)
        coinsLabel.zPosition = 102
        panel.addChild(coinsLabel)

        let closeButton = SKShapeNode(rectOf: CGSize(width: 62, height: 36), cornerRadius: 12)
        closeButton.name = "closeShop"
        closeButton.fillColor = SKColor(red: 0.95, green: 0.12, blue: 0.35, alpha: 1)
        closeButton.strokeColor = .white
        closeButton.lineWidth = 2
        closeButton.position = CGPoint(x: size.width * 0.34, y: size.height * 0.25)
        closeButton.zPosition = 102
        panel.addChild(closeButton)

        let closeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        closeLabel.text = "X"
        closeLabel.fontSize = 20
        closeLabel.fontColor = .white
        closeLabel.verticalAlignmentMode = .center
        closeLabel.horizontalAlignmentMode = .center
        closeLabel.position = CGPoint.zero
        closeButton.addChild(closeLabel)

        createSkinOption(for: .cyan, x: -size.width * 0.22, parent: panel)
        createSkinOption(for: .purple, x: 0, parent: panel)
        createSkinOption(for: .gold, x: size.width * 0.22, parent: panel)
    }

    private func createSkinOption(for skin: PlayerSkin, x: CGFloat, parent: SKNode) {
        let selectedSkin = PlayerSkinStore.shared.selectedSkin
        let unlocked = PlayerSkinStore.shared.isUnlocked(skin)

        let tapArea = SKShapeNode(rectOf: CGSize(width: 135, height: 125), cornerRadius: 20)
        tapArea.name = "skin_\(skin.rawValue)"
        tapArea.fillColor = SKColor.white.withAlphaComponent(0.001)
        tapArea.strokeColor = .clear
        tapArea.lineWidth = 0
        tapArea.position = CGPoint(x: x, y: -size.height * 0.05)
        tapArea.zPosition = 102
        parent.addChild(tapArea)

        if selectedSkin == skin {
            let selectedRing = SKShapeNode(circleOfRadius: 30)
            selectedRing.strokeColor = .yellow
            selectedRing.lineWidth = 4
            selectedRing.glowWidth = 7
            selectedRing.fillColor = .clear
            selectedRing.position = CGPoint(x: 0, y: 34)
            selectedRing.zPosition = 103
            tapArea.addChild(selectedRing)
        }

        let preview = SKShapeNode(circleOfRadius: 20)
        preview.fillColor = skin.fillColor
        preview.strokeColor = skin.strokeColor
        preview.lineWidth = 4
        preview.glowWidth = 8
        preview.position = CGPoint(x: 0, y: 34)
        preview.zPosition = 104
        tapArea.addChild(preview)

        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = skin.name
        nameLabel.fontSize = 15
        nameLabel.fontColor = .white
        nameLabel.verticalAlignmentMode = .center
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.position = CGPoint(x: 0, y: -10)
        nameLabel.zPosition = 104
        tapArea.addChild(nameLabel)

        let stateLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

        if selectedSkin == skin {
            stateLabel.text = "EQUIPPED"
            stateLabel.fontColor = .yellow
        } else if unlocked {
            stateLabel.text = "USE"
            stateLabel.fontColor = .cyan
        } else {
            stateLabel.text = "\(skin.price) COINS"
            stateLabel.fontColor = .yellow
        }

        stateLabel.fontSize = 12
        stateLabel.verticalAlignmentMode = .center
        stateLabel.horizontalAlignmentMode = .center
        stateLabel.position = CGPoint(x: 0, y: -43)
        stateLabel.zPosition = 104
        tapArea.addChild(stateLabel)
    }

    private func closePlayerShop() {
        shopPanel?.removeFromParent()
        shopPanel = nil
    }

    private func handleSkinTap(_ skin: PlayerSkin) {
        if PlayerSkinStore.shared.isUnlocked(skin) {
            PlayerSkinStore.shared.select(skin)
        } else {
            _ = PlayerSkinStore.shared.buy(skin)
        }

        coinsValueLabel.text = "\(Coins.shared.balance)"

        closePlayerShop()
        openPlayerShop()
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        guard let touchedName = getActionName(from: touchedNode) else { return }

        if shopPanel != nil {
            if touchedName == "closeShop" {
                closePlayerShop()
                return
            }

            if touchedName.hasPrefix("skin_") {
                let rawValue = touchedName.replacingOccurrences(of: "skin_", with: "")

                if let skin = PlayerSkin(rawValue: rawValue) {
                    handleSkinTap(skin)
                }

                return
            }

            return
        }

        if touchedName == "startButton" {
            startButton.removeAllActions()

            let pressDown = SKAction.scale(to: 0.92, duration: 0.08)
            let pressUp = SKAction.scale(to: 1.0, duration: 0.08)
            let start = SKAction.run { [weak self] in
                self?.startGame()
            }

            startButton.run(SKAction.sequence([pressDown, pressUp, start]))
        }

        if touchedName == "playerButton" {
            openPlayerShop()
        }
    }

    private func getActionName(from node: SKNode) -> String? {
        var currentNode: SKNode? = node

        while currentNode != nil {
            if let name = currentNode?.name {
                return name
            }

            currentNode = currentNode?.parent
        }

        return nil
    }
}
