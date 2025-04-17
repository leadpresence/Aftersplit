import SwiftUI

struct SplitStyleSelector: View {
    let currentStyle: SplitStyle
    let onStyleSelected: (SplitStyle) -> Void
    
    var body: some View {
        Menu {
            ForEach(SplitStyle.allCases) { style in
                Button(action: {
                    onStyleSelected(style)
                }) {
                    Label(
                        style.rawValue.capitalized,
                        systemImage: style.systemImageName
                    )
                }
            }
        } label: {
            Image(systemName: currentStyle.systemImageName)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
        }
    }
}
