//
//  ItemsCell.swift
//  Todoey
//
//  Created by AmirReza Jamali on 3/3/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
class ItemsCell: UITableViewCell {

    @IBOutlet weak var itemsCellView: UIView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var stepperOutlet: UIStepper!
    
    var realm: Realm? = nil
    var thisCell: Item? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        quantityLabel.text = String(format: "%.0f", sender.value)
        print(sender.value)
        if let unwrappedRealm = realm {
            if let unwrappedCell = thisCell{
                do {
                    try unwrappedRealm.write({
                        unwrappedCell.quantity = quantityLabel.text!
                    })
                } catch {
                    print("Error edditing realm in stepper")
                }
            }
        }
    }
}
