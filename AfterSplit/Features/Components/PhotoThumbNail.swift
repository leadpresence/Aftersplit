import SwiftUI
struct PhotoThumbnailView: View {
    let photo: Photo
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let backImage = UIImage(data: photo.backImage) {
                Image(uiImage: backImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipShape(Rectangle())
                
                // Indicator for front camera image
                Image(systemName: "person.crop.square")
                    .font(.system(size: 12))
                    .padding(4)
                    .background(Color.black.opacity(0.6))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .padding(4)
            }
        }
    }
}
