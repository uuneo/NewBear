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
            ForEach(messages.suffix( showMsgCount ), id: \.id) { message in
                    MessageItem(message: message)
                        .swipeActions(edge: .leading) {
                            Button {
                                let _ = RealmManager.shared.updateObject(message) { item2 in
                                    item2.isRead = !item2.isRead
                                    
                                    toolsManager.async_set_localString( "messageModeChanged") { text in
                                        self.toastText = text
                                    }
                                  
                                }
                            } label: {
                                Label(message.isRead ? NSLocalizedString("markNotRead",comment: "") :  NSLocalizedString("markRead",comment: ""), systemImage: message.isRead ? "envelope.open": "envelope")
                            }.tint(.blue)
                        }
                        .onAppear{
                            if message == messages.last {
                                self.pageNumber += 1
                            }
                        }
                    
            }.onDelete { IndexSet in
                for k in IndexSet{
                   let _ =  RealmManager.shared.deleteObject(messages[k])
                }
            }
                
            }
           
            .toast(info: $toastText)
            .onChange(of: messages) { value in
                if value.count <= 0 {
                    dismiss()
                }
            }.onDisappear{
                RealmManager.shared.readMessage(messages)
            }
        
    }
}

#Preview {
    MessageDetailView(messages: RealmManager.shared.getObject()!)
}
