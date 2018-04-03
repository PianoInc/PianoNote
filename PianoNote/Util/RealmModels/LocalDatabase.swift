//
//  LocalDatabase.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import RealmSwift

class LocalDatabase {
    static let shared = LocalDatabase()
    
    let databaseQueue = DispatchQueue.global(qos: .background)
    
    //This method is for creating object.
    func saveObject (newObject: Object, completion handler: (() -> Void)? = nil) {
        
        databaseQueue.async {
            autoreleasepool {
                guard let realm = try? Realm() else {/* fatal error */return}
                
                try? realm.write {
                    realm.add(newObject, update: true)
                }
                handler?()
            }
        }
    }
    
    
    //This method is for updating object.
    func updateObject(id: String, kv: [String: Any], type: Object.Type, completion handler: (() -> Void)? = nil) {
        databaseQueue.async {
            
            autoreleasepool {
                guard let realm = try? Realm(),
                    let object = realm.object(ofType: type.self, forPrimaryKey: id) else {return}
                
                try? realm.write {
                    object.setValuesForKeys(kv)
                }
                handler?()
            }
        }
    }
    
    //This method is for deleting object by reference.
    func deleteObject<T> (ref: ThreadSafeReference<T>, completion handler: (() -> Void)? = nil) where T: Object {
        
        databaseQueue.async {
            
            autoreleasepool {
                guard let realm = try? Realm(),
                    let object = realm.resolve(ref) else {/* fatal error */ return}
                
                try? realm.write {
                    realm.delete(object)
                }
                handler?()
            }
        }
    }

    //This method is for deleting objects.
    func deleteObject<T> (ref: ThreadSafeReference<Results<T>>, completion handler: (() -> Void)? = nil) where T: Object {
        
        databaseQueue.async {
            
            autoreleasepool {
                guard let realm = try? Realm(),
                    let object = realm.resolve(ref) else {/* fatal error */ return}
                
                try? realm.write {
                    realm.delete(object)
                }
                handler?()
            }
        }
    }
}

