import SpriteKit

// Cena principal do jogo onde a ação acontece.
// Herda de SKScene e adota o protocolo SKPhysicsContactDelegate para detetar colisões (ex: jogador bateu num obstáculo).
class GameScene: SKScene, SKPhysicsContactDelegate {

    // Constantes de tamanho para o jogador e os limites do ecrã
    private let playerRadius: CGFloat = 18
    private let boundaryThickness: CGFloat = 16

    // Elementos visuais principais
    private var player = SKShapeNode()
    private var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private var coinLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    // Variáveis para controlar a pontuação e o tempo
    private var score: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var obstacleTimer: TimeInterval = 0

    // Variáveis que definem a dificuldade (velocidade e frequência dos obstáculos)
    private var obstacleInterval: TimeInterval = 1.6
    private var obstacleSpeed: CGFloat = 240
    
    // Controlo de lógica para evitar que os obstáculos apareçam sempre do mesmo lado
    private var lastObstacleFromBottom: Bool?
    private var sameSideObstacleCount = 0
    private var maxSameSideObstacles = 2

    // Estado do jogador e do jogo
    private var gravityIsDown = true
    private var gameEnded = false

    // Controla se o jogador pode mudar a gravidade (só pode se estiver a tocar no chão/teto)
    private var canInvertGravity = false
    private var surfaceContactCount = 0

