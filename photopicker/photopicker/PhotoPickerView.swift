//
//  PhotoPickerView.swift
//  photopicker
//
//  Created by shiva kumar on 10/12/23.
//

import SwiftUI
import PhotosUI

enum PhotoPickerError: Error {
    case failedToLoadImageData
    case failedToConvertDataToImage
    // Add more error cases as needed
}

struct PhotoPickerView: View {
    @State private var selectedItems:[PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []


    var body: some View {
        VStack {
            if !selectedImages.isEmpty {
                ScrollView(showsIndicators: false) {
                    ForEach(selectedImages, id: \.self) {image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                }
                .frame(width: 300, height: 500)
            }
            
            PhotosPicker(selection: $selectedItems, matching: .images) {
                Label("Pick Photos", systemImage: "photo.fill.on.rectangle.fill")
            }
        }
        .onChange(of: selectedItems) { newItems in
            newItems.forEach { item in
                // Clear the earlier selected images, so that only fresh selection is shown
                selectedImages = []
                Task {
                    do {
                        guard let data = try? await item.loadTransferable(type: Data.self) else {
                            throw PhotoPickerError.failedToLoadImageData
                        }
                        guard let image = UIImage(data: data) else {
                            throw PhotoPickerError.failedToConvertDataToImage
                        }
                        selectedImages.append(image)
                    }catch {
                        // Handle error
                        print("Error loading image \(error)")
                    }

                }
            }
        }
    }
}

struct PhotoPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerView()
    }
}
