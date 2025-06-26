//
//  ExternalPrint.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 22/5/2024.
//

import Foundation
import UIKit
extension UIViewController{
    /// alertController that is used to output message for user
    func externalPrint(_ title: String,_ messages:String){
        let alertController = UIAlertController(title: title, message: messages, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
