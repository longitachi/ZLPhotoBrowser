//
//  ContentView.swift
//  SwiftUIExample
//
//  Created by long on 2025/3/27.
//

import SwiftUI
import ZLPhotoBrowser

struct ContentView: View {
    @State private var selectedIndex = 0
    @State private var selectPhoto = false
    @State private var previewPhoto = false
    
    @State private var results: [ZLResultModel] = []
    @State private var isOriginal = false
    
    var body: some View {
        VStack {
            HStack {
                Button("Library Selection") {
                    selectPhoto = true
                }
                .frame(height: 30)
                .padding(10)
                .background(.black)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerSize: CGSize(width: 10, height: 10)))
                .fullScreenCover(isPresented: $selectPhoto) {
                    PhotoPickerWrapper(results: $results, isOriginal: $isOriginal)
                        .ignoresSafeArea()
                }
            }
            
            Spacer(minLength: 50)
            
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let spacing: CGFloat = 10
                let columnCount: CGFloat = 4
                let cellWidth = (totalWidth - (spacing * (columnCount - 1))) / columnCount
                
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: Int(columnCount)),
                        spacing: 10)
                    {
                        ForEach(results.indices, id: \.self) { index in
                            Image(uiImage: results[index].image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: cellWidth, height: cellWidth)
                                .cornerRadius(8)
                                .onTapGesture {
                                    previewPhoto = true
                                    selectedIndex = index
                                }
                        }
                    }
                    .padding()
                }
                .fullScreenCover(isPresented: $previewPhoto) {
                    PhotoPickerWrapper(
                        isPreviewResults: true,
                        index: selectedIndex,
                        results: $results,
                        isOriginal: $isOriginal
                    )
                    .ignoresSafeArea()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
