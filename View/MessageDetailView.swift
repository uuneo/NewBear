//
//  GroupMessageSolo.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI
import RealmSwift

struct MessageDetailView: View {
    var messages:Results<NotificationMessage>
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @State private var toastText:String = ""
    @State private var pageNumber:Int = 1
    var showMsgCount:Int{
        min(pageNumber * 10, messages.count)
    }
    var body: some View {
        
        List {
            ForEach(messages.prefix( showMsgCount ), id: \.id) { message in
                    MessageItem(message: message)
                        .swipeActions(edge: .leading) {
                            Button {
                                let _ = RealmManager.shared.updateObject(message) { item2 in
                                    item2.isRead = !item2.isRead
                                    
                                    
                                    self.toastText = NSLocalizedString("messageModeChanged", comment: "")
                                  
                                }
                            } label: {
                                Label(message.isRead ? NSLocalizedString("markNotRead",comment: "") :  NSLocalizedString("markRead",comment: ""), systemImage: message.isRead ? "envelope.open": "envelope")
                            }.tint(.blue)
                        }
                        .onAppear{
                            if message == messages.prefix( showMsgCount ).last {
                                self.pageNumber += 1
                            }
                        }
                    
            }.onDelete { IndexSet in
                for k in IndexSet{
                   let _ =  RealmManager.shared.deleteObject(messages[k])
                }
            }
                
            }
        .toolbar{
            ToolbarItem {
                HStack{
                    Text("\(showMsgCount)")
                    Text("/")
                    Text("\(messages.count)")
                }.font(.caption)
            }
        }
           
            .toast(info: $toastText)
            .onChange(of: messages) { value in
                if value.count <= 0 {
                    dismiss()
                }
            }.onAppear{
                
                let notReadMessages = messages.where({!$0.isRead})
                
                if notReadMessages.count > 0{
                    DispatchQueue.global().async {
                        // 获取后台线程上的 Realm 实例
                        let backgroundRealm = try! Realm()
                        do{
                            try backgroundRealm.write {
                                for k in notReadMessages{
                                    if let item =  backgroundRealm.thaw(k){
                                        item.isRead = true
                                    }
                                   
                                }
                            }
                        }catch{
                            debugPrint(error)
                        }
                       
                    }
                }
                
              
               
            }
        
    }
}

#Preview {
    MessageDetailView(messages: RealmManager.shared.getObject()!)
}
