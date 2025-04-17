import SwiftUI

struct CornerMask: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Create a mask for the top-right corner (1/4 of the screen)
        path.move(to: CGPoint(x: rect.maxX - rect.width/3, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + rect.height/3))
        path.closeSubpath()
        
        return path
    }
}
