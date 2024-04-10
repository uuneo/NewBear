//
//  ConstantConfig.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import Foundation


let defaultStore = UserDefaults(suiteName: settings.groupName)


struct otherUrl {
#if DEBUG
    static let defaultServer = "https://dev.twown.com"
#else
    static let defaultServer = "https://push.twown.com"
#endif
    static let docServer = "https://alarmpaw.twown.com"
    static let defaultImage = docServer + "/_media/avatar.jpg"
    static let helpWebUrl = docServer + "/#/tutorial"
    static let problemWebUrl = docServer + "/#/faq"
    static let delpoydoc = docServer + "/#/?id=alarmpaw"
    static let emailHelpUrl = docServer + "/#/email"
    static let helpRegisterWebUrl = docServer + "/#/registerUser"
    static let actinsRunUrl = "https://github.com/96bit/AlarmPaw/actions/runs/"
    static let musicUrl = "https://convertio.co/mp3-caf/"
    static let callback = defaultServer + "/callback"
}


struct settings {
    
    static let  groupName = "group.NewBear"
    static let  cloudMessageName = "NewBearMessageCloud"
    static let  settingName = "cryptoSettingFields"
    static let  deviceToken = "deviceToken"
    static let  imageCache = "shard"
    static let  badgemode = "NewBearbadgemode"
    static let  server = "serverArrayStroage"
    static let  defaultPage = "defaultPageViewShow"
    static let  messageFirstShow = "messageFirstShow"
    static let  messageShowMode = "messageShowMode"
    static let  syncServerUrl = "syncServerUrl"
    static let  syncServerParams = "syncServerParams"
    static let  emailConfig = "emailStmpConfig"
    static let  iCloudName = "iCloud.NewBear"
    static let  firstStartApp = "firstStartApp"
    static let  CryptoSettingFields = "CryptoSettingFields"
    static let  recordType = "NotificationMessage"
    static let  realmName = "NewBear.realm"
    static let realmModalVersion:UInt64 = 9
}
