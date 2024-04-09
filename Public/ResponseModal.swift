//
//  ResponseModal.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import Foundation

struct baseResponse<T:Codable>:Codable{
    var code:Int
    var message:String
    var data:T
}



struct DeviceInfo: Codable {
    var deviceKey: String
    var deviceToken: String
    var pawKey: String

    // 使用 `CodingKeys` 枚举来匹配 JSON 键和你的变量命名
    enum CodingKeys: String, CodingKey {
        case deviceKey = "device_key"
        case deviceToken = "device_token"
        case pawKey = "key"
    }
}


struct ServersForSync:Codable{
    var key,url:String
}
