//
//  Enums+.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import Foundation
import SwiftUI
import UIKit
import CryptoSwift


enum badgeAutoMode:String, CaseIterable {
    case auto = "Auto"
    case custom = "Custom"
}


enum appIcon:String,CaseIterable{
    case def = "AppIcon"
    case zero = "AppIcon0"
    case one = "AppIcon1"
    case two = "AppIcon2"
    case three = "AppIcon3"
    case four = "AppIcon4"
    case five = "AppIcon5"
    case six = "AppIcon6"
    case seven = "AppIcon7"
    
    static let arr = [appIcon.def,appIcon.zero,appIcon.one,appIcon.two,appIcon.three,appIcon.four,appIcon.five,appIcon.six,appIcon.seven]
    
    var toLogoImage: String{
        switch self {
        case .def:
            logoImage.def.rawValue
        case .zero:
            logoImage.zero.rawValue
        case .one:
            logoImage.one.rawValue
        case .two:
            logoImage.two.rawValue
        case .three:
            logoImage.three.rawValue
        case .four:
            logoImage.four.rawValue
        case .five:
            logoImage.five.rawValue
        case .six:
            logoImage.six.rawValue
        case .seven:
            logoImage.seven.rawValue
        }
    }
}


enum logoImage:String,CaseIterable{
    case def = "logo"
    case zero = "logo0"
    case one = "logo1"
    case two = "logo2"
    case three = "logo3"
    case four = "logo4"
    case five = "logo5"
    case six = "logo6"
    case seven = "logo7"
    static let arr = [logoImage.def,logoImage.zero,logoImage.one,logoImage.two,logoImage.three,logoImage.four,logoImage.five,logoImage.six,logoImage.seven]
    
    
}


enum saveType:String{
    case failUrl
    case failSave
    case failAuth
    case success
    case other
}

extension saveType {

    var localized: String {
        switch self {
        case .failUrl:
            return NSLocalizedString(self.rawValue, comment: "Url错误")
        case .failSave:
            return NSLocalizedString("failSave", comment: "Save failed")
        case .failAuth:
            return NSLocalizedString("failAuth", comment: "No permission")
        case .success:
            return NSLocalizedString("saveSuccess", comment: "Save successful")
        case .other:
            return NSLocalizedString("failOther", comment: "Other error")
        }
    }
}



enum Algorithm: String, CaseIterable {
    case aes128 = "AES128"
    case aes192 = "AES192"
    case aes256 = "AES256"

    var modes: [String] {
        switch self {
        case .aes128, .aes192, .aes256:
            return ["CBC", "ECB", "GCM"]
        }
    }

    var paddings: [String] {
        switch self {
        case .aes128, .aes192, .aes256:
            return ["pkcs7"]
        }
    }

    var keyLength: Int {
        switch self {
        case .aes128:
            return 16
        case .aes192:
            return 24
        case .aes256:
            return 32
        }
    }
}

enum MyError: Error {
    case customError(description: String)
}

struct AESCryptoModel {
    let key: String
    let mode: BlockMode
    let padding: Padding
    let aes: AES
    
    
    init(cryptoFields: CryptoSettingFields) throws {
        
       
        guard let algorithm = Algorithm(rawValue: cryptoFields.algorithm) else {
            throw MyError.customError(description: "Invalid algorithm")
        }
        
        let key = cryptoFields.key
        if key == ""{
            throw MyError.customError(description: "Key is missing")
        }

        guard algorithm.keyLength == key.count else {
            throw MyError.customError(description: String(format: NSLocalizedString("enterKey", comment: ""), algorithm.keyLength))
        }
        

        var iv = ""
        if ["CBC", "GCM"].contains(cryptoFields.mode) {
            var expectIVLength = 0
            if cryptoFields.mode == "CBC" {
                expectIVLength = 16
            }
            else if cryptoFields.mode == "GCM" {
                expectIVLength = 12
            }

            let ivField = cryptoFields.iv
            
            if  ivField.count == expectIVLength {
                iv = ivField
            }
            else {
                throw MyError.customError(description: String(format: NSLocalizedString("enterIv", comment: ""), expectIVLength))
            }
        }

        let mode: BlockMode
        switch cryptoFields.mode {
        case "CBC":
            mode = CBC(iv: iv.bytes)
        case "ECB":
            mode = ECB()
        case "GCM":
            mode = GCM(iv: iv.bytes)
        default:
            throw MyError.customError(description: "Invalid Mode")
        }

        self.key = key
        self.mode = mode
        self.padding = Padding.pkcs7
        self.aes = try AES(key: key.bytes, blockMode: self.mode, padding: self.padding)
    }

    func encrypt(text: String) throws -> String {
        return try aes.encrypt(Array(text.utf8)).toBase64()
    }

    func decrypt(ciphertext: String) throws -> String {
        return String(data: Data(try aes.decrypt(Array(base64: ciphertext))), encoding: .utf8) ?? ""
    }
}



enum MessageGroup:String{
    case group = "分组"
    case all = "全部"
}
enum mesAction: String{
    case markRead = "全部标为已读"
    case lastHour = "一小时前"
    case lastDay = "一天前"
    case lastWeek = "一周前"
    case lastMonth = "一月前"
    case allTime = "所有时间"
}





enum QuickAction{
    static var selectAction:UIApplicationShortcutItem?
    
    static var allReaduserInfo:[String: NSSecureCoding]{
        ["name":"allread" as NSSecureCoding]
    }
    
    static var allDelReaduserInfo:[String: NSSecureCoding]{
        ["name":"alldelread" as NSSecureCoding]
    }
    
    static var allDelNotReaduserInfo:[String: NSSecureCoding]{
        ["name":"alldelnotread" as NSSecureCoding]
    }
    
    static var allShortcutItems = [
        UIApplicationShortcutItem(
            type: "allread",
            localizedTitle: NSLocalizedString("readAllQuickAction", comment: "已读全部") ,
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(systemImageName: "bookmark"),
            userInfo: allReaduserInfo
        ),
        UIApplicationShortcutItem(
            type: "alldelread",
            localizedTitle: NSLocalizedString("delReadAllQuickAction", comment: "删除全部已读"),
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(systemImageName: "trash"),
            userInfo: allDelReaduserInfo
        ),
        UIApplicationShortcutItem(
            type: "alldelnotread",
            localizedTitle: NSLocalizedString("delNotReadAllQuickAction", comment: "删除全部未读"),
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(systemImageName: "trash"),
            userInfo: allDelNotReaduserInfo
        )
    ]
}


enum requestHeader :String {
    case https = "https://"
    case http = "http://"
}
