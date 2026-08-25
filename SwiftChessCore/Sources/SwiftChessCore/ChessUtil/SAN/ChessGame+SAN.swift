import Foundation

public extension ChessGame {
    func move(_ moveNotation: String) throws {
        guard let move = MoveFactory.create(moveNotation, position: position) else {
            throw ValidationError.canNotIdentifyMove
        }
        try self.move(move)
    }
}
