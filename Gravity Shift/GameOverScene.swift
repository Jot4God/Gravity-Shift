import SpriteKit

// Cena de Game Over que exibe a pontuação final, recorde e botões de ação.
class GameOverScene: SKScene {

    private let finalScore: Int

    private var restartButton = SKShapeNode()
    private var menuButton = SKShapeNode()

    private var highScore = 0
    private var isNewHighScore = false

    // Inicializador principal da cena, recebendo a pontuação final da partida.
    init(size: CGSize, finalScore: Int) {
        self.finalScore = finalScore
        super.init(size: size)
    }

    // Inicializador obrigatório exigido pelo SpriteKit (usado caso a cena fosse carregada via interface builder/storyboard).
    required init?(coder aDecoder: NSCoder) {
        self.finalScore = 0
        super.init(coder: aDecoder)
    }

    // Método chamado automaticamente assim que a cena é apresentada no ecrã.
    // É aqui que montamos todo o visual e a interface.
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.03, green: 0.03, blue: 0.08, alpha: 1)

        updateHighScore()

        createStars()
        createTitle()
        createScores()
        createRestartButton()
        createMenuButton()
    }

    // Verifica a pontuação final contra o recorde guardado no dispositivo (UserDefaults).
    // Atualiza o recorde se o jogador tiver feito uma pontuação maior.
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

    // Cria um fundo estrelado gerando vários círculos brancos em posições e tamanhos aleatórios.
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

    // Cria e posiciona os textos principais no topo da ecrã (Ex: "GAME OVER" e "NEW BEST!").
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

    // Posiciona as etiquetas que vão mostrar a pontuação atual e o recorde máximo do jogador.
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

    // Função auxiliar para construir os textos de pontuação para evitar repetição de código.
    // Recebe o título, o valor, a cor e a posição.
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

    // Instancia o botão de "REINICIAR" com o seu visual específico e adiciona a animação de pulsar.
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

    // Instancia o botão de "MENU" com o seu visual específico e adiciona a animação de pulsar.
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

    // Função auxiliar para construir qualquer botão da cena (SKShapeNode).
    // Configura o fundo, bordas, brilho, posição e o texto interior.
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

    // Cria e aplica uma animação contínua ao botão, fazendo-o aumentar e diminuir de tamanho (pulsar).
    private func addPulse(to button: SKShapeNode) {
        let scaleUp = SKAction.scale(to: 1.04, duration: 0.65)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.65)
        button.run(SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown])))
    }

    // Deteta toques no ecrã. Verifica qual botão foi pressionado (Restart ou Menu) e dispara a ação correspondente.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)

        if restartButton.contains(location) {
            restartGame()
        } else if menuButton.contains(location) {
            goToMenu()
        }
    }

    // Trata o evento de reiniciar o jogo.
    // Executa uma rápida animação de "click" no botão e faz uma transição de ecrã para a GameScene.
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

    // Trata o evento de voltar ao menu.
    // Executa uma rápida animação de "click" no botão e faz uma transição de ecrã para a MenuScene.
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
