//
//  DetailViewController.swift
//  MapKit-Swift
//
//  Created by Fazlı Koç on 27.09.2022.
//

import UIKit
import CoreData

class DetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var nameArray = [String]()
    var UUIDArray = [UUID]()
    
    
    var slctLocationName=String()
    var slctLocationID : UUID?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTopBar))
        getDataToCore()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=UITableViewCell()
        cell.textLabel?.text=nameArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        slctLocationName=nameArray[indexPath.row]
        slctLocationID = UUIDArray[indexPath.row]
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapVC"{
            let destinationVC = segue.destination as! MapsViewController
            destinationVC.slctDetailName=slctLocationName
            destinationVC.slctDetailID=slctLocationID
        }
    }
    
    @objc func addTopBar(){
        slctLocationName=""
        performSegue(withIdentifier: "toMapVC", sender: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getDataToCore), name: NSNotification.Name(rawValue: "insert"), object: nil)
    }
    
    
    
    @objc func getDataToCore(){
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        
        do{
            let  datas = try context.fetch(request)
            if datas.count > 0 {
                nameArray.removeAll(keepingCapacity: false)
                UUIDArray.removeAll(keepingCapacity: false)
                for data in datas as! [NSManagedObject]{
                    if let nameCast = data.value(forKey: "name") as? String{
                        nameArray.append(nameCast)
                    }
                    if let idCast = data.value(forKey: "id") as? UUID{
                        UUIDArray.append(idCast)
                        
                    }
                }
            }
            tableView.reloadData()
        }
        catch{
            print("Data Gelirken Hata")
        }
    }
}
