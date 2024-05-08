//
//  String+.swift
//  NewBear
//
//  Created by He Cho on 2024/5/8.
//

import Foundation


extension String{
    func removeHTTPPrefix() -> String {
        var cleanedURL = self
        if cleanedURL.hasPrefix("http://") {
            cleanedURL = cleanedURL.replacingOccurrences(of: "http://", with: "")
        } else if cleanedURL.hasPrefix("https://") {
            cleanedURL = cleanedURL.replacingOccurrences(of: "https://", with: "")
        }
        return cleanedURL
    }
}
