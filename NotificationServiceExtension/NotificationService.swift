//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/4/9.
//

import Intents
import Kingfisher
import MobileCoreServices
import SwiftyJSON
import UIKit
import UserNotifications
import UniformTypeIdentifiers
import SwiftUI
import Foundation
import RealmSwift
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    @AppStorage(settings.badgemode,store: defaultStore) var badgeMode:badgeAutoMode = .auto
    @AppStorage(settings.emailConfig,store: defaultStore) var email:emailConfig = emailConfig.data
    
    @AppStorage(settings.CryptoSettingFields,store: defaultStore) var cryptoFields:CryptoSettingFields = CryptoSettingFields.data
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    lazy var realm: Realm? = {
        let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: settings.groupName)
        let fileUrl = groupUrl?.appendingPathComponent(settings.realmName)
        let config = Realm.Configuration(
            fileURL: fileUrl,
            schemaVersion: 6,
            migrationBlock: { _, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 1 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            }
        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        return try? Realm()
    }()
    
    
    /// 保存推送
    /// - Parameter userInfo: 推送参数
    /// 如果用户携带了 `isarchive` 参数，则以 `isarchive` 参数值为准
    fileprivate func archive(_ userInfo: [AnyHashable: Any]) {
        
        let alert = (userInfo["aps"] as? [String: Any])?["alert"] as? [String: Any]
        let title = alert?["title"] as? String
        let body = alert?["body"] as? String
        let group = (userInfo["aps"] as? [String: Any])?["thread-id"] as? String
        let icon = userInfo["icon"] as? String
        let url = userInfo["url"] as? String
        let markdown = userInfo["markdown"] as? String
        
        var isArchive: Bool{
            if let archive = userInfo["isarchive"] as? String {
                return archive == "1" ? true : false
            }
            return  true
        }
        
        
        if isArchive == true {
            
            
            let message = NotificationMessage()
            message.title = title
            message.body = body
            message.icon = icon
            message.group = group ?? NSLocalizedString("defaultGroup",comment: "")
            message.url = url
            message.markdown = markdown
            
            do{
                try realm?.write {
                    realm?.add(message)
                }
            }catch{
#if DEBUG
                print("\(error)")
#endif
               
            }
            
            
        }
        
        
    }
    
    
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        
        
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }
        
        var userInfo = bestAttemptContent.userInfo
        
        // 如果是加密推送，则使用密文配置 bestAttemptContent
        if let ciphertext = userInfo["ciphertext"] as? String {
            do {
                var map = try decrypt(ciphertext: ciphertext, iv: userInfo["iv"] as? String)
                for (key, val) in map {
                    // 将key重写为小写
                    map[key.lowercased()] = val
                }
                var alert = [String: Any]()
                
                if let alertEmp = (userInfo["aps"] as? [String: Any])?["alert"] as? [String: Any]{
                    alert = alertEmp
                }
                
                if let title = map["title"] as? String {
                    bestAttemptContent.title = title
                    alert["title"] = title
                }
                if let body = map["body"] as? String {
                    bestAttemptContent.body = body
                    alert["body"] = body
                }
                if let group = map["group"] as? String {
                    bestAttemptContent.threadIdentifier = group
                }
                if var sound = map["sound"] as? String {
                    if !sound.hasSuffix(".caf") {
                        sound = "\(sound).caf"
                    }
                    bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
                }
                if let badge = map["badge"] as? Int {
                    bestAttemptContent.badge = badge as NSNumber
                }
                
                if let markdown = map["markdown"] as? String {
                    alert["markdown"] = markdown
                }
                
                map["aps"] = ["alert": alert]
                userInfo = map
                bestAttemptContent.userInfo = userInfo
            }
            catch {
                bestAttemptContent.body = "Decryption Failed"
                bestAttemptContent.userInfo = ["aps": ["alert": ["body": bestAttemptContent.body]]]
                return
            }
        }
        
        
        
        
        switch badgeMode {
        case .auto:
            // MARK: 通知角标 .custom
            if let badgeStr = bestAttemptContent.userInfo["badge"] as? String, let badge = Int(badgeStr) {
                bestAttemptContent.badge = NSNumber(value: badge)
            }
        case .custom:
            // MARK: 通知角标 .auto
            let messages = realm?.objects(NotificationMessage.self).where {!$0.isRead}
            bestAttemptContent.badge = NSNumber(value:  messages?.count ?? 0 + 1)
        }
        
        
        
        // MARK:  通知中断级别
        if let level = userInfo["level"] as? String {
            let interruptionLevels: [String: UNNotificationInterruptionLevel] = [
                "passive": UNNotificationInterruptionLevel.passive,
                "active": UNNotificationInterruptionLevel.active,
                // MARK: 兼容版本
                "timeSensitive": UNNotificationInterruptionLevel.timeSensitive,
                "timesensitive": UNNotificationInterruptionLevel.timeSensitive,
                "critical": UNNotificationInterruptionLevel.critical,
            ]
            bestAttemptContent.interruptionLevel = interruptionLevels[level] ?? .active
        }
        
        // MARK: 保存消息
        archive(userInfo)
        
        // MARK: 发送邮件
        mailAuto(userInfo)
        
        
        Task.init {
            // 设置推送图标
            let iconResult = await setIcon(content: bestAttemptContent)
            
            contentHandler(iconResult)
        }
    }
    
    // MARK: 发送邮件
    private func mailAuto(_ userInfo:[AnyHashable: Any]){
        Task{
            if let action = userInfo["action"] as? String{
                if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted) {
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    toolsManager.sendMail(config: email, title: "自动化\(action)", text: jsonString ?? "数据编码失败")
                } else {
#if DEBUG
                    print("转换失败")
#endif
                   
                    toolsManager.sendMail(config: email, title: "自动化\(action)", text: "数据编码失败")
                }
            }
        }
        
    }
    
    // MARK: 解密
    func decrypt(ciphertext: String, iv: String? = nil) throws -> [String: Any] {
        
        if let iv = iv {
            // Support using specified IV parameter for decryption
            cryptoFields.iv = iv
        }
        
        let aes = try AESCryptoModel(cryptoFields: cryptoFields)
        
        let json = try aes.decrypt(ciphertext: ciphertext)
        
        guard let data = json.data(using: .utf8), let map = JSON(data).dictionaryObject else {
            throw MyError.customError(description: "JSON parsing failed")
        }
        return map
    }
    
    
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    
    
}




