protocol EngineProtocol {
    func startAnalysis(position: Position)
    func stopAnalysis()
    func addEvalListener(_ listener: @escaping ([EngineLine]) -> Void)
}
