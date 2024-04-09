//
//  GroupMessageSolo.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import SwiftUI
import RealmSwift

struct MessageDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    var groupName: String
    @ObservedResults var messages: Results<NotificationMessage>
    
    init(groupName: String) {
        self.groupName = groupName
        self._messages = ObservedResults(
            NotificationMessage.self, where: { $0.group == groupName },
            sortDescriptor: SortDescriptor(keyPath: "createDate", ascending: false)
        )
    }
   
    @State private var toastText:String = ""
    var body: some View {
        
        List {
                ForEach(messages, id: \.id) { message in
                    MessageItem(message: message)
                        .swipeActions(edge: .leading) {
                            Button {
                                let _ = RealmManager.shared.updateObject(message) { item2 in
                                    item2.isRead = !item2.isRead
                                    self.toastText = NSLocalizedString("messageModeChanged",comment: "")
                                }
                            } label: {
                                Label(message.isRead ? NSLocalizedString("markNotRead",comment: "") :  NSLocalizedString("markRead",comment: ""), systemImage: message.isRead ? "envelope.open": "envelope")
                            }.tint(.blue)
                        }
                    
                }.onDelete(perform: $messages.remove)
                
            }
            .navigationTitle(groupName)
            .toast(info: $toastText)
            .onChange(of: messages) { value in
                if value.count <= 0 {
                    dismiss()
                }
            }
        
        
    }
}

#Preview {
    MessageDetailView(groupName: "abc")
}
