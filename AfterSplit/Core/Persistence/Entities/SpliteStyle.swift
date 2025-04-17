import SwiftUI

enum SplitStyle: String, CaseIterable, Identifiable {
    case straight
    case diagonal
    case circular
    case corner
    
    var id: String { self.rawValue }
    
    var systemImageName: String {
        switch self {
        case .straight: return "rectangle.split.2x1"
        case .diagonal: return "rectangle.split.2x1.fill"
        case .circular: return "circle.square"
        case .corner: return "square.tophalf.fill"
        }
    }
}
