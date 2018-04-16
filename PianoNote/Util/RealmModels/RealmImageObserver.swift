//
//  RealmImageObserver.swift
//  PianoNote
//
//  Created by 김범수 on 2018. 4. 10..
//  Copyright © 2018년 piano. All rights reserved.
//

import Foundation
import RealmSwift

class RealmImageObserver {
    
    private var notificationToken: NotificationToken?
    private var handlerDic:[String: ((ThreadSafeReference<RealmImageModel>) -> Void)]  = [:]
    
    
    deinit {
        notificationToken?.invalidate()
    }
    
    init() {
        guard let realm = try? Realm() else {/* fatal error! */ return }
        
        notificationToken = realm.objects(RealmImageModel.self).observe { [weak self] (change) in
            switch change {
            case .initial: break
            case .update(let results,_,let inserts,_):
                inserts.forEach {
                    guard let strongHandlerDic = self?.handlerDic else {return}
                    
                    let id = results[$0].id
                    let ref = ThreadSafeReference(to: results[$0])
                    if let handler = strongHandlerDic[id] {
                        self?.handlerDic.removeValue(forKey: id)
                        handler(ref)
                    }
                }
            case .error: fatalError()
            }
        }
    }
    
    func setHandler(for id: String, handler: @escaping ((ThreadSafeReference<RealmImageModel>) -> Void)) {
        //Don't overwrite handler
        if handlerDic[id] == nil { handlerDic[id] = handler }
    }
}
