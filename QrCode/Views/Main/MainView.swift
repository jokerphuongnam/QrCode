//
//  MainView.swift
//  QrCode
//
//  Created by P. Nam on 29/05/2024.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        VStack(spacing: 8) {
            NavigationLink(value: MainDestination.generateQR) {
                ActionLabel(text: "Generate QR", color: .blue)
            }
            
            NavigationLink(value: MainDestination.scanQR) {
                ActionLabel(text: "Scan QR", color: .yellow)
            }
        }
        .padding(.horizontal, 16)
        .navigationTitle("QRCode App")
        .navigationDestination(for: MainDestination.self) { destination in
            switch destination {
            case .generateQR:
                GenerateQRView()
            case .scanQR:
                ScanQRView()
            }
        }
    }
}

#Preview {
    MainView()
}
