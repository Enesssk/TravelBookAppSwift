//
//  TableViewController.swift
//  TravelBookAppSwift
//
//  Created by Enes Kala on 2.03.2024.
//

import UIKit
import CoreData

class TableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var titleArray = [String] ()
    var idArray = [UUID] ()
    var chosenTitle = ""
    var chosenId = UUID()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    func getData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchReguest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchReguest)
            
            for result in results as! [NSManagedObject] {
                
                if let nameTitle = result.value(forKey: "title") as? String {
                    titleArray.append(nameTitle)
                }
                if let id = result.value(forKey: "id") as? UUID {
                    idArray.append(id)
                }
            }
            
        }catch{
            print ("Error at dataShow")
        }
    }
    
    @objc func addButtonClicked() {
        chosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenTitle = titleArray[indexPath.row]
        chosenId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController" {
            let destination = segue.destination as! ViewController
            destination.selectedId = chosenId
            destination.selectedTitle = chosenTitle
        }
    }
    

 

}
