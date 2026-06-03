import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let skView = self.view as? SKView {
            // Inicia o jogo diretamente na cena do Menu ocupando todo o ecrã
            let scene = MenuScene(size: skView.bounds.size)
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)

            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }

    // Esconde a barra de estado (bateria, rede, horas) para jogar em ecrã inteiro
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
