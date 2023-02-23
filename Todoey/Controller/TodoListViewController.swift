//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: UITableViewController {
    
    
    @IBOutlet weak var itemsNavigationBar: UINavigationItem!
    @IBOutlet weak var itemsSearcBar: UISearchBar!
    
    var itemsArray: Results<Item>?
    let realm = try! Realm()
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        tableView.rowHeight = 60
        itemsSearcBar.delegate = self
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let thisCategory = selectedCategory {
            guard let navbar = navigationController?.navigationBar else {fatalError("Navigation bar is not initialized yet")}
            
            if let color = UIColor(hexString: thisCategory.cellColor){
                let contrastColor = ContrastColorOf(color, returnFlat: true)
                title = thisCategory.categoryName
                navbar.tintColor = contrastColor
                itemsSearcBar.barTintColor = UIColor(hexString: thisCategory.cellColor)
                
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.foregroundColor: contrastColor]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: contrastColor]
                navBarAppearance.backgroundColor = color
                navbar.standardAppearance = navBarAppearance
                navbar.scrollEdgeAppearance = navBarAppearance
            }
        }
        
        
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        SharedStatistics.alertWithTextField(alertControllerTitle: "Adding new item", actionTitle: "Add", triggeringViewController: self) { field in
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write({
                        let thisItem = Item()
                        thisItem.title = field.text!
                        currentCategory.items.append(thisItem)
                        thisItem.dateCreated = Date()
                    })
                } catch {
                    print(error)
                }
                self.tableView.reloadData()
            }
            
            
            
        }
    }
    
}


//MARK: -- Table view

extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        if let thisCell = itemsArray?[indexPath.row] {
            var content = cell.defaultContentConfiguration()
//            cell.textLabel?.text = thisCell.title
            content.text = thisCell.title
            cell.accessoryType = thisCell.isChecked ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(itemsArray!.count))) {
                cell.backgroundColor = color
                let contrastColor = ContrastColorOf(color, returnFlat: true)
//                cell.textLabel?.textColor = contrastColor
                
                cell.tintColor = contrastColor
            }
            cell.contentConfiguration = content
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thisRow = indexPath.row
        if let item = itemsArray?[thisRow] {
            do {
                try realm.write({
                    item.isChecked = !(item.isChecked)
                })
            } catch {
                print("Error updating is checked status --- \(error) ---")
            }
            tableView.reloadData()
        }
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: -- swipe to delete
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .destructive, title: "Edit") { contextAction, view, completion in
            if let thisCell = self.itemsArray?[indexPath.row]{
                SharedStatistics.alertWithTextField(alertControllerTitle: "Edit", actionTitle: "Done", textFieldDefaultValue: thisCell.title,triggeringViewController: self) { field in
                    
                    if let thisItem = self.itemsArray?[indexPath.row] {
                        
                        do {
                            try self.realm.write({
                                thisItem.title = field.text!
                            })
                        } catch  {
                            print("Error updating category item title --- \(error) ---")
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            completion(true)
        }
        editAction.image = UIImage(systemName: "square.and.pencil")
        editAction.backgroundColor = .orange
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { contextAction, view, completion in
            if let thisItem = self.itemsArray?[indexPath.row]{
                do {
                    try self.realm.write({
                        self.realm.delete(thisItem)
                    })
                } catch {
                    print("Error deleting category item --- \(error) ---")
                }
                tableView.reloadData()
            }
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
}
//MARK: -- Shared Functions
extension TodoListViewController {
    // edit title of the item on long press does the same thing as swipe to edit
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if let thisCell = self.itemsArray?[indexPath.row]{
                    SharedStatistics.alertWithTextField(alertControllerTitle: "Editting title of item: \(indexPath.row + 1)", actionTitle: "Done", textFieldDefaultValue: thisCell.title,triggeringViewController: self) { field in
                        
                        if let thisItem = self.itemsArray?[indexPath.row] {
                            
                            do {
                                try self.realm.write({
                                    thisItem.title = field.text!
                                })
                            } catch  {
                                print("Error updating category item title --- \(error) ---")
                            }
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func loadData() {
        itemsArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
}
//MARK: -- Search bar delegate
extension TodoListViewController: UISearchBarDelegate {
    
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else {
            itemsArray = itemsArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title",ascending: true)
            tableView.reloadData()
        }
    }
}

