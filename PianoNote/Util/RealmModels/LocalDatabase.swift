//
//  LocalDatabase.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 3..
//  Copyright © 2018년 piano. All rights reserved.
//

import RealmSwift
import RxSwift

typealias TransactionHandler = ((Error?) -> Void)

class LocalDatabase {
    static let shared = LocalDatabase()
    
    private let globalSchedular = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global(qos: .utility))
    private let transactionSubject = PublishSubject<LocalDatabaseTransaction>()
    private let disposeBag = DisposeBag()

    private init() {
        subscribeToObservables()
    }

    private func subscribeToObservables() {
        transactionSubject
                .subscribeOn(globalSchedular)
                .subscribe(onNext: { (transaction) in
                    do {
                        let realm = try Realm()
                        transaction.action(realm)
                        transaction.completion?(nil)
                    } catch {
                        transaction.completion?(error)
                    }
                }).disposed(by: disposeBag)
    }

    func commit(transaction: LocalDatabaseTransaction) {
        transactionSubject.on(.next(transaction))
    }

    func commit(action: @escaping ((Realm) -> ()), completion: TransactionHandler? = nil) {
        let newTransaction = LocalDatabaseTransaction(action: action, completion: completion)
        commit(transaction: newTransaction)
    }
}

class LocalDatabaseTransaction {
    let action: ((Realm) -> ())
    let completion: TransactionHandler?

    /**
      - parameters:
        - action: Transaciton에서 실행할 액션
        - completion: 액션이 실행된 후 completion handler
      - important: Action내에서 사용되는 Object들은 보통 ThreadSafeReference로 사용되어야한다.
     
     예외의 경우가 있다. 아직 Realm에 추가되지 않은 Object는 Object자체로 action내에서 사용될 수 있다.
      */
    init(action: @escaping ((Realm) -> ()), completion: TransactionHandler? = nil) {
        self.action = action
        self.completion = completion
    }
}
