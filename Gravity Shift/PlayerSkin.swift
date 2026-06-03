import SpriteKit

// Define as skins disponíveis, os seus preços e as respetivas propriedades visuais.
enum PlayerSkin: String, CaseIterable {
    case cyan
    case purple
    case gold

    var name: String {
        switch self {
        case .cyan:
            return "CYAN"
        case .purple:
            return "PURPLE"
        case .gold:
            return "GOLD"
        }
    }

    var price: Int {
        switch self {
        case .cyan:
            return 0
        case .purple:
            return 10
        case .gold:
            return 20
        }
    }

    var fillColor: SKColor {
        switch self {
        case .cyan:
            return .cyan
        case .purple:
            return SKColor(red: 0.65, green: 0.25, blue: 1.0, alpha: 1)
        case .gold:
            return SKColor(red: 1.0, green: 0.75, blue: 0.10, alpha: 1)
        }
    }

    var strokeColor: SKColor {
        return .white
    }
}

// Gestor da loja que guarda a skin selecionada e as compras nos UserDefaults.
final class PlayerSkinStore {

    static let shared = PlayerSkinStore()

    private let selectedSkinKey = "SelectedPlayerSkin"
    private let unlockedPrefix = "UnlockedPlayerSkin_"

    private init() {}

    var selectedSkin: PlayerSkin {
        let savedValue = UserDefaults.standard.string(forKey: selectedSkinKey) ?? PlayerSkin.cyan.rawValue
        return PlayerSkin(rawValue: savedValue) ?? .cyan
    }

    func isUnlocked(_ skin: PlayerSkin) -> Bool {
        if skin.price == 0 {
            return true
        }

        return UserDefaults.standard.bool(forKey: unlockedPrefix + skin.rawValue)
    }

    func select(_ skin: PlayerSkin) {
        if isUnlocked(skin) {
            UserDefaults.standard.set(skin.rawValue, forKey: selectedSkinKey)
        }
    }

    func buy(_ skin: PlayerSkin) -> Bool {
        if isUnlocked(skin) {
            select(skin)
            return true
        }

        let bought = Coins.shared.spend(amount: skin.price)

        if bought {
            UserDefaults.standard.set(true, forKey: unlockedPrefix + skin.rawValue)
            select(skin)
            return true
        }

        return false
    }
}
