//
//  Realm+CloudKit.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import RealmSwift
import CloudKit


extension RealmTagsModel {
    func getRecord() -> CKRecord {
        let scheme = Schema.Tags.self
        
        let coder = NSKeyedUnarchiver(forReadingWith: self.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data polluted!!")}
        coder.finishDecoding()
        
        record[scheme.tags] = self.tags as CKRecordValue
        record[scheme.id] = self.id as CKRecordValue
        
        return record
    }
}

extension RealmNoteModel {
    
    func getRecord() -> CKRecord {
        let scheme = Schema.Note.self
        
        let coder = NSKeyedUnarchiver(forReadingWith: self.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data poluted!!")}
        coder.finishDecoding()
        
        record[scheme.id] = self.id as CKRecordValue
        record[scheme.content] = self.content as CKRecordValue
        record[scheme.attributes] = self.attributes as CKRecordValue
        
        record[scheme.tags] = self.tags as CKRecordValue
        record[scheme.isPinned] = (self.isPinned ? 1 : 0) as CKRecordValue
        record[scheme.isInTrash] = (self.isInTrash ? 1 : 0) as CKRecordValue
        record[scheme.backgroundColorString] = self.backgroundColorString as CKRecordValue
        
        return record
        
    }
}

extension RealmImageModel {
    
    func getRecord() -> (URL, CKRecord) {
        let scheme = Schema.Image.self
        
        let coder = NSKeyedUnarchiver(forReadingWith: self.ckMetaData)
        coder.requiresSecureCoding = true
        guard let record = CKRecord(coder: coder) else {fatalError("Data poluted!!")}
        coder.finishDecoding()
        
        let noteRecordID = CKRecordID(recordName: noteRecordName, zoneID: record.recordID.zoneID)
        
        record[scheme.id] = self.id as CKRecordValue
        guard let asset = try? CKAsset(data: self.image) else { fatalError() }
        record[scheme.image] = asset
        
        record[scheme.noteRecordName] = CKReference(recordID: noteRecordID, action: .deleteSelf)
        record.setParent(noteRecordID)
        
        return (asset.fileURL, record)
    }
}


extension CKRecord {

    func getMetaData() -> Data {
        let data = NSMutableData()
        let coder = NSKeyedArchiver(forWritingWith: data)
        coder.requiresSecureCoding = true
        self.encodeSystemFields(with: coder)
        coder.finishEncoding()

        return Data(referencing: data)
    }

    func parseRecord(isShared: Bool) -> Object? {
        switch self.recordType {
            case RealmTagsModel.recordTypeString: return parseTagsRecord()
            case RealmNoteModel.recordTypeString: return parseNoteRecord(isShared: isShared)
            case RealmImageModel.recordTypeString: return parseImageRecord(isShared: isShared)
            case RealmRecordTypeString.latestEvent.rawValue:
                //special case!
                if let date = self[Schema.LatestEvent.date] as? Date {
                    UserDefaults.standard.set(date, forKey: Schema.LatestEvent.key)
                    UserDefaults.standard.synchronize()
                }
                fallthrough
            default: return nil
        }
    }
    
    private func parseTagsRecord() -> RealmTagsModel? {
        let newTagsModel = RealmTagsModel()
        let schema = Schema.Tags.self
        
        guard let tags = self[schema.tags] as? String,
            let id = self[schema.id] as? String else {return nil}
        
        newTagsModel.tags = tags
        newTagsModel.id = id
        newTagsModel.ckMetaData = self.getMetaData()
        
        return newTagsModel
    }
    
    private func parseNoteRecord(isShared: Bool) -> RealmNoteModel? {
        let newNoteModel = RealmNoteModel()
        let schema = Schema.Note.self
        
        guard let id = self[schema.id] as? String,
                let content = self[schema.content] as? String,
                let attributes = self[schema.attributes] as? Data,
                let tags = self[schema.tags] as? String,
                let isPinned = self[schema.isPinned] as? Int,
                let isInTrash = self[schema.isInTrash] as? Int,
                let backgroundColorString = self[schema.backgroundColorString] as? String else {return nil}

        newNoteModel.id = id
        newNoteModel.content = content
        newNoteModel.attributes = attributes
        newNoteModel.recordName = self.recordID.recordName
        newNoteModel.ckMetaData = self.getMetaData()
        newNoteModel.isModified = self.modificationDate ?? Date()
        newNoteModel.tags = tags
        newNoteModel.isPinned = isPinned == 1
        newNoteModel.isInTrash = isInTrash == 1
        newNoteModel.backgroundColorString = backgroundColorString

        newNoteModel.isShared = isShared
        
        return newNoteModel
    }
    
    private func parseImageRecord(isShared: Bool) -> RealmImageModel? {
        let newImageModel = RealmImageModel()
        let schema = Schema.Image.self
        
        guard let id = self[schema.id] as? String,
            let imageAsset = self[schema.image] as? CKAsset,
            let image = try? Data(contentsOf: imageAsset.fileURL),
            let noteReference = self[schema.noteRecordName] as? CKReference
            else {return nil}

        newImageModel.id = id
        newImageModel.image = image
        newImageModel.noteRecordName = noteReference.recordID.recordName
        newImageModel.recordName = self.recordID.recordName
        newImageModel.ckMetaData = self.getMetaData()
        newImageModel.isShared = isShared

        defer {
            try? FileManager.default.removeItem(at: imageAsset.fileURL)
        }
        
        return newImageModel
    }
    
}

