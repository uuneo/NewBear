//
//  CryptoConfigView.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI

struct CryptoConfigView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage(settings.CryptoSettingFields,store: defaultStore) var cryptoFields:CryptoSettingFields = CryptoSettingFields.data
    @State var toastText:String = ""
    
    var expectKeyLength:Int {
        switch cryptoFields.algorithm{
        case Algorithm.aes128.rawValue:
            return 16
        case Algorithm.aes192.rawValue:
            return 24
        case Algorithm.aes256.rawValue:
            return 32
        default:
            return 16
        }
    }
    
    var modes = ["CBC", "ECB"]
    
    var body: some View {
        List {
            
            
            Section(header:Text("")){
                Picker(selection: $cryptoFields.algorithm, label: Text(NSLocalizedString("cryptoConfigAlgorithm", comment: "算法"))) {
                    ForEach(Algorithm.allCases,id: \.self){item in
                        Text(item.rawValue).tag(item.rawValue)
                    }
                }
            }
            
            Section {
                Picker(selection: $cryptoFields.mode, label: Text(NSLocalizedString("cryptoConfigMode", comment: "模式"))) {
                    ForEach(modes,id: \.self){item in
                        Text(item).tag(item)
                    }
                }
            }
            
            Section {
                Picker(selection: $cryptoFields.padding, label: Text("Padding")) {
                    Text("pkcs7").tag("pkcs7")
                }
            }
            
            Section {
                
                HStack{
                    Label {
                        Text("Key：")
                    } icon: {
                        Image(systemName: "key")
                    }
                    Spacer()
                    TextField(String(format: NSLocalizedString("cryptoConfigKey", comment: "输入\(expectKeyLength)位数的key"), expectKeyLength), text: $cryptoFields.key)
                        .onDisappear{
                            let _ = verifyKey()
                        }
                    
                }
                
                
                
            }
            
            
            Section {
                
                
                HStack{
                    Label {
                        Text("Iv：")
                    } icon: {
                        Image(systemName: "dice")
                    }
                    Spacer()
                    TextField(NSLocalizedString("cryptoConfigIv", comment: "请输入16位Iv"), text: $cryptoFields.iv)
                        .onDisappear{
                            let _ = verifyIv()
                        }
                }
                
                
            }
            
            
            
            HStack{
                Spacer()
                Button {
                    createCopyText()
                } label: {
                    Text(NSLocalizedString("cryptoConfigCopyTitle", comment: "复制发送脚本"))
                        .padding(.horizontal)
                    
                }.buttonStyle(BorderedProminentButtonStyle())
                
                
                
                Spacer()
            } .listRowBackground(Color.clear)
            
            
            
            
            
            
        }.navigationTitle(NSLocalizedString("cryptoConfigNavTitle", comment: "算法配置"))
            .toolbar{
                ToolbarItem {
                    Button {
                        if verifyKey() && verifyIv(){
                           
                            toolsManager.async_set_localString("cryptoConfigSuccess", "验证成功"){text in
                                self.toastText = text
                            }
                            
                           
                        }
                    } label: {
                        Text(NSLocalizedString("cryptoConfigVerify", comment: "验证"))
                    }
                    
                }
            }.toast(info: $toastText)
        
    }
    func verifyKey()-> Bool{
        if cryptoFields.key.count != expectKeyLength{
            cryptoFields.key = ""
            toolsManager.async_set_localString("cryptoConfigKeyFail", "Key参数长度不正确"){text in
                self.toastText = text
            }
            return false
        }
        return true
    }
    
    func verifyIv() -> Bool{
        if cryptoFields.iv.count != 16 {
            cryptoFields.iv = ""
           
            toolsManager.async_set_localString("cryptoConfigIvFail", "Iv参数长度不正确"){text in
                self.toastText = text
            }
            return false
        }
        return true
    }
    
    
    func createCopyText(){
        
        if !verifyIv() {
            cryptoFields.iv = self.randomString(length: 16)
        }
        
        if !verifyKey(){
            cryptoFields.key = self.randomString(length: expectKeyLength)
        }
        
    
        
        let text = """
                    # Documentation: \(NSLocalizedString("encryptionUrl",comment: ""))
                    # python demo: 使用AES加密数据，并发送到服务器
                    # pip3 install pycryptodome
                    
                    import json
                    import base64
                    import requests
                    from Crypto.Cipher import AES
                    from Crypto.Util.Padding import pad
                    
                    
                    def encrypt_AES_CBC(data, key, iv):
                        cipher = AES.new(key, AES.MODE_\(cryptoFields.mode.uppercased()), iv)
                        padded_data = pad(data.encode(), AES.block_size)
                        encrypted_data = cipher.encrypt(padded_data)
                        return encrypted_data
                    
                    
                    # JSON数据
                    json_string = json.dumps({"body": "test", "sound": "birdsong"})
                    
                    # \(String(format: NSLocalizedString("keyComment",comment: ""), Int(cryptoFields.algorithm.suffix(3))! / 8))
                    key = b"\(cryptoFields.key)"
                    # \(NSLocalizedString("ivComment",comment: ""))
                    iv= b"\(cryptoFields.iv)"
                    
                    # 加密
                    # \(NSLocalizedString("consoleComment",comment: "")) "\((try? AESCryptoModel(cryptoFields: cryptoFields).encrypt(text: "{\"body\": \"test\", \"sound\": \"birdsong\"}")) ?? "")"
                    encrypted_data = encrypt_AES_CBC(json_string, key, iv)
                    
                    # 将加密后的数据转换为Base64编码
                    encrypted_base64 = base64.b64encode(encrypted_data).decode()
                    
                    print("加密后的数据（Base64编码）：", encrypted_base64)
                    
                    deviceKey = '\(pawManager.shared.servers[0].key)'
                    
                    res = requests.get(f"\(pawManager.shared.servers[0].url)/{deviceKey}/test",
                                       params={"ciphertext": encrypted_base64, "iv": iv})
                    
                    print(res.text)
                    
                    """
        
        pawManager.shared.copy(text: text)
        toolsManager.async_set_localString("copySuccessText", "复制成功"){text in
            self.toastText = text
        }
    }
    
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}

#Preview {
    NavigationStack{
        CryptoConfigView()
    }
}
