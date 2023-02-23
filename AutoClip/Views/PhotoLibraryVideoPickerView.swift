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
    /// フォトライブラリからテンポラリーフォルダにコピーされた動画のurl
    @Binding var videoUrl: URL?
    /// フォトライブラリにある動画にアクセスするための識別子
    @Binding var localIdentifier: String
    /// 動画の読み込み、コピー中か
    @Binding var isLoading: Bool
    /// クリップ検出画面を表示するか
    @Binding var isShowClipDetectionView: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
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
                        DispatchQueue.main.async {
                            self.parent.videoUrl = newUrl
                            print("url:", newUrl)
                            self.parent.isLoading = false
                            self.parent.isShowClipDetectionView = true
                        }
                    }
                }
            }
            
            guard let assetIdentifier = results.first?.assetIdentifier else {
                self.parent.isLoading = false
                    return
                }
                        

            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
                guard let asset = fetchResult.firstObject else {
                    self.parent.isLoading = false
                    return
                }
            
            
            
            let options = PHVideoRequestOptions()
            options.version = .original
            
            self.parent.localIdentifier = asset.localIdentifier
            print("localIdentifier:", asset.localIdentifier)

        }
    }
}
