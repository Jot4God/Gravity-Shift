import Foundation

// Gere o saldo global de moedas do jogador, guardando o valor localmente no dispositivo.
final class Coins {

    static let shared = Coins()

    private let coinsKey = "CoinsBalance"

    private init() {}

    var balance: Int {
        return UserDefaults.standard.integer(forKey: coinsKey)
    }

    func add( amount: Int) {
        if amount <= 0 { return }

        let newBalance = balance + amount
        UserDefaults.standard.set(newBalance, forKey: coinsKey)
    }

    func spend( amount: Int) -> Bool {
        if amount <= 0 { return false }

        if balance >= amount {
            let newBalance = balance - amount
            UserDefaults.standard.set(newBalance, forKey: coinsKey)
            return true
        }

        return false
    }

    func reset() {
        UserDefaults.standard.set(0, forKey: coinsKey)
    }
}
