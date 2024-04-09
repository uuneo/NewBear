//
//  CryptoSettings.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import Foundation



struct CryptoSettingFields: Codable,Equatable {
    var algorithm: String
    var mode: String
    var padding: String
    var key: String
    var iv: String
    
    
    init(algorithm: String, mode: String, padding: String, key: String, iv: String) {
        self.algorithm = algorithm
        self.mode = mode
        self.padding = padding
        self.key = key
        self.iv = iv
    }
    
    enum CodingKeys: CodingKey {
        case algorithm
        case mode
        case padding
        case key
        case iv
    }
    

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.algorithm = try container.decode(String.self, forKey: .algorithm)
        self.mode = try container.decode(String.self, forKey: .mode)
        self.padding = try container.decode(String.self, forKey: .padding)
        self.key = try container.decode(String.self, forKey: .key)
        self.iv = try container.decode(String.self, forKey: .iv)
    }
    
   
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.algorithm, forKey: .algorithm)
        try container.encode(self.mode, forKey: .mode)
        try container.encode(self.padding, forKey: .padding)
        try container.encode(self.key, forKey: .key)
        try container.encode(self.iv, forKey: .iv)
    }
    
    
    static let data = CryptoSettingFields(algorithm: "AES128", mode: "CBC", padding: "pkcs7", key: "",iv: "")
}

extension CryptoSettingFields: RawRepresentable{
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8) ,
              let result = try? JSONDecoder().decode(
                Self.self,from: data) else{
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let result = try? JSONEncoder().encode(self),
              let string = String(data: result, encoding: .utf8) else{
            return ""
        }
        return string
    }
}
