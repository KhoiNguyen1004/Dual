//
//  CommentModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/4/21.
//

import Foundation
import Firebase


class CommentModel {
    
    var lastCmtSnapshot: DocumentSnapshot!
    var just_add: Bool!
    
   
    
    
    
    fileprivate var _Comment_id: String!
    fileprivate var _Comment_uid: String!
    fileprivate var _text: String!
    fileprivate var _status: String!
    fileprivate var _isReply: Bool!
    fileprivate var _Mux_playbackID: String!
    fileprivate var _root_id: String!
    fileprivate var _has_reply: Bool!
    fileprivate var _is_title: Bool!
    fileprivate var _number_of_reply: Int!
    fileprivate var _timeStamp: Timestamp!
    fileprivate var _Update_timestamp: Timestamp!
    fileprivate var _reply_to: String!
    fileprivate var _just_add: Bool!
   
    
    
    
    var number_of_reply: Int! {
        get {
            if _number_of_reply == nil {
                _number_of_reply = 1
            }
            return _number_of_reply
        }
        
    }
    
       
       var reply_to: String! {
        get {
            if _reply_to == nil {
                _reply_to = ""
            }
            return _reply_to
        }
        
    }
    
    var Comment_uid: String! {
        get {
            if _Comment_uid == nil {
                _Comment_uid = ""
            }
            return _Comment_uid
        }
        
    }
    
    var Comment_id: String! {
        get {
            if _Comment_id == nil {
                _Comment_id = ""
            }
            return _Comment_id
        }
        
    }
    
    var text: String! {
        get {
            if _text == nil {
                _text = ""
            }
            return _text
        }
        
    }
    
    var status: String! {
        get {
            if _status == nil {
                _status = ""
            }
            return _status
        }
        
    }
    
    var is_title: Bool! {
        get {
            if _is_title == nil {
                _is_title = false
            }
            
            return _is_title
        }
    }
    
    var isReply: Bool! {
        get {
            if _isReply == nil {
                _isReply = false
            }
            
            return _isReply
        }
    }
    
    var has_reply: Bool! {
        get {
            if _has_reply == nil {
                _has_reply = false
            }
            
            return _has_reply
        }
    }

    
    var Mux_playbackID: String! {
        
        get {
            if _Mux_playbackID == nil {
                _Mux_playbackID = ""
            }
            return _Mux_playbackID
        }
        
    }
    
    var root_id: String! {
        
        get {
            if _root_id == nil {
                _root_id = ""
            }
            return _root_id
        }
        
    }

    var timeStamp: Timestamp! {
        get {
            if _timeStamp == nil {
                _timeStamp = nil
            }
            return _timeStamp
        }
    }
    
    var Update_timestamp: Timestamp! {
        get {
            if _Update_timestamp == nil {
                _Update_timestamp = nil
            }
            return _Update_timestamp
        }
    }
    
    
    
    
    init(postKey: String, Comment_model: Dictionary<String, Any>) {
        
        self._Comment_id = postKey
       
        if let Comment_uid = Comment_model["Comment_uid"] as? String {
            self._Comment_uid = Comment_uid
        }
        
        if let text = Comment_model["text"] as? String {
            self._text = text
        }
        
        if let status = Comment_model["status"] as? String {
            self._status = status
        }
        
        if let Mux_playbackID = Comment_model["Mux_playbackID"] as? String {
            self._Mux_playbackID = Mux_playbackID
        }
        
        if let root_id = Comment_model["root_id"] as? String {
            self._root_id = root_id
        }
        
        
        if let isReply = Comment_model["isReply"] as? Bool {
            self._isReply = isReply
        }
        
        
        if let has_reply = Comment_model["has_reply"] as? Bool {
            self._has_reply = has_reply
        }
        
        if let is_title = Comment_model["is_title"] as? Bool {
            self._is_title = is_title
        }
        
 
        if let timeStamp = Comment_model["timeStamp"] as? Timestamp {
            self._timeStamp = timeStamp
        }
        
        
        if let number_of_reply = Comment_model["number_of_reply"] as? Int {
            self._number_of_reply = number_of_reply
        }
        
        
        if let reply_to = Comment_model["reply_to"] as? String {
            self._reply_to = reply_to
        }

        if let Update_timestamp = Comment_model["Update_timestamp"] as? Timestamp {
            self._Update_timestamp = Update_timestamp
        }
        
        
        
        
    

    }
    

}
