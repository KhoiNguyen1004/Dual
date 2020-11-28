//
//  ChallengeModel.swift
//  Dual
//
//  Created by Khoi Nguyen on 11/21/20.
//

import Foundation
import Firebase


class ChallengeModel {
    
    
    fileprivate var _challenge_status: String!
    fileprivate var _category: String!
    fileprivate var _challenge_id: String!
    fileprivate var _sender_ID: String!
    fileprivate var _messages: String!
    fileprivate var _started_timeStamp: Timestamp!
    fileprivate var _updated_timeStamp: Timestamp!
    fileprivate var _created_timeStamp: Timestamp!
   
    var challenge_status: String! {
        get {
            if _challenge_status == nil {
                _challenge_status = ""
            }
            return _challenge_status
        }
        
    }
    
    var category: String! {
        get {
            if _category == nil {
                _category = ""
            }
            return _category
        }
        
    }
    
    var sender_ID: String! {
        get {
            if _sender_ID == nil {
                _sender_ID = ""
            }
            return _sender_ID
        }
        
    }
    
    var messages: String! {
        get {
            if _messages == nil {
                _messages = ""
            }
            return _messages
        }
        
    }
    
    var started_timeStamp: Timestamp! {
        get {
            if _started_timeStamp == nil {
                _started_timeStamp = nil
            }
            return _started_timeStamp
        }
    }
    
    var updated_timeStamp: Timestamp! {
        get {
            if _updated_timeStamp == nil {
                _updated_timeStamp = nil
            }
            return _updated_timeStamp
        }
    }
    
    var created_timeStamp: Timestamp! {
        get {
            if _created_timeStamp == nil {
                _created_timeStamp = nil
            }
            return _created_timeStamp
        }
    }
    
    
   
    init(postKey: String, Challenge_model: Dictionary<String, Any>) {
        
        
        self._challenge_id = postKey
       
        if let challenge_status = Challenge_model["challenge_status"] as? String {
            self._challenge_status = challenge_status
        }
        
        if let category = Challenge_model["category"] as? String {
            self._category = category
        }
        
        if let sender_ID = Challenge_model["sender_ID"] as? String {
            self._sender_ID = sender_ID
        }
        
        if let messages = Challenge_model["messages"] as? String {
            self._messages = messages
        }
        
        if let started_timeStamp = Challenge_model["started_timeStamp"] as? Timestamp {
            self._started_timeStamp = started_timeStamp
        }
         
        if let updated_timeStamp = Challenge_model["updated_timeStamp"] as? Timestamp {
            self._updated_timeStamp = updated_timeStamp
        }
        
        if let created_timeStamp = Challenge_model["created_timeStamp"] as? Timestamp {
            self._created_timeStamp = created_timeStamp
        }
            
    }
    
   
    
    
}
