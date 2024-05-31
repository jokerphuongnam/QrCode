//
//  ScanQRView.swift
//  QrCode
//
//  Created by P. Nam on 29/05/2024.
//

import SwiftUI
import LinkPresentation
import Photos

struct ScanQRView: View {
    @State private var result: String = ""
    @State private var metaData: LPLinkMetadata?
    @State private var status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    
    var body: some View {
        ZStack {
            switch status {
            case .notDetermined:
                requestAuthorizeView
            case .authorized:
                scanCameraView
            case .denied, .restricted:
                deninedView
            @unknown default:
                EmptyView()
            }
        }
        .navigationTitle("Scan QR")
    }
    
    private var requestAuthorizeView: some View {
        ZStack {
            
        }
        .onAppear {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task(priority: .high) { @MainActor in
                    self.status = granted ? .authorized : .denied
                }
            }
        }
    }
    
    private var deninedView: some View {
        VStack(spacing: 8) {
            Button {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl) { success in
                        Task(priority: .high) { @MainActor in
                            self.status = AVCaptureDevice.authorizationStatus(for: .video)
                        }
                    }
                }
            } label: {
                ActionLabel(text: "Grant permissions", color: .blue)
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var scanCameraView: some View {
        VStack(spacing: 16) {
            ScanQRRepresentable(code: $result)
                .frame(width: 200, height: 200)
                .scaledToFill()
                .clipped()
            
            ZStack {
                if result.isEmpty {
                    Text("Scan Barcode or QR code")
                } else {
                    HStack(spacing: 4) {
                        if let url = URL(string: result) {
                            if let metaData {
                                URLPreview(metaData: metaData)
                                    .onChange(of: result) { oldValue, newValue in
                                        if oldValue != newValue {
                                            self.metaData = nil
                                        }
                                    }
                            } else {
                                HStack(spacing: 4) {
                                    Text(.init(result))
                                        .underline()
                                        .italic()
                                    
                                    ProgressView()
                                }
                                .onAppear {
                                    loadPreview(url: url)
                                }
                            }
                        } else {
                            Text(result)
                        }
                        
                        Button {
                            UIPasteboard.general.string = result
                        } label: {
                            Image(systemName: "doc.on.doc")
                                .tint(.black)
                                .clipped()
                                .frame(width: 24, height: 14)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 300)
        }
    }
    
    private func loadPreview(url previewURL: URL) {
        let provider = LPMetadataProvider()
        
        provider.startFetchingMetadata(for: previewURL) { (metadata, error) in
            if let metadata {
                Task(priority: .high) { @MainActor in
                    self.metaData = metadata
                }
            }
        }
    }
}

#Preview {
    ScanQRView()
}
