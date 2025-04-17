// Help View

import SwiftUI
struct HelpView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Getting Started")) {
                    HelpItemView(
                        icon: "camera.fill",
                        title: "Taking Photos",
                        description: "Tap the camera button to capture a photo with both cameras."
                    )
                    
                    HelpItemView(
                        icon: "video.fill",
                        title: "Recording Videos",
                        description: "Tap the video button to start recording. Videos can be up to 20 minutes long."
                    )
                }
                
                Section(header: Text("Split Styles")) {
                    HelpItemView(
                        icon: "rectangle.split.2x1",
                        title: "Straight Split",
                        description: "Divides the screen with a vertical line, showing both cameras side by side."
                    )
                    
                    HelpItemView(
                        icon: "rectangle.split.2x1.fill",
                        title: "Diagonal Split",
                        description: "Divides the screen with a diagonal line between the cameras."
                    )
                    
                    HelpItemView(
                        icon: "circle.square",
                        title: "Circular Split",
                        description: "Shows one camera in a circular overlay on top of the other."
                    )
                    
                    HelpItemView(
                        icon: "square.tophalf.fill",
                        title: "Corner Split",
                        description: "Shows one camera in the corner of the screen."
                    )
                }
                
                Section(header: Text("Filters")) {
                    HelpItemView(
                        icon: "camera.filters",
                        title: "Apply Filters",
                        description: "Tap the filters button to choose from different visual effects for your captures."
                    )
                }
                
                Section(header: Text("Tips")) {
                    HelpItemView(
                        icon: "lightbulb.fill",
                        title: "Best Results",
                        description: "For best results, hold the device steady and ensure good lighting for both cameras."
                    )
                    
                    HelpItemView(
                        icon: "square.and.arrow.up",
                        title: "Sharing",
                        description: "You can share your photos and videos directly from the gallery."
                    )
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Help & Tips")
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                }
            )
        }
    }
}

struct HelpItemView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 5)
    }
}
