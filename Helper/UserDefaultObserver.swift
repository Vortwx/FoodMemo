//
//  UserDefaultListener.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 21/5/2024.
//

import Foundation
import UIKit

class UserDefaultObserver{
    /// make it singleton
    static let shared = UserDefaultObserver()
    
    func notifyUserDefaultDidChange(){
        NotificationCenter.default.post(name: .userDefaultDidChange,object:nil)
    }
    
    func addObserver(_ observer: Any, selector: Selector){
        NotificationCenter.default.addObserver(observer, selector: selector, name: UserDefaults.didChangeNotification, object: nil)
    }
    
    func removeObserver(_ observer: Any, selector: Selector){
        NotificationCenter.default.removeObserver(observer, name: UserDefaults.didChangeNotification, object: nil)
    }
}
/// the notification that this observer post for notifying purposes
extension Notification.Name{
    static let userDefaultDidChange = Notification.Name("userDefaultDidChange")
}
