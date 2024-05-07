//
//  emailPageView.swift
//  NewBear
//
//  Created by He Cho on 2024/5/7.
//

import SwiftUI
import SwiftSMTP

struct emailPageView: View {
    @EnvironmentObject var paw:pawManager
    @State var showLoading:Bool = false
    @State var toastText:String = ""
    var body: some View {
        List{
            
            HStack{
                
                Text( NSLocalizedString("mailTestTips", comment: "主题包含: NewBear"))
                    .font(.caption2)
                Spacer()
                Button{
                    self.removeFailToEmail()
                    self.showLoading = true
                    paw.dispatch_async_queue{
                        toolsManager.sendMail(config: paw.email, title:   NSLocalizedString("toMailTestTitle", comment: "自动化: NewBear"), text:NSLocalizedString("toMailTestText", comment:  "{title:\"标题\",...}")){ error in
                            
                           
                            
                            
                            if error != nil {
                                
                                self.toastText = NSLocalizedString("sendMailFail", comment:  "调用失败")
                            }else{
                                
                                self.toastText = NSLocalizedString("sendMailSuccess", comment:   "调用成功")
                            }
                            
                            
                            
                            
                            
                            paw.dispatch_sync_safely_main_queue {
                               
                                self.showLoading = false
                            }
                            
                        }
                    }
                   
                }label: {
                    if showLoading{
                        ProgressView()
                    }else{
                        Text(NSLocalizedString("sendMailTestBtn", comment:  "测试"))
                    }
                }
                .buttonStyle(BorderedButtonStyle())
                
                   
            }.listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section(header:Text(NSLocalizedString("emailConfigHeader", comment: "邮件服务器配置,本地化服务"))) {
                HStack{
                    Text("Smtp:")
                        .foregroundStyle(.gray)
                    TextField("smtp.qq.com", text: $paw.email.smtp)
                        .textFieldStyle(.roundedBorder)
                       
                }
                HStack{
                    Text("Email:")
                        .foregroundStyle(.gray)
                    TextField("@twown.com", text: $paw.email.email)
                        .textFieldStyle(.roundedBorder)
                      
                }
                HStack{
                    Text("Password:")
                        .foregroundStyle(.gray)
                    SecureField(NSLocalizedString("emailPasswordPl", comment: "请输入密码"), text: $paw.email.password)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            Section(header:Text(NSLocalizedString("tomailListHeader", comment: "接收邮件列表"))) {
                HStack{
                    Spacer()
                    Button{
                        paw.email.toEmail.insert(toEmailConfig(""), at: 0)
                    }label: {
                        Image(systemName: "plus.square.dashed")
                            .font(.headline)
                    }.buttonStyle(.borderless)
                }
                
                ForEach($paw.email.toEmail, id: \.id){item in
                    HStack{
                        Text("ToMail:")
                            .foregroundStyle(.gray)
                        TextField("@twown.com", text: item.mail)
                            .textFieldStyle(.roundedBorder)
                    }
                        
                }.onDelete(perform: { indexSet in
                    paw.email.toEmail.remove(atOffsets: indexSet)
                })
            }
            
           
            
            
        }.navigationTitle(NSLocalizedString("emailNavigationTitle", comment: "邮件自动化"))
            .toolbar {
                ToolbarItem {
                    Button{
                        pageState.shared.webUrl = otherUrl.emailHelpUrl
                        pageState.shared.fullPage = .web
                    }label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .toast(info: $toastText)
            .onDisappear{
                self.removeFailToEmail()
            }
            
    }
    
}
extension emailPageView{
    func removeFailToEmail(){
        paw.email.toEmail.removeAll(where: {!toolsManager.isValidEmail($0.mail)})
    }
}

#Preview {
    NavigationStack{
        emailPageView().environmentObject(pawManager.shared)
    }
}
