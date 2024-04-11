//
//  RealmManager.swift
//  NewBear
//
//  Created by He Cho on 2024/4/4.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    var realm: Realm?

    private init() {
        realm = try? Realm()
    }
    
    func getUnreadCount()-> Int?{
        return self.getObject()?.where({!$0.isRead}).count
    }

    // Create
    func addObject(_ object: NotificationMessage) -> Bool {
        guard let realm = realm else { return false }
        do {
            try realm.write {
                realm.add(object)
            }
            return true
        } catch {
            return false
        }
    }

    // Read
    func getObject() -> Results<NotificationMessage>? {
        guard let realm = realm else { return nil }
        return realm.objects(NotificationMessage.self)
    }

    // Update
    func updateObject(_ object: NotificationMessage, with updates: (NotificationMessage) -> Void) -> Bool {
        guard let realm = realm else { return false }
        do {
            try realm.write {
                let objectToUpdate = object.isFrozen ? object.thaw() : object
                if let objectToUpdate = objectToUpdate {
                    updates(objectToUpdate)
                }
            }
            return true
        } catch {
            return false
        }
    }
    
    func readMessage(_ results: Results<NotificationMessage>){
        let _ = self.updateObjects(results) { value in
            if let isRead = value?.isRead,!isRead{
                value?.isRead = true
            }
        }
    }
    
    
    
    func updateObjects(_ results: Results<NotificationMessage>?, with updates: (NotificationMessage?) -> Void) -> Bool {
        guard let realm = realm else { return false }
        
        if let datas = results{
            do {
                try realm.write {
                    for object in datas {
                        let data = realm.objects(NotificationMessage.self).where({$0.id == object.id}).first
                        updates(data)
                    }
                }
                return true
            } catch {
                return false
            }
        }
        return false
        
    }

    // Delete
    func deleteObject(_ object: NotificationMessage?) -> Bool {
        guard let realm = realm else { return false }
        if let data = object{
            do {
                try realm.write {
                    let item = realm.objects(NotificationMessage.self).where({$0.id == data.id})
                    realm.delete(item)
                }
                return true
            } catch {
                return false
            }
        }
       return false
    }
    
    func deleteObjects<T: Object>(_ objects: Results<T>?) -> Bool {
        guard let realm = realm else { return false }
        if let datas = objects{
            do {
                try realm.write {
                    realm.delete(datas)
                }
                return true
            } catch {
                return false
            }
        }
       return false
    }
    
    func allRead(){
        let alldata = self.getObject()?.where({!$0.isRead})
        let _ = self.updateObjects(alldata){data in
            data?.isRead = true
        }
    }
    func allDel(_ mode: Int = 0) {
        switch mode {
        case 0:
            let alldata = self.getObject()?.where({$0.isRead})
            let _ = self.deleteObjects(alldata)
        case 1:
            let alldata = self.getObject()?.where({!$0.isRead})
            let _ = self.deleteObjects(alldata)
        case 3:
            let _ = self.deleteObjects(self.getObject())
        default:
            break
        }
    }
    
    func delByGroup(_ group:String){
        let datas = self.getObject()?.where({$0.group == group})
        let _ = self.deleteObjects(datas)
    }
    
    func createMessage(message:NotificationMessage){
        guard let realm = realm else { return }
        
       do{
            try realm.write{
                realm.add(message)
            }
        }catch{
            debugPrint(error)
        }
    }

}
