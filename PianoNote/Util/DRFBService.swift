//
//  DRFBService.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 27..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftyJSON

typealias DRFBPosts = (updated: String, id: String, name: String, msg: String)
typealias DRFBComments = (tag: Int?, msg: String, reply: [String]?)

class DRFBService: NSObject {
    
    static let share = DRFBService()
    
    private enum DRFBState {case next, finish}
    private typealias DRFBCursor = (state: DRFBState, cursor: String)
    
    private var postState = DRFBCursor(state: .next, cursor: "")
    private var commentState = DRFBCursor(state: .next, cursor: "")
    
    private var postData = [DRFBPosts]()
    private var commentData = [DRFBComments]()
    
    private let postLimit = "10"
    private let commentLimit = "50"
    
    /// postData을 감시하며 self return한다.
    var rxPost = DRBinder([DRFBPosts]())
    
    /// commentData을 감시하며 self return한다.
    var rxComment = DRBinder([DRFBComments]())
    
    /**
     Facebook 로그인
     - parameter from : 타겟 viewController.
     - parameter completion : 로그인 성공 여부.
     */
    func facebook(login from: UIViewController, completion: @escaping ((Bool) -> ())) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        loginManager.logIn(withReadPermissions: ["public_profile"], from: from) { (result, error) in
            if let result = result, !result.isCancelled {
                completion(FBSDKAccessToken.current().tokenString != nil)
            } else {completion(false)}
        }
    }
    
    /**
     Facebook의 해당 page에 올려져있는 post들을 load 한다.
     - parameter pageID : 가져오고자 하는 page의 id.
     */
    func facebook(post pageID: String) {
        guard postState.state == .next else {return}
        
        let params = ["fields" : "updated_time, name, message", "limit" : postLimit]
        let request = FBSDKGraphRequest(graphPath: "/\(pageID)/posts", parameters: params)!
        request.start { (connect, result, error) in
            guard let result = result else {return}
            let json = JSON(result)
            
            if let data = json["data"].array {
                for data in data {
                    let updated = data["updated_time"].string ?? ""
                    let id = data["id"].string ?? ""
                    let name = data["name"].string ?? ""
                    guard let msg = data["message"].string else {continue}
                    self.postData.append(DRFBPosts(updated: updated, id: id, name: name, msg: msg))
                }
                self.rxPost.value = self.postData
                self.postData.removeAll()
            }
            
            if let paging = json["paging"].dictionary {
                if let next = paging["next"]?.string {
                    let from = next.index(lastOf: "=")
                    let cursor = next.sub(from...)
                    self.postState.state = .next
                    self.postState.cursor = cursor
                } else {
                    self.postState.state = .finish
                    self.postState.cursor = ""
                }
            }
        }
    }
    
    /**
     Facebook의 해당 post에 달려있는 comment들을 load 한다.
     - parameter postID : 가져오고자 하는 post의 id.
     */
    func facebook(comment postID: String) {
        guard commentState.state == .next else {return}
        
        let params = ["fields" : "comments.limit(\(commentLimit)){updated_time, message, comments{updated_time, message}}"]
        let request = FBSDKGraphRequest(graphPath: postID, parameters: params)!
        request.start { (connect, result, error) in
            guard let result = result else {return}
            let json = JSON(result)
            
            if let comments = json["comments"].dictionary, let data = comments["data"]?.array  {
                for data in data {
                    guard let msg = data["message"].string else {continue}
                    var reply = [String]()
                    if let comments = data["comments"].dictionary, let data = comments["data"]?.array  {
                        for data in data {
                            if let msg = data["message"].string, !msg.isEmpty {
                                reply.append(msg)
                            }
                        }
                    }
                    self.commentData.append(DRFBComments(tag: nil, msg: msg, reply: nil))
                    if let firstReply = reply.first {
                        reply.remove(at: 0)
                        reply.reverse()
                        self.commentData.append(DRFBComments(tag: nil, msg: firstReply, reply: reply))
                    }
                }
                self.rxComment.value = self.commentData
                self.commentData.removeAll()
            }
            
            if let paging = json["paging"].dictionary {
                if let next = paging["next"]?.string {
                    let from = next.index(lastOf: "=")
                    let cursor = next.sub(from...)
                    self.commentState.state = .next
                    self.commentState.cursor = cursor
                } else {
                    self.commentState.state = .finish
                    self.commentState.cursor = ""
                }
            }
        }
    }
    
}

