import SwiftUI

struct VideoThumbnailView: View {
    let video: Video
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 120)
                .overlay(
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                )
            
            // Duration indicator
            Text(formatDuration(video.duration))
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.6))
                .cornerRadius(4)
                .padding(4)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

