//
//  CamButton.swift
//  AfterSplit
//
//  Created by Chibueze Felix on 12/04/2025.
//
import SwiftUI
struct CameraButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
