//
//  URLPreview.swift
//  QrCode
//
//  Created by P. Nam on 31/05/2024.
//

import SwiftUI
import LinkPresentation

struct URLPreview: UIViewRepresentable {
    private let metaData: LPLinkMetadata
    
    init(metaData: LPLinkMetadata) {
        self.metaData = metaData
    }
    
    func makeUIView(context: Context) -> LPLinkView {
        LPLinkView(metadata: metaData)
    }
    
    func updateUIView(_ uiView: LPLinkView, context: Context) {
        uiView.metadata = metaData
    }
}

#Preview {
    URLPreview(metaData: LPLinkMetadata())
}
