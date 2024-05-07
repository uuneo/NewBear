//
//  ContactsModal.swift
//  NewBear
//
//  Created by He Cho on 2024/5/4.
//

import Foundation
import RealmSwift

final class ContactsModal: Object , ObjectKeyIdentifiable{
    @Persisted var id:String = UUID().uuidString
    @Persisted var userKey:String
    @Persisted var userName:String
    @Persisted var createDate = Date()
    @Persisted var cloud:Bool = false
}
