//
//  MessageModal.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI
import RealmSwift
import Foundation
import CloudKit
import UIKit


final class NotificationMessage: Object , ObjectKeyIdentifiable{
    @Persisted var id:String = UUID().uuidString
    @Persisted var title:String?
    @Persisted var body:String?
    @Persisted var icon:String?
    @Persisted var group:String?
    @Persisted var createDate = Date()
    @Persisted var isRead:Bool = false
    @Persisted var url:String?
    @Persisted var cloud:Bool = false
    @Persisted var markdown:String?
    @Persisted var pushId:String?
    
}



extension NotificationMessage: Codable{
    enum CodingKeys: String, CodingKey {
        case id, title, body, icon, group, createDate, isRead, url,cloud,markdown,pushId
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encodeIfPresent(group, forKey: .group)
        try container.encodeIfPresent(createDate, forKey: .createDate)
        try container.encodeIfPresent(isRead, forKey: .isRead)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(cloud, forKey: .cloud)
        try container.encodeIfPresent(markdown, forKey: .markdown)
        try container.encodeIfPresent(pushId, forKey: .pushId)
    }
   
}

extension NotificationMessage{
    static let messages = [
       
        NotificationMessage(value: ["title":  NSLocalizedString("messageExampleTitle1",comment: ""),"group":  NSLocalizedString("messageExampleGroup1",comment: ""),"body": NSLocalizedString("messageExampleBody1",comment: ""),"icon":"warn","image":otherUrl.defaultImage,"cloud":true]),
        NotificationMessage(value: ["title":NSLocalizedString("messageExampleTitle2",comment: ""),"group":NSLocalizedString("messageExampleGroup2",comment: ""),"body":NSLocalizedString("messageExampleBody2",comment: ""),"icon":otherUrl.defaultImage,"cloud":true]),
        NotificationMessage(value: ["group":NSLocalizedString("messageExampleGroup3",comment: ""),"title":NSLocalizedString("messageExampleTitle3",comment: "") ,"body":NSLocalizedString("messageExampleBody3",comment: ""),"url":"weixin://","icon":"weixin","cloud":true])
    ]
}

extension NotificationMessage {
    // 可以添加一个便利构造器或修改现有构造器来支持从CKRecord初始化
    convenience init(from record: CKRecord) {
        self.init()
        self.id = record.recordID.recordName
        self.title = record["title"] as? String
        self.body = record["body"] as? String
        self.icon = record["icon"] as? String
        self.group = record["group"] as? String ?? NSLocalizedString("unknown",comment: "")
        self.createDate = record["createDate"] as? Date ?? Date()
        self.isRead = record["isRead"] as? Bool ?? true
        self.url = record["url"] as? String
        self.cloud = record["cloud"] as? Bool ?? true
        self.markdown = record["markdown"] as? String
        self.pushId = record["pushId"] as? String
    }
    
    
    

}

extension NotificationMessage{
    
    // 将Message转换为CKRecord
    func createCKRecord() -> CKRecord {
        let record = CKRecord(recordType: settings.recordType, recordID: CKRecord.ID(recordName: self.id))
        record["title"] = self.title
        record["body"] = self.body
        record["icon"] = self.icon
        record["group"] = self.group
        record["createDate"] = self.createDate
        record["isRead"] = self.isRead
        record["url"] = self.url
        record["cloud"] = true
        record["markdown"] = self.markdown
        record["pushId"] = self.pushId
        return record
    }
    
    
    
}



