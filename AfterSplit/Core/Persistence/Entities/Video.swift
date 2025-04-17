struct Video {
    let id: UUID
    let url: URL
    let duration: TimeInterval
    let timestamp: Date
    let appliedFilter: Filter?
}
