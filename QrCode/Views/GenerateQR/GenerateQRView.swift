//
//  GenerateQRView.swift
//  QrCode
//
//  Created by P. Nam on 29/05/2024.
//

import SwiftUI
import PhotosUI

struct GenerateQRView: View {
    @State private var textGenerate: String = ""
    @State private var text: String = ""
    @State private var backgroundImage: UIImage?
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if textGenerate.isEmpty {
                    Text("Input text")
                } else {
                    QRView(
                        $textGenerate,
                        $backgroundImage
                    )
                }
            }
            .frame(width: 200, height: 200)
            
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    TextField(
                        text: $text,
                        prompt: Text("Input text to generate QR")
                            .foregroundColor(.gray)
                    ) {
                        Text(text)
                            .foregroundColor(.black)
                    }
                    .frame(height: 52)
                    .padding(.leading, 8)
                    .padding(.vertical, 4)
                    
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .tint(.black)
                            .frame(width: 12, height: 12)
                            .padding(.trailing, 8)
                            .padding(.vertical, 12)
                    }
                }.overlay {
                    if text.isEmpty {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray, lineWidth: 1)
                            .frame(height: 52)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black, lineWidth: 2)
                            .frame(height: 52)
                    }
                }
                
                Button {
                    self.textGenerate = text
                } label: {
                    ActionLabel(text: "Generate QR", color: .blue)
                }
                .frame(width: 150)
            }
            .padding(.horizontal, 16)
            
            GalleryPickerImageView(
                title: "Pick background image",
                image: $backgroundImage
            )
            .padding(.horizontal, 16)
        }
        .navigationTitle("Generate QR")
    }
}

#Preview {
    GenerateQRView()
}
