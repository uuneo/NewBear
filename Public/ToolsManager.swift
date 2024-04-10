//
//  Tools.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//


import Foundation
import SwiftSMTP

struct toolsManager{
    
    static func startsWithHttpOrHttps(_ urlString: String) -> Bool {
        let pattern = "^(http|https)://.*"
        let test = NSPredicate(format:"SELF MATCHES %@", pattern)
        return test.evaluate(with: urlString)
    }
    
    
    static func scanModeAndString(_ urlString: String) -> (String, String){
        
        
        if urlString.hasPrefix("add:"){
            let prefixRemoved = String(urlString.dropFirst(4))
            if self.isValidURL(prefixRemoved){
                return ("add", prefixRemoved)
            }
        }else if urlString.hasPrefix("config:"){
            let prefixRemoved = String(urlString.dropFirst(7))
            if self.isValidURL(prefixRemoved){
                return ("config", prefixRemoved)
            }
        }
        return ("", "")
    }
    
    
    
    static  func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false // 无效的URL格式
        }
        
        // 验证协议头是否是http或https
        guard let scheme = url.scheme, ["http", "https"].contains(scheme.lowercased()) else {
            return false
        }
        
        // 验证是否有足够的点分隔符
        let components = url.host?.components(separatedBy: ".")
        return components?.count ?? 0 >= 2
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    
    static func sendMail(config:emailConfig,title:String,text:String){
        
        let smtp = SMTP(
            hostname: config.smtp,     // SMTP server address
            email: config.email,        // username to login
            password: config.password   // password to login
            // "illozqrqvcshbahi"
        )
        
        let mail = Mail(
            from: Mail.User(name: "NewBear", email: "909038822@qq.com"),
            to: config.toEmail.map({Mail.User(name: "NewBear", email: $0.mail)}),
            subject: title,
            text:text
        )
        
        smtp.send(mail) { (error) in
            
#if DEBUG
            debugPrint(error as Any)
#endif
            
            
        }
    }
    
    
    static  func sendMail(config:emailConfig,title:String,text:String, completionHandler: @escaping (Error?) -> Void){
        
        let smtp = SMTP(
            hostname: config.smtp,     // SMTP server address
            email: config.email,        // username to login
            password: config.password   // password to login
            // "illozqrqvcshbahi"
        )
        
        let mail = Mail(
            from: Mail.User(name: "NewBear", email: "909038822@qq.com"),
            to: config.toEmail.map({Mail.User(name: "NewBear", email: $0.mail)}),
            subject: title,
            text:text
        )
        
        smtp.send(mail) { (error) in
            completionHandler(error)
        }
        
    }
    
    // MARK: 防止阻塞主线程
    static func async_set_localString(_ key:String,_ comment: String = "",_ block: @escaping (_ text:String) -> ()) {
        Task{
            let text = NSLocalizedString(key, comment: comment)
            DispatchQueue.main.sync {
                block(text)
            }
        }
    }
    
    
    static func getGroup(_ group:String?)->String{
        return group ?? NSLocalizedString("defaultGroup",comment: "")
    }

    
}





