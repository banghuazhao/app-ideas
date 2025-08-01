//
// Created by Banghua Zhao on 05/08/2025
// Copyright Apps Bay Limited. All rights reserved.
//
  

import Foundation
import SwiftUI

struct LLMQuickLaunchButton: View {
    let icon: String
    let label: String
    let background: Color
    let foreground: Color
    let url: URL
    
    var body: some View {
        Button(action: {
            UIApplication.shared.open(url)
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(label)
            }
        }
        .buttonStyle(.llmQuickLaunch(background: background, foreground: foreground))
        .accessibilityLabel("Quick launch to \(label)")
    }
}
