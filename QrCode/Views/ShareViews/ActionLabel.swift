//
//  ActionLabel.swift
//  QrCode
//
//  Created by P. Nam on 29/05/2024.
//

import SwiftUI

struct ActionLabel: View {
    private let text: String
    private let color: Color
    
    init(text: String, color: Color) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                color.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 8
                        )
                    )
            }
    }
}

#Preview {
    ActionLabel(text: "Button", color: .blue)
}