extension NotificationService{
    /// 保存图片到缓存中
    /// - Parameters:
    ///   - cache: 使用的缓存
    ///   - data: 图片 Data 数据
    ///   - key: 缓存 Key
    func storeImage(cache: ImageCache, data: Data, key: String) async {
        return await withCheckedContinuation { continuation in
            cache.storeToDisk(data, forKey: key, expiration: StorageExpiration.never) { _ in
                continuation.resume()
            }
        }
    }
    
    /// 使用 Kingfisher.ImageDownloader 下载图片
    /// - Parameter url: 下载的图片URL
    /// - Returns: 返回 Result
    func downloadImage(url: URL) async -> Result<ImageLoadingResult, KingfisherError> {
        return await withCheckedContinuation { continuation in
            Kingfisher.ImageDownloader.default.downloadImage(with: url, options: nil) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    
    /// 下载推送图片
    /// - Parameter imageUrl: 图片URL字符串
    /// - Returns: 保存在本地中的`图片 File URL`
    fileprivate func downloadImage(_ imageUrl: String, _ bestAttemptContent: UNMutableNotificationContent) async -> String? {
        
        
        guard let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: settings.groupName),
              let cache = try? ImageCache(name: "shared", cacheDirectoryURL: groupUrl),
              let imageResource = URL(string: imageUrl)
        else {
            return nil
        }
        
        // 先查看图片缓存
        if cache.diskStorage.isCached(forKey: imageResource.cacheKey) {
            return cache.cachePath(forKey: imageResource.cacheKey)
        }
        
        // 下载图片
        guard let result = try? await downloadImage(url: imageResource).get() else {
            return nil
        }
        
        // 缓存图片
        await storeImage(cache: cache, data: result.originalData, key: imageResource.cacheKey)
        
        
        return cache.cachePath(forKey: imageResource.cacheKey)
        //        return result.originalData
    }
    
    
    
    /// 为 Notification Content 设置ICON
    /// - Parameter bestAttemptContent: 要设置的 Notification Content
    /// - Returns: 返回设置ICON后的 Notification Content
    fileprivate func setIcon(content bestAttemptContent: UNMutableNotificationContent) async -> UNMutableNotificationContent {
        if #available(iOSApplicationExtension 15.0, *) {
            
            
            let userInfo = bestAttemptContent.userInfo
            
            guard let imageUrl = userInfo["icon"] as? String,
                  toolsManager.startsWithHttpOrHttps(imageUrl),
                  let imageFileUrl = await downloadImage(imageUrl,bestAttemptContent) else {
                return bestAttemptContent
            }
            
            
            
            var personNameComponents = PersonNameComponents()
            personNameComponents.nickname = bestAttemptContent.title
            
            let avatar = INImage(imageData: NSData(contentsOfFile: imageFileUrl)! as Data)
            let senderPerson = INPerson(
                personHandle: INPersonHandle(value: "", type: .unknown),
                nameComponents: personNameComponents,
                displayName: personNameComponents.nickname,
                image: avatar,
                contactIdentifier: nil,
                customIdentifier: nil,
                isMe: false,
                suggestionType: .none
            )
            let mePerson = INPerson(
                personHandle: INPersonHandle(value: "", type: .unknown),
                nameComponents: nil,
                displayName: nil,
                image: nil,
                contactIdentifier: nil,
                customIdentifier: nil,
                isMe: true,
                suggestionType: .none
            )
            
            let intent = INSendMessageIntent(
                recipients: [mePerson],
                outgoingMessageType: .outgoingMessageText,
                content: bestAttemptContent.body,
                speakableGroupName: INSpeakableString(spokenPhrase: personNameComponents.nickname ?? ""),
                conversationIdentifier: bestAttemptContent.threadIdentifier,
                serviceName: nil,
                sender: senderPerson,
                attachments: nil
            )
            
            intent.setImage(avatar, forParameterNamed: \.sender)
            
            let interaction = INInteraction(intent: intent, response: nil)
            interaction.direction = .incoming
            
            try? await interaction.donate()
            
            do {
                let content = try bestAttemptContent.updating(from: intent) as! UNMutableNotificationContent
                return content
            }
            catch {
#if DEBUG
                print(error)
#endif
              
            }
            
            return bestAttemptContent
        }
        else {
            return bestAttemptContent
        }
    }
    
}
