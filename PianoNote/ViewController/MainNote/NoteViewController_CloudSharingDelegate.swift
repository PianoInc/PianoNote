//
//  NoteViewController_CloudSharingDelegate.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 17..
//  Copyright © 2018년 piano. All rights reserved.
//

import CloudKit
import UIKit
import RealmSwift

extension NoteViewController: UICloudSharingControllerDelegate, UIPopoverPresentationControllerDelegate {
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print(error)
    }
    
    func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
        print("save!!!!!")
    }
    
    func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
        print("Stoppedddd!!!!!!!!!!!1’")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return "피아노 노트"
    }
    
    func itemThumbnailData(for csc: UICloudSharingController) -> Data? {
        return UIImageJPEGRepresentation(textView.getScreenShot(), 1.0)
    }
    
    private func share(rootRecord: CKRecord, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) {
        let shareRecord = CKShare(rootRecord: rootRecord)
        let recordsToSave = [rootRecord, shareRecord]
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: [])
        operation.perRecordCompletionBlock = { (record, error) in
            if let error = error {
                print(error)
            } else {
                //TODO: sync metadata with share
            }
        }
        
        operation.modifyRecordsCompletionBlock = { (savedRecords, deletedRecordIDs, error) in
            if let error = error {
                completion(nil,nil,error)
            } else {
                completion(shareRecord, CKContainer.default(), nil)
            }
        }
        
        
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    func presentShare(_ sender: UIBarButtonItem) {
        guard let realm = try? Realm(),
            let note = realm.object(ofType: RealmNoteModel.self, forPrimaryKey: noteID) else {return}
        
        let record = note.getRecord()
        
        let cloudSharingController = UICloudSharingController { [weak self] (controller, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
            self?.share(rootRecord: record, completion: completion)
        }
        
        cloudSharingController.availablePermissions = [.allowPrivate, .allowReadWrite]
        cloudSharingController.delegate = self
        
        if let popover = cloudSharingController.popoverPresentationController {
            popover.barButtonItem = sender
        }
        self.present(cloudSharingController, animated: true)
    }
}
