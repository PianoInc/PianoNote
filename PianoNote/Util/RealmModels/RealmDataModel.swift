//
//  RealmDataModel.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import RealmSwift
import CloudKit

@objc protocol Recordable {
    var recordName: String {get set}
    var isInSharedDB: Bool {get set}
    var ckMetaData: Data {get set}
    @objc optional func getRecord() -> CKRecord
}


/*
 Adding new field
 
 1 RealmDataModel
 2. Sync scheme
 3. Realm+Cloudkit -> getRecord() & parse__Record()
 4. Appdelegate -> increment MigrationNumber
 
*/

/*
 How Notificaiton works
 
 1. object observe notification
    switch {
    case .change(let [propertyList]):
        changeList.forEach {
            $0.name
            $0.newValue
            $0.oldValue
        }
    case .error
    case .deleted
    }
 
 2. result(List) observe notification
 
 switch {
    case .change(let objects, let deletes, let insertions, let modifications)
    case .initial
    case .error
 }
*/

class RealmTagsModel: Object, Recordable {
    static let recordTypeString = "Tags"
    static let tagSeparator = "|"
    static let lockSymbol = "@"
    
    @objc dynamic var id = ""
    @objc dynamic var tags = ""
    @objc dynamic var recordName = ""
    @objc dynamic var ckMetaData = Data()
    @objc dynamic var isInSharedDB = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["recordTypeString"]
    }
    
    static func getNewModel() -> RealmTagsModel {
        let zone = CKRecordZone(zoneName: RxCloudDatabase.privateRecordZoneName)
        let id = Util.share.getUniqueID()
        let record = CKRecord(recordType: RealmTagsModel.recordTypeString, zoneID: zone.zoneID)
        
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: data)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        
        let newModel = RealmTagsModel()
        newModel.id = id
        newModel.recordName = record.recordID.recordName
        newModel.ckMetaData = Data(referencing: data)
        
        return newModel
    }
}


class RealmNoteModel: Object, Recordable {
    
    static let recordTypeString = "Note"
    
    @objc dynamic var id = ""
    @objc dynamic var content = ""
    @objc dynamic var attributes = "[]".data(using: .utf8)!
    @objc dynamic var colorThemeCode = ColorPreset.white.rawValue
    
    @objc dynamic var recordName = ""
    @objc dynamic var ckMetaData = Data()
    @objc dynamic var isModified = Date()
    
    @objc dynamic var isInSharedDB = false
    @objc dynamic var shareRecordName: String? = nil
    
    @objc dynamic var isPinned = false
    @objc dynamic var isLocked = false
    @objc dynamic var isInTrash = false
    
    @objc dynamic var tags = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["recordTypeString"]
    }
    
    static func getNewModel(content: String, categoryRecordName: String) -> RealmNoteModel {
        let zone = CKRecordZone(zoneName: RxCloudDatabase.privateRecordZoneName)
        let id = Util.share.getUniqueID()
        let record = CKRecord(recordType: RealmNoteModel.recordTypeString, zoneID: zone.zoneID)
        
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: data)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        
        let newModel = RealmNoteModel()
        newModel.recordName = record.recordID.recordName
        newModel.ckMetaData = Data(referencing: data)
        newModel.id = id
        newModel.tags = categoryRecordName.isEmpty ? "" : "\(RealmTagsModel.tagSeparator)\(categoryRecordName)\(RealmTagsModel.tagSeparator)"
        newModel.content = content
        
        return newModel
    }
}

class RealmImageModel: Object, Recordable {
    
    static let recordTypeString = "Image"
    
    @objc dynamic var id = ""
    @objc dynamic var image = Data()
    
    @objc dynamic var recordName = ""
    @objc dynamic var ckMetaData = Data()
    
    @objc dynamic var isInSharedDB = false
    
    @objc dynamic var noteRecordName = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["recordTypeString"]
    }    
    
    
    static func getNewModel(sharedZoneID: CKRecordZoneID? = nil, noteRecordName: String, image: UIImage) -> RealmImageModel {
        let zone = CKRecordZone(zoneName: RxCloudDatabase.privateRecordZoneName)
        let id = Util.share.getUniqueID()
        let zoneID = sharedZoneID ?? zone.zoneID
        let record = CKRecord(recordType: RealmImageModel.recordTypeString, zoneID: zoneID)
        
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: data)
        coder.requiresSecureCoding = true
        record.encodeSystemFields(with: coder)
        coder.finishEncoding()
        
        let newModel = RealmImageModel()
        newModel.recordName = record.recordID.recordName
        newModel.ckMetaData = Data(referencing: data)
        newModel.id = id
        newModel.isInSharedDB = sharedZoneID != nil
        newModel.noteRecordName = noteRecordName
        newModel.image = UIImageJPEGRepresentation(image, 1.0) ?? Data()
        
        return newModel
    }
}

class RealmCKShare: Object {
    
    static let recordTypeString = "cloudkit.share"
    
    @objc var recordName = ""
    @objc var shareData = Data()
    
    override static func primaryKey() -> String? {
        return "recordName"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["recordTypeString"]
    }
}
