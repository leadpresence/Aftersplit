import SwiftUI
struct PhotoDetailView: View {
    let photo: Photo
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    if let frontImage = UIImage(data: photo.frontImage),
                       let backImage = UIImage(data: photo.backImage) {
                        
                        // Show images combined based on a fixed split style
                        ZStack {
                            Image(uiImage: backImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height * 0.8)
                            
                            Image(uiImage: frontImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.4, height: geometry.size.width * 0.4)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
            }
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Close")
                        .foregroundColor(.white)
                },
                trailing: Button(action: {
                    // Share photo functionality would go here
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            )
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
