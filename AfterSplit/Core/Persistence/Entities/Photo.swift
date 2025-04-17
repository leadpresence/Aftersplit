import SwiftUI
struct Photo:Identifiable {
    let id: UUID
    let frontImage: Data
    let backImage: Data
    let timestamp: Date
    let appliedFilter: Filter?
}