    // Método chamado automaticamente quando a cena é apresentada.
    // Configura o mundo físico, a gravidade e constrói todos os elementos iniciais.
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.03, blue: 0.08, alpha: 1)

        // Desativa múltiplos toques em simultâneo para evitar bugs de gravidade
        view.isMultipleTouchEnabled = false

        // Define a gravidade inicial a puxar para baixo
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        // Define esta cena como a delegada para gerir colisões físicas
        physicsWorld.contactDelegate = self

        createBackgroundStars()
        createBounds()
        createPlayer()
        createScoreLabel()
        createCoinLabel()
    }

    // MARK: - Background

    // Cria o efeito de estrelas a passar de fundo em loop (paralaxe)
    private func createBackgroundStars() {
        // Preenche o ecrã com estrelas iniciais
        for _ in 0..<45 {
            createStar(startX: CGFloat.random(in: 0...size.width))
        }

        // Cria uma ação repetitiva que gera uma nova estrela a cada 0.14 segundos
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

    // Instancia uma estrela individual, dá-lhe uma velocidade aleatória e move-a para a esquerda
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

    // Cria as barras superior (teto) e inferior (chão) que impedem o jogador de sair do ecrã
    private func createBounds() {
        // --- CHÃO ---
        let ground = SKSpriteNode(
            color: SKColor(red: 0.08, green: 0.08, blue: 0.14, alpha: 1),
            size: CGSize(width: size.width, height: boundaryThickness)
        )

        ground.name = "ground"
        ground.position = CGPoint(x: size.width / 2, y: boundaryThickness / 2)
        ground.zPosition = 5

        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false // Estático, não se move com impactos
        ground.physicsBody?.restitution = 0 // Sem ressalto
        ground.physicsBody?.friction = 1
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.player
        ground.physicsBody?.collisionBitMask = PhysicsCategory.player

        addChild(ground)

        // --- TETO ---
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

    // Instancia o nó do jogador, aplica a skin escolhida na loja e configura o seu corpo físico
    private func createPlayer() {
        player = SKShapeNode(circleOfRadius: playerRadius)

        let selectedSkin = PlayerSkinStore.shared.selectedSkin

        player.fillColor = selectedSkin.fillColor
        player.strokeColor = selectedSkin.strokeColor
        player.lineWidth = 4
        player.glowWidth = 8
        player.zPosition = 20

        player.position = CGPoint(x: size.width * 0.25, y: size.height / 2)

        // Configuração da física do jogador
        player.physicsBody = SKPhysicsBody(circleOfRadius: playerRadius)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false // Mantém o jogador direito

        player.physicsBody?.restitution = 0 // Não salta quando bate no chão
        player.physicsBody?.friction = 1
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.angularDamping = 1
        player.physicsBody?.usesPreciseCollisionDetection = true // Evita que atravesse paredes a altas velocidades

        // Máscaras de colisão (define com o que é que o jogador interage)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle | PhysicsCategory.coin
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.obstacle

        addChild(player)
    }

    // MARK: - UI

    // Configura o texto da pontuação no topo do ecrã
    private func createScoreLabel() {
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .cyan
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 60)
        scoreLabel.zPosition = 50
        addChild(scoreLabel)
    }

    // Configura o texto das moedas no canto superior esquerdo
    private func createCoinLabel() {
        coinLabel.text = "Coins: \(Coins.shared.balance)"
        coinLabel.fontSize = 20
        coinLabel.fontColor = .yellow
        coinLabel.horizontalAlignmentMode = .left
        coinLabel.position = CGPoint(x: 24, y: size.height - 60)
        coinLabel.zPosition = 50
        addChild(coinLabel)
    }

    // Atualiza o texto das moedas sempre que uma é apanhada
    private func updateCoinLabel() {
        coinLabel.text = "Coins: \(Coins.shared.balance)"
    }

    // MARK: - Input

    // Deteta toques no ecrã. Se o jogo não acabou e o jogador puder mudar a gravidade, inverte-a.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameEnded { return }

        guard canInvertGravity else {
            invalidTapFeedback()
            return
        }

        invertGravity()
    }

    // Lógica para inverter a gravidade (fazer a "queda" do jogador mudar de sentido)
    private func invertGravity() {
        canInvertGravity = false
        surfaceContactCount = 0

        gravityIsDown.toggle() // Inverte o booleano (true vira false, e vice-versa)

        // Reseta a velocidade atual para que a inversão seja imediata e brusca
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

        // Muda a gravidade do mundo e aplica um pequeno impulso para ajudar o jogador a descolar da parede
        if gravityIsDown {
            physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -10))
        } else {
            physicsWorld.gravity = CGVector(dx: 0, dy: 9.8)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
        }

        // Animação visual de rotação para dar "feeling" ao movimento
        let rotateAction = SKAction.rotate(byAngle: .pi, duration: 0.15)
        player.run(rotateAction)
    }

    // Efeito visual (piscar rápido) se o jogador tentar mudar a gravidade a meio do ar sem estar a tocar em nada
    private func invalidTapFeedback() {
        let fadeOut = SKAction.fadeAlpha(to: 0.45, duration: 0.05)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.08)
        player.run(SKAction.sequence([fadeOut, fadeIn]))
    }

    // MARK: - Update

    // O "Game Loop": Esta função é chamada automaticamente a cada frame (idealmente 60 vezes por segundo).
    // Atualiza pontuação, dificuldade e gere o spawn de obstáculos.
    override func update(_ currentTime: TimeInterval) {
        if gameEnded { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        // Calcula o tempo que passou desde o último frame
        let deltaTime = min(currentTime - lastUpdateTime, 0.05)
        lastUpdateTime = currentTime

        // Aumenta a pontuação consoante o tempo que o jogador sobrevive
        score += deltaTime
        scoreLabel.text = "Score: \(Int(score))"

        obstacleTimer += deltaTime

        // Aumenta a dificuldade do jogo reduzindo o intervalo entre obstáculos, mas fixa um limite mínimo de 0.60s
        let currentInterval = max(0.60, obstacleInterval - score / 35)

        // Se o tempo chegou ao intervalo necessário, cria um obstáculo
        if obstacleTimer >= currentInterval {
            spawnObstacle()
            obstacleTimer = 0
        }

        // Aumenta gradualmente a velocidade dos obstáculos consoante a pontuação
        obstacleSpeed = min(480, 240 + CGFloat(score) * 5)

        // Força a colagem do jogador ao chão/teto quando já aterrou, para evitar que a física o faça deslizar/tremer
        if canInvertGravity {
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            snapPlayerToSurface()
        }
    }

    // MARK: - Obstacles

    // Cria um bloco vermelho mortal e fá-lo mover-se da direita para a esquerda
    private func spawnObstacle() {
        let obstacleWidth: CGFloat = CGFloat.random(in: 40...70)
        let obstacleHeight: CGFloat = CGFloat.random(in: 80...160)

        let obstacle = SKSpriteNode(
            color: SKColor(red: 0.95, green: 0.12, blue: 0.35, alpha: 1),
            size: CGSize(width: obstacleWidth, height: obstacleHeight)
        )

        let spawnFromBottom = chooseObstacleSide()

        // Posiciona o obstáculo no chão ou no teto, baseado na lógica
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

        // Configuração física do obstáculo (estático, mas interage com o jogador)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.restitution = 0
        obstacle.physicsBody?.friction = 1
        obstacle.physicsBody?.usesPreciseCollisionDetection = true

        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.player

        addChild(obstacle)

        // 45% de chance de spawnar também uma moeda logo a seguir ao obstáculo
        if Int.random(in: 1...100) <= 45 {
            spawnCoin(
                oppositeToBottomObstacle: spawnFromBottom,
                afterObstacleWidth: obstacleWidth
            )
        }

        // Calcula a distância que o obstáculo tem de percorrer para sair do ecrã e ser apagado
        let distance = size.width + obstacleWidth + 100
        let duration = TimeInterval(distance / obstacleSpeed)

        let moveAction = SKAction.moveBy(x: -distance, y: 0, duration: duration)
        let removeAction = SKAction.removeFromParent()

        obstacle.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    // Lógica inteligente para escolher o lado onde o obstáculo aparece.
    // Garante que o jogo não é injusto lançando demasiados obstáculos seguidos do mesmo lado.
    private func chooseObstacleSide() -> Bool {
        let chosenSide: Bool

        if let lastSide = lastObstacleFromBottom {
            if sameSideObstacleCount >= maxSameSideObstacles {
                chosenSide = !lastSide // Força a mudança de lado
            } else if score > 8 && Int.random(in: 1...100) <= 65 {
                chosenSide = !lastSide // Dá preferência a mudar de lado frequentemente (mais dinâmico)
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

    // Gera uma moeda e anima-a da direita para a esquerda, no lado oposto ao obstáculo gerado
    private func spawnCoin(oppositeToBottomObstacle obstacleFromBottom: Bool, afterObstacleWidth obstacleWidth: CGFloat) {
        let coinRadius: CGFloat = 10

        let coin = SKShapeNode(circleOfRadius: coinRadius)
        coin.name = "coin"
        coin.fillColor = .yellow
        coin.zPosition = 18

        let coinFromBottom = !obstacleFromBottom

        let coinY: CGFloat

        // Define se a moeda vai estar encostada em cima ou em baixo
        if coinFromBottom {
            coinY = boundaryThickness + playerRadius
        } else {
            coinY = size.height - boundaryThickness - playerRadius
        }

        coin.position = CGPoint(
            x: size.width + obstacleWidth + 170, // Espaço extra para o jogador conseguir reagir
            y: coinY
        )

        // Configuração física da moeda (é "atravessável", não empurra o jogador)
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

    // Função chamada quando a física deteta uma colisão entre o jogador e a moeda
    private func collectCoin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        // Descobre qual dos dois corpos colididos é a moeda
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

        // Remove a física e o nó do ecrã imediatamente
        coin.physicsBody = nil
        coin.removeFromParent()

        // Atualiza a loja e a UI
        Coins.shared.add(amount: 1)
        updateCoinLabel()

        showCoinCollectEffect(at: coinPosition)
    }

    // Mostra um pequeno texto "+1" amarelo que sobe e desaparece no local onde a moeda estava
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

    // Função delegada disparada SEMPRE que dois objetos físicos (com contactTestBitMask definido) começam a tocar-se
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Jogador tocou numa moeda
        if collision == (PhysicsCategory.player | PhysicsCategory.coin) {
            collectCoin(contact)
            return
        }

        // Jogador tocou num obstáculo (GAME OVER)
        if collision == (PhysicsCategory.player | PhysicsCategory.obstacle) {
            handleObstacleCollision(contact)
            return
        }

        // Jogador tocou no chão ou no teto (Pode inverte gravidade novamente)
        if collision == (PhysicsCategory.player | PhysicsCategory.ground) {
            surfaceContactCount += 1
            canInvertGravity = true

            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            snapPlayerToSurface()
        }
    }

    // Função delegada disparada quando dois objetos deixam de se tocar
    func didEnd(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        // Se o jogador descolou do chão/teto, deixa de poder mudar a gravidade
        if collision == (PhysicsCategory.player | PhysicsCategory.ground) {
            surfaceContactCount = max(0, surfaceContactCount - 1)

            if surfaceContactCount == 0 {
                canInvertGravity = false
            }
        }
    }

    // Processa a colisão mortal. Prende o jogador ao lado esquerdo do bloco para parecer que bateu contra ele
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

    // Força a posição Y do jogador a ficar perfeitamente alinhada com a superfície.
    // Evita um bug visual do SpriteKit onde o jogador pode "entrar" uns pixels no chão.
    private func snapPlayerToSurface() {
        if gravityIsDown {
            player.position.y = boundaryThickness + playerRadius
        } else {
            player.position.y = size.height - boundaryThickness - playerRadius
        }
    }

    // MARK: - Game Over

    // Função chamada quando o jogador morre. Congela tudo e muda para a cena final.
    private func endGame() {
        if gameEnded { return }

        gameEnded = true
        canInvertGravity = false

        // Para as físicas
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.affectedByGravity = false
        player.removeAllActions() // Para animações

        // Congela todos os obstáculos no sítio onde estão
        enumerateChildNodes(withName: "obstacle") { node, _ in
            node.removeAllActions()
            node.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }

        // Para e desativa as moedas do ecrã
        enumerateChildNodes(withName: "coin") { node, _ in
            node.removeAllActions()
            node.physicsBody = nil
        }

        flashScreen()

        // Aguarda um curto momento e transita suavemente para a GameOverScene
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

    // Efeito de flash vermelho no ecrã para indicar ao utilizador que bateu num obstáculo
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
