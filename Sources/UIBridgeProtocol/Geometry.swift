import Foundation

public struct UIBPoint: Codable, Hashable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct UIBSize: Codable, Hashable, Sendable {
    public var width: Double
    public var height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
}

public struct UIBRect: Codable, Hashable, Sendable {
    public var origin: UIBPoint
    public var size: UIBSize

    public init(x: Double, y: Double, width: Double, height: Double) {
        self.origin = UIBPoint(x: x, y: y)
        self.size = UIBSize(width: width, height: height)
    }
}
