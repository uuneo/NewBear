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
                            self.toastText = NSLocalizedString("cryptoConfigSuccess", comment: "验证成功")
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
            self.toastText = NSLocalizedString("cryptoConfigKeyFail", comment: "Key参数长度不正确")
            return false
        }
        return true
    }
    
    func verifyIv() -> Bool{
        if cryptoFields.iv.count != 16 {
            cryptoFields.iv = ""
            self.toastText = NSLocalizedString("cryptoConfigIvFail", comment: "Iv参数长度不正确")
            return false
        }
        return true
    }
    
    
    func createCopyText(){
        if cryptoFields.iv == "" || cryptoFields.key == ""{
            self.toastText = NSLocalizedString("cryptoConfigParamsFail", comment: "参数不全")
            return
        }
        let text =   """
                    #!/usr/bin/env bash
                    
                    # Documentation: \(NSLocalizedString("encryptionUrl",comment: ""))
                    
                    set -e
                    
                    # bark key
                    deviceKey='\(pawManager.shared.deviceToken)'
                    # push payload
                    json='{"body": "test", "sound": "birdsong"}'
                    
                    # \(String(format: NSLocalizedString("keyComment",comment: ""), Int(cryptoFields.algorithm.suffix(3))! / 8))
                    key='\(pawManager.shared.servers[0].key)'
                    # \(NSLocalizedString("ivComment",comment: ""))
                    iv='\(cryptoFields.iv)'
                    
                    # \(NSLocalizedString("opensslEncodingComment",comment: ""))
                    key=$(printf $key | xxd -ps -c 200)
                    iv=$(printf $iv | xxd -ps -c 200)
                    
                    ciphertext=$(echo -n $json | openssl enc -aes-\(cryptoFields.algorithm.suffix(3))-\(cryptoFields.mode.lowercased()) -K $key \(cryptoFields.iv.count > 0 ? "-iv $iv " : "")| base64)
                    
                    # \(NSLocalizedString("consoleComment",comment: "")) "\((try? AESCryptoModel(cryptoFields: cryptoFields).encrypt(text: "{\"body\": \"test\", \"sound\": \"birdsong\"}")) ?? "")"
                    echo $ciphertext
                    
                    # \(NSLocalizedString("ciphertextComment",comment: ""))
                    curl --data-urlencode "ciphertext=$ciphertext"\( cryptoFields.iv.count == 0 ? "" : " --data-urlencode \"iv=\(cryptoFields.iv)\"") \(pawManager.shared.servers[0].url)/$deviceKey
                    """
        
        pawManager.shared.copy(text: text)
        self.toastText = NSLocalizedString("copySuccessText", comment: "复制成功")
    }
}

#Preview {
    NavigationStack{
        CryptoConfigView()
    }
}
