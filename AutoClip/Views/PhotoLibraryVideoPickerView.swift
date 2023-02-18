//
//  PhotoLibraryVideoPickerView.swift
//  AutoClip
//
//  Created by cmStudent on 2023/02/10.
//

import SwiftUI
import PhotosUI

struct PhotoLibraryVideoPickerView: UIViewControllerRepresentable {

    @Environment(\.dismiss) private var dismiss
    @Binding var videoUrl: URL?
    @Binding var isLoading: Bool

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {

        let parent: PhotoLibraryVideoPickerView

        init(_ parent: PhotoLibraryVideoPickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            self.parent.isLoading = true
            parent.dismiss()

            guard let provider = results.first?.itemProvider else {
                self.parent.isLoading = false
                return
            }

            let typeIdentifier = UTType.movie.identifier

            if provider.hasItemConformingToTypeIdentifier(typeIdentifier) {

                provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                    if let error = error {
                        print("error: \(error)")
                        return
                    }
                    if let url = url {
                        let fileName = "\(UUID().uuidString).\(url.pathExtension)"
                        let newUrl = URL(fileURLWithPath: NSTemporaryDirectory() + fileName)
                        try? FileManager.default.copyItem(at: url, to: newUrl)
                        self.parent.videoUrl = newUrl
                        print("url:", newUrl)
                        self.parent.isLoading = false
                    }
                }
            }
        }
        
        
    }
}
