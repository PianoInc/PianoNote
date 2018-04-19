//
// Created by 김범수 on 2018. 4. 19..
// Copyright (c) 2018 piano. All rights reserved.
//

import CloudKit
import RxSwift

typealias CloudSaveHandler = ((CKRecord?, Error?) -> Void)
typealias CloudDeleteHandler = ((Error?) -> Void)

class RxCloudDatabase {
    static let privateRecordZoneName = "Cloud_Memo_Zone"
    let database: CKDatabase
    var synchronizers: [String: NoteSynchronizer] = [:]

    private let saveObservable = PublishSubject<(CKRecord, CloudSaveHandler)>()
    private let deleteObservable = PublishSubject<(CKRecordID, CloudDeleteHandler)>()
    private let disposeBag = DisposeBag()

    init(database: CKDatabase) {
        self.database = database

        subscribeToObservers()
    }

    //Subscribe to save\delete observables to perform batch operation
    private func subscribeToObservers() {
        saveObservable.buffer(timeSpan: 0.5, count: 40, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.upload($0)
            }).disposed(by: disposeBag)

        deleteObservable.buffer(timeSpan: 0.5, count: 40, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.delete($0)
            }).disposed(by: disposeBag)
    }

    private func upload(_ recordsAndHandlers: [(CKRecord, CloudSaveHandler)]) {
        var completionDic:[CKRecordID: CloudSaveHandler] = [:]
        var records: [CKRecord] = []

        recordsAndHandlers.forEach{
            records.append($0.0)
            completionDic[$0.0.recordID] = $0.1
        }

        let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: [])
        operation.modifyRecordsCompletionBlock = { savedRecords, _, error in
            guard error == nil else {
                guard let errors = (error as? CKError)?.partialErrorsByItemID else { return completionDic.values.forEach{ $0(nil,error)} }
                errors.forEach{ key, error in
                    guard let recordID = key as? CKRecordID else {return}
                    completionDic[recordID]?(nil,error)
                }
                return
            }

            //TODO: save at local db with batch!
            completionDic.values.forEach{$0(nil,nil)}
        }
        operation.qualityOfService = .utility

        database.add(operation)
    }

    private func delete(_ recordsAndHandlers: [(CKRecordID, CloudDeleteHandler)]) {
        var completionDic:[CKRecordID: CloudDeleteHandler] = [:]
        var recordIDs:[CKRecordID] = []

        recordsAndHandlers.forEach{
            recordIDs.append($0.0)
            completionDic[$0.0] = $0.1
        }

        let operation = CKModifyRecordsOperation(recordsToSave: [], recordIDsToDelete: recordIDs)

        operation.modifyRecordsCompletionBlock = { (_, _, error) in
            guard error == nil else {
                guard let errors = (error as? CKError)?.partialErrorsByItemID else { return completionDic.values.forEach{ $0(error)} }
                errors.forEach{ key, error in
                    guard let recordID = key as? CKRecordID else {return}
                    completionDic[recordID]?(error)
                }
                return
            }

            completionDic.values.forEach{ $0(nil) }
        }
        operation.qualityOfService = .utility

        database.add(operation)
    }

    func upload(record: CKRecord, ancestorRecord: CKRecord? = nil, completion: @escaping CloudSaveHandler) {
        let cloudCompletion: CloudSaveHandler = { [weak self] conflicted, error in
            guard error == nil else {
                guard let ckError = error as? CKError else {return completion(nil, error)}

                if ckError.isZoneNotFound() && self?.database.databaseScope == .private {
                    let zone = CKRecordZone(zoneName: RxCloudDatabase.privateRecordZoneName)
                    self?.createZoneWithID(zoneID: zone.zoneID) { error in
                        guard error == nil else {return completion(nil, error)}
                        self?.upload(record: record, ancestorRecord: ancestorRecord, completion: completion)
                    }
                    return
                } else {
                    let (wrappedAncestor, wrappedClient, wrappedServer) = ckError.getMergeRecords()

                    guard let clientRecord = wrappedClient,
                            let serverRecord = wrappedServer,
                            let ancestorRecord = ancestorRecord ?? wrappedAncestor ?? nil else {return completion(nil,error)}

                    //TODO: conflict resolve
                }
                return
            }

            completion(nil,nil)
        }
        saveObservable.onNext((record,cloudCompletion))
    }

    func delete(recordID: CKRecordID, completion: @escaping CloudDeleteHandler) {
        deleteObservable.on(.next((recordID, completion)))
    }

    func load(recordIDs: [CKRecordID], completion: @escaping (([CKRecordID: CKRecord]?,Error?) -> Void)) {
        let operation = CKFetchRecordsOperation(recordIDs: recordIDs)
        operation.fetchRecordsCompletionBlock = { recordDic, error in
            guard error == nil else { return completion(nil, error)}
            completion(recordDic,nil)
        }
        operation.qualityOfService = .utility

        database.add(operation)
    }

    /**
       This method creates custom Zone with specific identifier
       in this class.
      */
    func createZoneWithID(zoneID: CKRecordZoneID, completion: @escaping ((Error?) -> Void)) {
        let recordZone = CKRecordZone(zoneID: zoneID)
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [recordZone], recordZoneIDsToDelete: [])

        operation.modifyRecordZonesCompletionBlock = { (_, _, error) in
            completion(error)
        }

        operation.qualityOfService = .utility

        database.add(operation)
    }
}
