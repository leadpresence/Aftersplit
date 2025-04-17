enum Filter: String, CaseIterable, Identifiable {
    case none
    case mono
    case sepia
    case vibrant
    case dramatic
    
    var id: String { self.rawValue }
    
    func ciFilterName() -> String? {
        switch self {
        case .none: return nil
        case .mono: return "CIPhotoEffectMono"
        case .sepia: return "CISepiaTone"
        case .vibrant: return "CIVibrance"
        case .dramatic: return "CIPhotoEffectProcess"
        }
    }
}
