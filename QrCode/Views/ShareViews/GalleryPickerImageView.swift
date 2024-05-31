//
//  GalleryPickerImageView.swift
//  QrCode
//
//  Created by P. Nam on 29/05/2024.
//

import SwiftUI
import PhotosUI

struct GalleryPickerImageView: View {
    @State private var photoItem: PhotosPickerItem?
    @Binding private var image: UIImage?
    private let title: String
    
    init(title: String, image: Binding<UIImage?>) {
        self.title = title
        self._image = image
    }
    
    var body: some View {
        PhotosPicker(selection: $photoItem, matching: .images) {
            ActionLabel(text: title, color: .black)
        }
        .onChange(of: photoItem) { oldValue, newValue in
            Task(priority: .background) {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        Task(priority: .background) { @MainActor in
                            self.image = uiImage
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    GalleryPickerImageView(title: "dssdsds", image: .constant(nil))
}
