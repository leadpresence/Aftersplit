import SwiftUI
struct EmptyStateView: View {
    let mediaType: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: mediaType == "photos" ? "photo.on.rectangle" : "video")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No \(mediaType) yet")
                .font(.title2)
                .foregroundColor(.gray)
            
            Text("Captured \(mediaType) will appear here")
                .font(.body)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

