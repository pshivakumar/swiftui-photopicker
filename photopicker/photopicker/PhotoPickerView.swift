//
//  PhotoPickerView.swift
//  photopicker
//
//  Created by shiva kumar on 10/12/23.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        VStack {
            if let image = selectedImage {
                // Display selected image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Button("Pick a Photo") {
                    isImagePickerPresented.toggle()
                }
                .padding()
                .sheet(isPresented: $isImagePickerPresented) {
                    // Present the PhotoPicker sheet
                    PhotoPicker(selectedImage: $selectedImage, isImagePickerPresented: $isImagePickerPresented)
                }
            }
        }
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var isImagePickerPresented: Bool // Binding to control the presentation of the sheet

    // Create and configure the PHPickerViewController
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    // Update the PHPickerViewController
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    // Create the coordinator to handle PHPickerViewControllerDelegate methods
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker

        init(parent: PhotoPicker) {
            self.parent = parent
        }
        
        // Called when the user finishes picking photos
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let selectedItem = results.first {
                // Load the selected image
                selectedItem.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        // Update the selected image on the main thread
                        DispatchQueue.main.async {
                            self.parent.selectedImage = image
                        }
                    }
                }
            } else {
                parent.selectedImage = nil
            }

            parent.isImagePickerPresented = false
        }
    }
}

struct PhotoPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerView()
    }
}
