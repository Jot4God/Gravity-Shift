import Foundation

struct PhysicsCategory {
    
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let ground: UInt32 = 1 << 0
    static let obstacle: UInt32 = 1 << 2
    static let coin: UInt32 = 1 << 3
    
}
