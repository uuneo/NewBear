//
//  AsyncImageView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI





struct AsyncImageView: View {
    let imageUrl: String
    
    @State private var image: UIImage?
    
    @State var toastText:String = ""
    @State var isPressed:Bool = false
    @State var scale:Int = 1
    
    var isSave:Bool = false
    
    var body: some View {
        
        if let image = image {
            // 如果已经加载了图片，则显示图片
           
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .scaleEffect(isPressed ? 1.2 : 1.0) // 控制缩放比例
                .animation(.easeInOut(duration: 0.3), value: isPressed) // 应用动画
            
                .onTapGesture(count: 2) {
                
                    if isSave{
                        isPressed = true
                        Task{
                            let imageSaver = ImageSaver()
                            imageSaver.requestAuthorizationAndSaveImage(image: image) { result in
                                pawManager.shared.dispatch_sync_safely_main_queue {
                                    self.toastText = result.localized
                                    isPressed = false
                                }
                            }
                        }
                    }

                }
                
        } else {
            // 如果图片尚未加载，则显示加载中的视图
            ProgressView()
                .onAppear {
                    // 在视图显示时异步下载图片
                    Task {
                        if let imagePath = await ImageManager.downloadImage(imageUrl) {
                            self.image = UIImage(contentsOfFile: imagePath)
                        }
                    }
                }
        }
    }
}

