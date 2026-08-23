enum FigureEvent {
    case moved(figure: FigureModel, deltaRow: Int, deltaFile: Int)
    case focusSet(figure: FigureModel)
    case focusCleared
}
