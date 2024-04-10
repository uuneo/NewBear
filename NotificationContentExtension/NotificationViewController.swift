//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by He Cho on 2024/4/9.
//


import UIKit
import UserNotifications
import UserNotificationsUI
import WebKit
import Down


class NotificationViewController: UIViewController, UNNotificationContentExtension {
    let markLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 // 设置为 0 表示可以显示多行文本
        label.lineBreakMode = .byWordWrapping // 换行方式为按单词换行
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        
        
        return label
    }()
    
    let copyTips: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 0, height: 0) // 设置初始框架
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(copyTips)
        self.view.addSubview(markLabel)
        markLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            markLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 10),
            markLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            markLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -10),
            markLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10)
        ])
        
    }
    
    
    func didReceive(_ notification: UNNotification) {
        
        let userInfo = notification.request.content.userInfo
        
        if let autoCopy = userInfo["autocopy"]as? String,autoCopy == "1" {
            if let copy = userInfo["copy"] as? String {
                UIPasteboard.general.string = copy
            }
            else {
                UIPasteboard.general.string = notification.request.content.body
            }
        }
        
        if let markdown = userInfo["markdown"] as? String {
            
            let down = Down(markdownString: markdown)
        
            do {
//                let attributedString = try down.toAttributedString()
                let attributedString = try down.toAttributedString()
                
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                
                let textColor = UIColor { traitCollection in
                    if traitCollection.userInterfaceStyle == .dark {
                        return UIColor.white // 深色模式下的字体颜色
                    } else {
                        return UIColor.black // 浅色模式下的字体颜色
                    }
                }
                
                mutableAttributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: mutableAttributedString.length))
            
                
                markLabel.attributedText = mutableAttributedString
                
                return
            } catch {
#if DEBUG
                print("Error converting Markdown to NSAttributedString:", error)
#endif
                
            }
            
            
        }
        self.preferredContentSize = CGSize(width: 0, height: 1)
        markLabel.removeFromSuperview()
       
        
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let copy = userInfo["copy"] as? String {
            UIPasteboard.general.string = copy
        }
        else {
            UIPasteboard.general.string = response.notification.request.content.body
        }
        self.copyTips.text = NSLocalizedString("groupMessageMode", comment: "复制成功")
        self.copyTips.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 10)
        completion(.doNotDismiss)
    }
    
    

    
}

