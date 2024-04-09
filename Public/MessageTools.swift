//
//  MessageTools.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//


import UIKit
import Foundation
import RealmSwift
import Photos
import SwiftUI

func filterMessage(_ messages:Results<NotificationMessage>,searchText:String)-> Results<NotificationMessage>{
    if searchText == ""{
        return messages
    }
    
    let resultFilter = messages.filter(NSPredicate(format: "title CONTAINS[c] %@ OR body CONTAINS[c] %@", searchText, searchText))
    
    let newResult = resultFilter.sorted(by: [
        SortDescriptor(keyPath: "isRead", ascending: true),
        SortDescriptor(keyPath: "createDate", ascending: false)
    ])
    
    return newResult
}




class ImageSaver: NSObject {
   
    // 定义完成回调类型
    var completionHandler: ((Bool, Error?) -> Void)?

    // 调用此方法来保存图片
    func saveImage(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        self.completionHandler = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    // 保存完成时被调用的方法
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        completionHandler?(error == nil, error)
    }
    
    
    func requestAuthorizationAndSaveImage(image:UIImage,_ complate: @escaping (saveType)->Void) {

        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                self.saveImage(image: image) { success, error in
                    if !success{
#if DEBUG
                        print("error: \(String(describing: error?.localizedDescription))")
#endif
                       
                    }
                    complate( success ? .success : .failSave)
                }
            } else {
                // 处理未获得权限的情况
                complate(.failAuth)
            }
        }
    }
    
    
    
}

