//
//  CategoryViewController.swift
//  Todoey
//
//  Created by AmirReza Jamali on 12/26/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categoryList: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
        tableView.rowHeight = 60
        self.loadData()
        tableView.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
      setNavbarColor()
    }
    @IBAction func addCategoryButton(_ sender: UIBarButtonItem) {
        SharedStatistics.alertWithTextField(alertControllerTitle: "Add new item", actionTitle: "Add", triggeringViewController: self) { field in
            let thisCategory = Category()
            thisCategory.categoryName = field.text!
            thisCategory.cellColor = UIColor.randomFlat().hexValue()
            SharedStatistics.saveCategory(realm: self.realm, data: thisCategory, table: self.tableView)
        }
    }
    
}

//MARK: -- Table view data source

extension CategoryViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        if let thisCell = categoryList?[indexPath.row] {
            var content = cell.defaultContentConfiguration()
            content.text = thisCell.categoryName
            cell.backgroundColor = UIColor(hexString: thisCell.cellColor)
            content.textProperties.color = ContrastColorOf(UIColor(hexString: thisCell.cellColor)!, returnFlat: true)
            cell.contentConfiguration = content
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //MARK: -- cell edit action
        let editAction = UIContextualAction(style: .destructive, title: "Edit") { contextAction, view, compeletion in
            SharedStatistics.alertWithTextField(alertControllerTitle: "Edit", actionTitle: "Done",textFieldDefaultValue: self.categoryList?[indexPath.row].categoryName, triggeringViewController: self) { field in
                if let thisCategory = self.categoryList?[indexPath.row] {
                    
                    do {
                        try self.realm.write({
                            thisCategory.categoryName = field.text!
                        })
                    } catch  {
                        print("Error edittong category title --- \(error) ---")
                    }
                    self.tableView.reloadData()
                }
            }
         compeletion(true)
        }
        editAction.backgroundColor = .orange
        editAction.image = UIImage(systemName: "square.and.pencil")?.withTintColor(.white)
        
        //MARK: -- cell delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { contextAction, view, compeletion in
            if let thisCategory = self.categoryList?[indexPath.row] {
                do {
                    try self.realm.write({
                        self.tableView.beginUpdates()
                        self.realm.delete(thisCategory)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.tableView.endUpdates()
                    })
                } catch {
                    print("Error deleting category --- \(error) ---")
                }
            }
            compeletion(true)
        }
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(systemName: "trash.fill")?.withTintColor(.white)
        
        
        //MARK: -- change cell color action
        
        let changeColorAction = UIContextualAction(style: .destructive, title: "Change Color") { contextAction, view, completion in
            if let thisCategory = self.categoryList?[indexPath.row] {
                
                do {
                    try self.realm.write({
                        thisCategory.cellColor = UIColor.randomFlat().hexValue()
                    })
                } catch {
                    fatalError("Error changing cell color")
                }
                
                self.tableView.reloadData()
            }
        }
        changeColorAction.backgroundColor = .green
        changeColorAction.image = UIImage(systemName: "paintpalette")?.withTintColor(.white)
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction,changeColorAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SharedStatistics.fromCategoryToItemsSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationViewController.selectedCategory = categoryList?[indexPath.row]
        }
        
    }
}

//MARK: -- Shared Functions
extension CategoryViewController {
    func setNavbarColor () {
        guard let navbar = navigationController?.navigationBar else {fatalError("Navigation bar is not initialized yet")}
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        if traitCollection.userInterfaceStyle == .dark {
            navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navAppearance.backgroundColor = .black
            navbar.tintColor = .white
            navbar.standardAppearance = navAppearance
            navbar.scrollEdgeAppearance = navAppearance
            
        } else {
            navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
            navAppearance.backgroundColor = .white
            navbar.tintColor = .black
            navbar.standardAppearance = navAppearance
            navbar.scrollEdgeAppearance = navAppearance
        }
    }
    // hold on cell to edit category title
    @objc func handleLongPress(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let thisCell = self.categoryList?[indexPath.row]
                
                SharedStatistics.alertWithTextField(alertControllerTitle: "Editting title of item: \(indexPath.row + 1)", actionTitle: "Done", textFieldDefaultValue: thisCell?.categoryName,triggeringViewController: self) { field in
                    if let thisCategory = self.categoryList?[indexPath.row] {
                        
                        do {
                            try self.realm.write({
                                thisCategory.categoryName = field.text!
                            })
                        } catch {
                            print("Error editting category title --- \(error) ---")
                        }
                        
                        self.tableView.reloadData()
                        
                    }
                }
            }
        }
    }
    func loadData() {
        categoryList = realm.objects(Category.self)
        tableView.reloadData()
    }
}
//MARK: -- Dark mode and light mode hanndler

extension CategoryViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
       setNavbarColor()
    }
}
