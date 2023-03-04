//
//  Statistics.swift
//  Todoey
//
//  Created by AmirReza Jamali on 12/28/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

struct SharedStatistics {
     
    static let fromCategoryToItemsSegue: String  = "showItemsOfCategory"
    
    static func alertWithTextField (alertControllerTitle: String?, alertControllerMessage: String? = "", alertControllerStyle:UIAlertController.Style = .alert, actionTitle: String?, actionStyle: UIAlertAction.Style = .default,textFieldDefaultValue: String? = nil, triggeringViewController: UIViewController , functionToDoWhenUserSubbmits trigger: @escaping (_ field: UITextField) -> ()) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: alertControllerTitle, message: alertControllerMessage, preferredStyle: alertControllerStyle)
        let action = UIAlertAction(title: actionTitle, style: actionStyle) { action in
            if textField.text?.isEmpty == false {
                trigger(textField)
            } else {
                textField.placeholder = "Please enter a valid title"
                return
            }
            
        }
        alert.addAction(action)
        alert.addTextField { alertTextField in
            if let safeTextFieldDefaultValue = textFieldDefaultValue {
                alertTextField.text = safeTextFieldDefaultValue
            }
            textField = alertTextField
            textField.autocapitalizationType = .words
        }

        
            triggeringViewController.present(alert, animated: true)
        
    }
    static func saveCategory (realm: Realm, data: Category, table:UITableView) {
        do {
            try realm.write({
                realm.add(data)
            })
        } catch  {
            print("Error saving items realm ====== \(error)")
        }
        table.reloadData()
    }
    
}
