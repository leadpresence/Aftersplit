import SwiftUI
struct FilterSelector: View {
    let currentFilter: Filter
    let onFilterSelected: (Filter) -> Void
    
    var body: some View {
        Menu {
            ForEach(Filter.allCases) { filter in
                Button(action: {
                    onFilterSelected(filter)
                }) {
                    Text(filter.rawValue.capitalized)
                }
            }
        } label: {
            Image(systemName: "camera.filters")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.6))
                .clipShape(Circle())
        }
    }
}
