//
//  Sync.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 2..
//  Copyright © 2018년 piano. All rights reserved.
//

import CloudKit
import RealmSwift



struct Schema {
    
    struct LatestEvent {
        static let key = "UserDefaultsLatestEvent"
        static let date = "date"
    }
    
    struct Tags {
        static let tags = "tags"
        static let id = "id"
    }
    
    struct Note {
        static let id = "id"
        static let content = "content"
        static let attributes = "attributes"
        static let backgroundColorString = "backgroundColorString"
        
        static let tags = "tags"
        static let isPinned = "isPinned"
        static let isInTrash = "isInTrash"
    }
    
    struct Image {
        static let id = "id"
        static let image = "image"
        
        static let noteRecordName = "noteRecordName"
    }
}

enum RealmRecordTypeString: String {
    
    case tags = "Tags"
    case note = "Note"
    case image = "Image"
    case latestEvent = "LatestEvent"

    func getType() -> Object.Type? {
        switch self {
            case .tags: return RealmTagsModel.self
            case .note: return RealmNoteModel.self
            case .image: return RealmImageModel.self
            default: return nil
        }
    }
}


extension RxCloudDatabase {

    func syncMetaDatas(records: [CKRecord]) {
        records.forEach { syncMetaData(record: $0) }
    }

    func syncMetaData(record: CKRecord) {
        guard let tempRealm = try? Realm(),
                let type = RealmRecordTypeString(rawValue: record.recordType)?.getType(),
                let id = record["id"] as? String,
                let object = tempRealm.object(ofType: type, forPrimaryKey: id) else {return}

        let ref = ThreadSafeReference(to: object)
        LocalDatabase.shared.commit(action: { realm in
            guard let object = realm.resolve(ref) else {return}
            try? realm.write{ object.setValue(record.getMetaData(), forKey: "ckMetaData") }
        })

    }

    func syncChanged(records: [CKRecord], isShared: Bool) {
        records.forEach { save(record: $0, isShared: isShared) }
    }
    
    func syncChanged(record: CKRecord, isShared: Bool) {
        save(record: record, isShared: isShared)
    }

    func syncDeleted(recordID: CKRecordID, recordType: String) {
        guard let realmType = RealmRecordTypeString(rawValue: recordType) else { /*fatal error*/ return }
        
        switch realmType {
        case .tags, .latestEvent: break //Not gonna happen!
        case .note: deleteNoteRecord(recordID.recordName)
        case .image: deleteImageRecord(recordID.recordName)
        }
    }

    private func save(record: CKRecord, isShared: Bool) {
        guard let object = record.parseRecord(isShared: isShared) else {return}

        if record.recordType == RealmNoteModel.recordTypeString {
            if let synchronizer = synchronizers[record.recordID.recordName] {
                synchronizer.serverContentChanged(record)
            }
        }

        LocalDatabase.shared.commit(action: { realm in
            try? realm.write{ realm.add(object, update: true) }
        })
    }

    private func deleteNoteRecord(_ recordName: String) {
        
        guard let realm = try? Realm(),
            let noteModel = realm.objects(RealmNoteModel.self).filter("recordName = %@", recordName).first else {return}

        let images = realm.objects(RealmImageModel.self).filter("noteRecordName = %@", recordName)
        
        let noteRef = ThreadSafeReference(to: noteModel)
        let imagesRef = ThreadSafeReference(to: images)

        LocalDatabase.shared.commit(action: { realm in
            guard let note = realm.resolve(noteRef),
                    let images = realm.resolve(imagesRef) else {return}

            try? realm.write {
                realm.delete(note)
                realm.delete(images)
            }
        })
    }
    
    private func deleteImageRecord(_ recordName: String) {
        
        guard let realm = try? Realm(),
            let imageModel = realm.objects(RealmImageModel.self).filter("recordName = %@", recordName).first else {return}
        
        let ref = ThreadSafeReference(to: imageModel)

        LocalDatabase.shared.commit(action: { realm in
            guard let image = realm.resolve(ref) else {return}
            try? realm.write{realm.delete(image)}
        })
    }
}
