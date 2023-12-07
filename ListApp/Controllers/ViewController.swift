//
//  ViewController.swift
//  ListApp
//
//  Created by Bekir Berke Yılmaz on 7.12.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    //Define TableView
    @IBOutlet weak var tableView: UITableView!
    var alertController = UIAlertController()
    
    var data: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        fetch()
    }
    
    //Add Button Action
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem){
        presentAddAlert()
    }
    
    //Delete Button Action
    @IBAction func didRemoveBarButtonItemTapped(_ sender: UIBarButtonItem){
        presentAlert(title: "Uyarı", message: "Bütün verileri silmek istediğinize emin misiniz ?", defaultButtonTitle: "Evet", cancelButtonTitle: "Vazgeç", defaultButtonHandler: {_ in
            self.data.removeAll()
            self.tableView.reloadData()
        })
    }
    
    func presentAddAlert(){
        presentAlert(title: "Yeni Eleman Ekle", message: nil, defaultButtonTitle: "Ekle", cancelButtonTitle: "Vazgeç", defaultButtonHandler:{_ in
            let text = self.alertController.textFields?.first?.text
            if(text != ""){
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: managedObjectContext!)
                let listItem = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                listItem.setValue(text, forKey: "title")
                try? managedObjectContext?.save()
                self.fetch()
            }else{
                self.presentWarningAlert()
            }
        }, isTextFieldAvaible: true )
    }
    
    func presentWarningAlert(){
        presentAlert(title: "Uyarı", message: "Liste elemanı boş olamaz", cancelButtonTitle: "Tamam")
    }
    
    //Create Alert
    func presentAlert(title: String?, message: String?, defaultButtonTitle:String? = nil, preferredStyle: UIAlertController.Style = .alert, cancelButtonTitle: String?, defaultButtonHandler: ((UIAlertAction) -> Void)? = nil, isTextFieldAvaible: Bool = false){
        
        alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        let cancelButton = UIAlertAction(title: cancelButtonTitle, style: .cancel)
        if defaultButtonTitle != nil {
            let defaultButton = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultButtonHandler)
            alertController.addAction(defaultButton)
        }
        
        if isTextFieldAvaible{
            alertController.addTextField()
        }
        alertController.addAction(cancelButton)
        present(alertController, animated: true)

    }
    
    // Fetch From Core Data
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        data = try! managedObjectContext!.fetch(fetchRequest)
        tableView.reloadData()
    }
}

//TableView Configuration
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    //Define Table View Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    //Define Cell In Table View Rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    //Right Swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Delete Swipe Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil", handler: {_, _, _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            managedObjectContext?.delete(self.data[indexPath.row])
            try?managedObjectContext?.save()
            self.fetch()
        })
        
        //Edit Swipe Action
        let editAction = UIContextualAction(style: .normal, title: "Düzenle", handler: {_, _, _ in
            self.presentAlert(title: "Yeni Eleman Ekle", message: nil, defaultButtonTitle: "Düzenle", cancelButtonTitle: "Vazgeç", defaultButtonHandler:{_ in
                let text = self.alertController.textFields?.first?.text
                if(text != ""){
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let managedObjectContext = appDelegate?.persistentContainer.viewContext
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    if managedObjectContext!.hasChanges{
                        try? managedObjectContext?.save()
                    }
                    self.tableView.reloadData()
                }else{
                    self.presentWarningAlert()
                }
            }, isTextFieldAvaible: true )
        })
        
        //Swipe Config
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
}

