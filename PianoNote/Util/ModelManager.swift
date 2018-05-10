//
//  ModelManager.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import CloudKit
import RealmSwift

class ModelManager {
    enum ModelManagerError: Error {
        case objectNotFound
    }
    
    static func saveNew(model: RealmTagsModel, completion: ((Error?) -> Void)? = nil) {
        let record = model.getRecord()
        
        LocalDatabase.shared.commit(action: { (realm) in
            try? realm.write{realm.add(model, update: true)}
        })

        CloudManager.shared.privateDatabase.upload(record: record) { (conflicted, error) in
            if let error = error {
                return completion?(error) ?? ()
            } else if let conflictedModel = conflicted?.parseRecord(isShared: false) {
                LocalDatabase.shared.commit(action: {realm in
                    try? realm.write{realm.add(conflictedModel, update: true)}
                })
            }
            completion?(nil)
        }
    }
    
    static func saveNew(model: RealmNoteModel, completion: ((Error?) -> Void)? = nil) {
        
        let record = model.getRecord()
        LocalDatabase.shared.commit(action: { realm in
            try? realm.write {realm.add(model, update: true)}
        })
        
        let cloudCompletion: (CKRecord?, Error?) -> Void = { (conflicted, error) in
            if let error = error {
                return completion?(error) ?? ()
            } else if let conflictedModel = conflicted?.parseRecord(isShared: false) {
                LocalDatabase.shared.commit(action: { realm in
                    try? realm.write {realm.add(conflictedModel, update: true)}
                })
            }
            completion?(nil)
        }
        CloudManager.shared.privateDatabase.upload(record: record, completion: cloudCompletion)
    }
    
    
    static func saveNew(model: RealmImageModel, completion: ((Error?) -> Void)? = nil) {
        
        let (url, record) = model.getRecord()
        LocalDatabase.shared.commit(action: { realm in
            try? realm.write{ realm.add(model, update: true) }
        })
        
        let database: RxCloudDatabase = model.isInSharedDB ? CloudManager.shared.sharedDatabase:
            CloudManager.shared.privateDatabase
        
        database.upload(record: record) { conflicted, error in
            if let error = error {
                return completion?(error) ?? ()
            }
            completion?(nil)
            try? FileManager.default.removeItem(at: url)
        }
    }
    
    static func delete(id: String, type: Object.Type, completion: ((Error?) -> Void)? = nil) {
        guard let realm = try? Realm(),
            let model = realm.object(ofType: type.self, forPrimaryKey: id),
            let recordable = model as? Recordable else {return}
        
        let ref = ThreadSafeReference(to: model)
        
        LocalDatabase.shared.commit(action: { realm in
            guard let object = realm.resolve(ref) else {return}
            try? realm.write {realm.delete(object)}
        })
        
        let cloudCompletion: (Error?) -> () = { error in
            if let error = error {completion?(error)}
            else {completion?(nil)}
        }
        let coder = NSKeyedUnarchiver(forReadingWith: recordable.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data polluted!!")}
        coder.finishDecoding()
        
        if recordable.isInSharedDB {
            CloudManager.shared.sharedDatabase.delete(recordIDs: [record.recordID], completion: cloudCompletion)
        } else {
            CloudManager.shared.privateDatabase.delete(recordIDs: [record.recordID], completion: cloudCompletion)
        }
    }
    
    static func update(id: String, type: Object.Type, kv: [String: Any], completion: ((Error?) -> Void)? = nil) {
        do {
            let realm = try Realm()
            guard let model = realm.object(ofType: type, forPrimaryKey: id)
                else {return completion?(ModelManagerError.objectNotFound) ?? () }
            
            let database: RxCloudDatabase = (model as? Recordable)!.isInSharedDB ? CloudManager.shared.sharedDatabase : CloudManager.shared.privateDatabase
            let isShared = database.database.databaseScope == .shared
            let ancestorRecord = (model as? Recordable)?.getRecord?()
            let ref = ThreadSafeReference(to: (model as Object))
            
            LocalDatabase.shared.commit(action: { realm in
                guard let model = realm.resolve(ref) else {return completion?(ModelManagerError.objectNotFound) ?? ()}
                try? realm.write { model.setValuesForKeys(kv) }
            }, completion: { error in
                print("I;m out")
                guard let realm = try? Realm(),
                    let model = realm.object(ofType: type.self, forPrimaryKey: id) as? (Object & Recordable),
                    let record = model.getRecord?()else {return completion?(ModelManagerError.objectNotFound) ?? ()}
                //TODO:If note & If is locked and pinned, Ignore it
                
                database.upload(record: record, ancestorRecord: ancestorRecord) { conflicted, error in
                    if let error = error {
                        return completion?(error) ?? ()
                    } else if let conflictedRecord = conflicted {
                        let newModel = conflictedRecord.parseRecord(isShared: isShared)
                        
                        if let safeModel = newModel {
                            LocalDatabase.shared.commit(action: { realm in
                                try? realm.write { realm.add(safeModel, update: true) }
                            })
                        }
                        completion?(nil)
                    } else {
                        completion?(nil)
                    }
                }
            })
        } catch { completion?(error) }
    }
    
    static func update(predicate: NSPredicate, type: Object.Type, kv: [String: Any], completion: ((Error?) -> Void)? = nil) {
        do {
            let realm = try Realm()
            let model = realm.objects(type).filter(predicate)
            
            let database: RxCloudDatabase = (model as? Recordable)!.isInSharedDB ? CloudManager.shared.sharedDatabase : CloudManager.shared.privateDatabase
            let isShared = database.database.databaseScope == .shared
            
            let ref = ThreadSafeReference(to: model)
            
            LocalDatabase.shared.commit(action: { realm in
                guard let model = realm.resolve(ref) else {return completion?(ModelManagerError.objectNotFound) ?? ()}
                try? realm.write { model.setValuesForKeys(kv) }
            }, completion: { error in
                print("I;m out")
                guard let realm = try? Realm() else {return completion?(ModelManagerError.objectNotFound) ?? ()}
                let model = realm.objects(type).filter(predicate)
                var records: [CKRecord] = []
                model.forEach {
                    guard let record = ($0 as? Recordable)?.getRecord?() else {return}
                    records.append(record)
                }
                
                database.upload(records: records) { conflicted, error in
                    if let error = error {
                        return completion?(error) ?? ()
                    } else if let conflictedRecord = conflicted {
                        let newModel = conflictedRecord.parseRecord(isShared: isShared)
                        
                        if let safeModel = newModel {
                            LocalDatabase.shared.commit(action: { realm in
                                try? realm.write { realm.add(safeModel, update: true) }
                            })
                        }
                        completion?(nil)
                    } else {
                        completion?(nil)
                    }
                }
            })
        } catch { completion?(error) }
    }
}
