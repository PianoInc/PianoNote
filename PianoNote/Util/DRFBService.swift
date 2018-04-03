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

typealias DRFBPost = (create: Date, id: String, title: String, msg: String)
typealias DRFBComment = (create: Date, count: Int, msg: String, reply: [DRFBReply]?)
typealias DRFBReply = (create: Date, msg: String)

class DRFBService: NSObject {
    
    static let share = DRFBService()
    
    private enum DRFBState {case next, finish}
    private typealias DRFBCursor = (state: DRFBState, cursor: String)
    
    private var postState = DRFBCursor(state: .next, cursor: "")
    private var commentState = DRFBCursor(state: .next, cursor: "")
    
    private var postData = [DRFBPost]()
    private var commentData = [DRFBComment]()
    
    private let postLimit = "10"
    private let commentLimit = "10"
    
    /// postData을 감시하며 self return한다.
    var rxPost = DRBinder([DRFBPost]())
    
    /// commentData을 감시하며 self return한다.
    var rxComment = DRBinder([DRFBComment]())
    
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
        
        let params = ["fields" : "created_time, name, message", "limit" : postLimit, "after" : postState.cursor]
        let request = FBSDKGraphRequest(graphPath: "/\(pageID)/posts", parameters: params)!
        request.start { (connect, result, error) in
            guard let result = result else {return}
            let json = JSON(result)
            
            if let data = json["data"].array {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate,
                                           .withTime, .withColonSeparatorInTime]
                for data in data {
                    let id = data["id"].string ?? ""
                    let title = data["name"].string ?? ""
                    let msg = data["message"].string ?? ""
                    let create = formatter.date(from: data["created_time"].stringValue)!
                    self.postData.append(DRFBPost(create: create, id: id, title: title, msg: msg))
                }
                self.rxPost.value = self.postData
                self.postData.removeAll()
            }
            
            self.postState.state = .finish
            self.postState.cursor = ""
            if let paging = json["paging"].dictionary, let next = paging["next"]?.string {
                self.postState.state = .next
                self.postState.cursor = next.sub(next.index(lastOf: "=")...)
            }
        }
    }
    
    /**
     Facebook의 해당 post에 달려있는 comment들을 load 한다.
     - parameter postID : 가져오고자 하는 post의 id.
     */
    func facebook(comment postID: String) {
        guard commentState.state == .next else {return}
        let params = ["fields" : "comments.limit(\(commentLimit)){created_time, comment_count, message, comments{created_time, message}}", "after" : commentState.cursor]
        let request = FBSDKGraphRequest(graphPath: postID, parameters: params)!
        request.start { (connect, result, error) in
            guard let result = result else {return}
            let json = JSON(result)
            
            if let comments = json["comments"].dictionary, let data = comments["data"]?.array  {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withFullDate, .withDashSeparatorInDate,
                                           .withTime, .withColonSeparatorInTime]
                for data in data {
                    let count = data["comment_count"].int ?? 0
                    let msg = data["message"].string ?? ""
                    let create = formatter.date(from: data["created_time"].stringValue)!
                    var reply = [DRFBReply]()
                    if let comments = data["comments"].dictionary, let data = comments["data"]?.array  {
                        for data in data {
                            if let msg = data["message"].string, !msg.isEmpty {
                                guard let created_time = data["created_time"].string else {continue}
                                let create = formatter.date(from: created_time)!
                                reply.append(DRFBReply(create: create, msg: msg))
                            }
                        }
                    }
                    self.commentData.append(DRFBComment(create: create, count: count, msg: msg, reply: reply.isEmpty ? nil : reply))
                }
                self.rxComment.value = self.commentData
                self.commentData.removeAll()
            }
            
            self.commentState.state = .finish
            self.commentState.cursor = ""
            if let paging = json["paging"].dictionary, let next = paging["next"]?.string {
                self.commentState.state = .next
                self.commentState.cursor = next.sub(next.index(lastOf: "=")...)
            }
        }
    }
    
    // postState 초기화.
    func resetPost() {
        postState = DRFBCursor(state: .next, cursor: "")
        postData.removeAll()
    }
    
    // commentState 초기화.
    func resetComment() {
        commentState = DRFBCursor(state: .next, cursor: "")
        commentData.removeAll()
    }
    
}

