import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    private let playerRadius: CGFloat = 18
    private let boundaryThickness: CGFloat = 16

    private var player = SKShapeNode()
    private var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var coinLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    private var score: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var obstacleTimer: TimeInterval = 0

    private var obstacleInterval: TimeInterval = 1.6
    private var obstacleSpeed: CGFloat = 240
    
    private var lastObstacleFromBottom: Bool?
    private var sameSideObstacleCount = 0
    private var maxSameSideObstacles = 2

    private var gravityIsDown = true
    private var gameEnded = false

    private var canInvertGravity = false
    private var surfaceContactCount = 0

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.03, blue: 0.08, alpha: 1)

        view.isMultipleTouchEnabled = false

        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self

        createBackgroundStars()
        createBounds()
        createPlayer()
        createScoreLabel()
        createCoinLabel()
    }

    // MARK: - Background

    private func createBackgroundStars() {
        for _ in 0..<45 {
            createStar(startX: CGFloat.random(in: 0...size.width))
        }

        let spawnStars = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    self?.createStar(startX: nil)
                },
                SKAction.wait(forDuration: 0.14)
            ])
        )

        run(spawnStars, withKey: "stars")
    }

    private func createStar(startX: CGFloat?) {
        let radius = CGFloat.random(in: 1...2)

        let star = SKShapeNode(circleOfRadius: radius)
        star.fillColor = .white
        star.strokeColor = .clear
        star.alpha = CGFloat.random(in: 0.25...0.75)

        let xPosition = startX ?? size.width + 10

        star.position = CGPoint(
            x: xPosition,
            y: CGFloat.random(in: 20...(size.height - 20))
        )

        star.zPosition = -10
        addChild(star)

        let speed = CGFloat.random(in: 70...150)
        let distance = xPosition + 40
        let duration = TimeInterval(distance / speed)

        let move = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let remove = SKAction.removeFromParent()

        star.run(SKAction.sequence([move, remove]))
    }

    // MARK: - Bounds

    private func createBounds() {
        let ground = SKSpriteNode(
            color: SKColor(red: 0.08, green: 0.08, blue: 0.14, alpha: 1),
            size: CGSize(width: size.width, height: boundaryThickness)
        )

        ground.name = "ground"
        ground.position = CGPoint(x: size.width / 2, y: boundaryThickness / 2)
        ground.zPosition = 5

        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.restitution = 0
        ground.physicsBody?.friction = 1
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.player
        ground.physicsBody?.collisionBitMask = PhysicsCategory.player

        addChild(ground)

        let ceiling = SKSpriteNode(
            color: SKColor(red: 0.08, green: 0.08, blue: 0.14, alpha: 1),
            size: CGSize(width: size.width, height: boundaryThickness)
        )

        ceiling.name = "ceiling"
        ceiling.position = CGPoint(x: size.width / 2, y: size.height - boundaryThickness / 2)
        ceiling.zPosition = 5

        ceiling.physicsBody = SKPhysicsBody(rectangleOf: ceiling.size)
        ceiling.physicsBody?.isDynamic = false
        ceiling.physicsBody?.restitution = 0
        ceiling.physicsBody?.friction = 1
        ceiling.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ceiling.physicsBody?.contactTestBitMask = PhysicsCategory.player
        ceiling.physicsBody?.collisionBitMask = PhysicsCategory.player

        addChild(ceiling)
    }

    // MARK: - Player

    private func createPlayer() {
        player = SKShapeNode(circleOfRadius: playerRadius)

        let selectedSkin = PlayerSkinStore.shared.selectedSkin

        player.fillColor = selectedSkin.fillColor
        player.strokeColor = selectedSkin.strokeColor
        player.lineWidth = 4
        player.glowWidth = 8
        player.zPosition = 20

        player.position = CGPoint(x: size.width * 0.25, y: size.height / 2)

        player.physicsBody = SKPhysicsBody(circleOfRadius: playerRadius)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false

        player.physicsBody?.restitution = 0
        player.physicsBody?.friction = 1
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.angularDamping = 1
        player.physicsBody?.usesPreciseCollisionDetection = true

        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle | PhysicsCategory.coin
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle

        addChild(player)
    }

    // MARK: - UI

    private func createScoreLabel() {
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .cyan
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 60)
        scoreLabel.zPosition = 50
        addChild(scoreLabel)
    }

    private func createCoinLabel() {
        coinLabel.text = "Coins: \(Coins.shared.balance)"
        coinLabel.fontSize = 20
        coinLabel.fontColor = .yellow
        coinLabel.horizontalAlignmentMode = .left
        coinLabel.position = CGPoint(x: 24, y: size.height - 60)
        coinLabel.zPosition = 50
        addChild(coinLabel)
    }

    private func updateCoinLabel() {
        coinLabel.text = "Coins: \(Coins.shared.balance)"
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameEnded { return }

        guard canInvertGravity else {
            invalidTapFeedback()
            return
        }

        invertGravity()
    }

    private func invertGravity() {
        canInvertGravity = false
        surfaceContactCount = 0

        gravityIsDown.toggle()

        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

        if gravityIsDown {
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -10))
        } else {
            physicsWorld.gravity = CGVector(dx: 0, dy: 9.8)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        }

        let rotateAction = SKAction.rotate(byAngle: .pi, duration: 0.15)
        player.run(rotateAction)
    }

    private func invalidTapFeedback() {
        let fadeOut = SKAction.fadeAlpha(to: 0.45, duration: 0.05)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.08)
        player.run(SKAction.sequence([fadeOut, fadeIn]))
    }

    // MARK: - Update

    override func update(_ currentTime: TimeInterval) {
        if gameEnded { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let deltaTime = min(currentTime - lastUpdateTime, 0.05)
        lastUpdateTime = currentTime

        score += deltaTime
        scoreLabel.text = "Score: \(Int(score))"

        obstacleTimer += deltaTime

        let currentInterval = max(0.60, obstacleInterval - score / 35)

        if obstacleTimer >= currentInterval {
            spawnObstacle()
            obstacleTimer = 0
        }

        obstacleSpeed = min(480, 240 + CGFloat(score) * 5)

        if canInvertGravity {
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            snapPlayerToSurface()
        }
    }

    // MARK: - Obstacles

    private func spawnObstacle() {
        let obstacleWidth: CGFloat = CGFloat.random(in: 40...70)
        let obstacleHeight: CGFloat = CGFloat.random(in: 80...160)

        let obstacle = SKSpriteNode(
            color: SKColor(red: 0.95, green: 0.12, blue: 0.35, alpha: 1),
            size: CGSize(width: obstacleWidth, height: obstacleHeight)
        )

        let spawnFromBottom = chooseObstacleSide()

        if spawnFromBottom {
            obstacle.position = CGPoint(
                x: size.width + obstacleWidth / 2,
                y: boundaryThickness + obstacleHeight / 2
            )
        } else {
            obstacle.position = CGPoint(
                x: size.width + obstacleWidth / 2,
                y: size.height - boundaryThickness - obstacleHeight / 2
            )
        }

        obstacle.name = "obstacle"
        obstacle.zPosition = 15

        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.restitution = 0
        obstacle.physicsBody?.friction = 1
        obstacle.physicsBody?.usesPreciseCollisionDetection = true

        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.player

        addChild(obstacle)

        if Int.random(in: 1...100) <= 45 {
            spawnCoin(
                oppositeToBottomObstacle: spawnFromBottom,
                afterObstacleWidth: obstacleWidth
            )
        }

        let distance = size.width + obstacleWidth + 100
        let duration = TimeInterval(distance / obstacleSpeed)

        let moveAction = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let removeAction = SKAction.removeFromParent()

        obstacle.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    private func chooseObstacleSide() -> Bool {
        let chosenSide: Bool

        if let lastSide = lastObstacleFromBottom {
            if sameSideObstacleCount >= maxSameSideObstacles {
                chosenSide = !lastSide
            } else if score > 8 && Int.random(in: 1...100) <= 65 {
                chosenSide = !lastSide
            } else {
                chosenSide = Bool.random()
            }

            if chosenSide == lastSide {
                sameSideObstacleCount += 1
            } else {
                sameSideObstacleCount = 1
            }
        } else {
            chosenSide = Bool.random()
            sameSideObstacleCount = 1
        }

        lastObstacleFromBottom = chosenSide
        return chosenSide
    }

    // MARK: - Coins

    private func spawnCoin(oppositeToBottomObstacle obstacleFromBottom: Bool, afterObstacleWidth obstacleWidth: CGFloat) {
        let coinRadius: CGFloat = 10

        let coin = SKShapeNode(circleOfRadius: coinRadius)
        coin.name = "coin"
        coin.fillColor = .yellow
        coin.zPosition = 18

        let coinFromBottom = !obstacleFromBottom

        let coinY: CGFloat

        if coinFromBottom {
            coinY = boundaryThickness + playerRadius
        } else {
            coinY = size.height - boundaryThickness - playerRadius
        }

        coin.position = CGPoint(
            x: size.width + obstacleWidth + 170,
            y: coinY
        )

        coin.physicsBody = SKPhysicsBody(circleOfRadius: coinRadius)
        coin.physicsBody?.isDynamic = false
        coin.physicsBody?.categoryBitMask = PhysicsCategory.coin
        coin.physicsBody?.contactTestBitMask = PhysicsCategory.player
        coin.physicsBody?.collisionBitMask = PhysicsCategory.none

        addChild(coin)

        let distance = size.width + obstacleWidth + 230
        let duration = TimeInterval(distance / obstacleSpeed)

        let move = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let remove = SKAction.removeFromParent()

        coin.run(SKAction.sequence([move, remove]))
    }

    private func collectCoin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        let coinNode: SKNode?

        if bodyA.categoryBitMask == PhysicsCategory.coin {
            coinNode = bodyA.node
        } else if bodyB.categoryBitMask == PhysicsCategory.coin {
            coinNode = bodyB.node
        } else {
            coinNode = nil
        }

        guard let coin = coinNode else { return }

        let coinPosition = coin.position

        coin.physicsBody = nil
        coin.removeFromParent()

        Coins.shared.add(amount: 1)
        updateCoinLabel()

        showCoinCollectEffect(at: coinPosition)
    }

    private func showCoinCollectEffect(at position: CGPoint) {
        let text = SKLabelNode(fontNamed: "AvenirNext-Bold")
        text.text = "+1"
        text.fontSize = 18
        text.fontColor = .yellow
        text.position = position
        text.zPosition = 80
        addChild(text)

        let moveUp = SKAction.moveBy(x: 0, y: 28, duration: 0.35)
        let fade = SKAction.fadeOut(withDuration: 0.35)
        let remove = SKAction.removeFromParent()

        text.run(SKAction.sequence([
            SKAction.group([moveUp, fade]),
            remove
        ]))
    }

    // MARK: - Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == (PhysicsCategory.player | PhysicsCategory.coin) {
            collectCoin(contact)
            return
        }

        if collision == (PhysicsCategory.player | PhysicsCategory.obstacle) {
            handleObstacleCollision(contact)
            return
        }

        if collision == (PhysicsCategory.player | PhysicsCategory.ground) {
            surfaceContactCount += 1
            canInvertGravity = true

            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            snapPlayerToSurface()
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == (PhysicsCategory.player | PhysicsCategory.ground) {
            surfaceContactCount = max(0, surfaceContactCount - 1)

            if surfaceContactCount == 0 {
                canInvertGravity = false
            }
        }
    }

    private func handleObstacleCollision(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        let obstacleNode: SKNode?

        if bodyA.categoryBitMask == PhysicsCategory.obstacle {
            obstacleNode = bodyA.node
        } else if bodyB.categoryBitMask == PhysicsCategory.obstacle {
            obstacleNode = bodyB.node
        } else {
            obstacleNode = nil
        }

        if let obstacle = obstacleNode {
            player.position.x = obstacle.frame.minX - playerRadius - 2
        }

        endGame()
    }

    private func snapPlayerToSurface() {
        if gravityIsDown {
            player.position.y = boundaryThickness + playerRadius
        } else {
            player.position.y = size.height - boundaryThickness - playerRadius
        }
    }

    // MARK: - Game Over

    private func endGame() {
        if gameEnded { return }

        gameEnded = true
        canInvertGravity = false

        physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.affectedByGravity = false
        player.removeAllActions()

        enumerateChildNodes(withName: "obstacle") { node, _ in
            node.removeAllActions()
            node.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }

        enumerateChildNodes(withName: "coin") { node, _ in
            node.removeAllActions()
            node.physicsBody = nil
        }

        flashScreen()

        let wait = SKAction.wait(forDuration: 0.35)
        let goToGameOver = SKAction.run { [weak self] in
            guard let self = self else { return }

            let gameOverScene = GameOverScene(size: self.size, finalScore: Int(self.score))
            gameOverScene.scaleMode = .resizeFill

            let transition = SKTransition.fade(withDuration: 0.4)
            self.view?.presentScene(gameOverScene, transition: transition)
        }

        run(SKAction.sequence([wait, goToGameOver]))
    }

    private func flashScreen() {
        let flash = SKSpriteNode(
            color: SKColor(red: 0.95, green: 0.12, blue: 0.35, alpha: 1),
            size: size
        )

        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.alpha = 0
        flash.zPosition = 200

        addChild(flash)

        let fadeIn = SKAction.fadeAlpha(to: 0.30, duration: 0.06)
        let fadeOut = SKAction.fadeOut(withDuration: 0.20)
        let remove = SKAction.removeFromParent()

        flash.run(SKAction.sequence([fadeIn, fadeOut, remove]))
    }
}
