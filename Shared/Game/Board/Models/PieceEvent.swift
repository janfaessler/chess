enum PieceEvent {
    case moved(piece: PieceModel, deltaRow: Int, deltaFile: Int)
    case focusSet(piece: PieceModel)
    case focusCleared
}
