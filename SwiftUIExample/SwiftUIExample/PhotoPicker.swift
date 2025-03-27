//
//  PhotoPicker.swift
//  SwiftUIExample
//
//  Created by long on 2025/3/27.
//

import Foundation
import SwiftUI
import ZLPhotoBrowser

struct PhotoPickerWrapper: UIViewControllerRepresentable {
    var isPreviewResults = false
    var index = 0
    @Binding var results: [ZLResultModel]
    @Binding var isOriginal: Bool
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> some UIViewController {        
        let picker = ZLPhotoPicker()
        picker.selectImageBlock = { results, isOriginal in
            self.results = results
            self.isOriginal = isOriginal
        }
        picker.cancelBlock = {
            debugPrint("Cancel Select")
        }
        
        if isPreviewResults {
            return picker.previewAssetsForSwiftUI(assets: results.map { $0.asset }, index: index, isOriginal: isOriginal)
        } else {
            return picker.showPhotoLibraryForSwiftUI()
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
