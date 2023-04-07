//
//  ViewController.swift
//  ebac-noticias
//
//  Created by Josaphat Campos Pereira on 30/01/23.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {

    var fetchedResultController: NSFetchedResultsController<NewsData>!
    var newsData = [NewsData]()
    var dataController:DataController!
    
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load chamado")
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.purple
        self.navigationController?.navigationBar.isOpaque = false
        setupFetchedREsultController()
        showIndicator()
        callnewsdata()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print("View did appear chamado")
//        setupFetchedREsultController()
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultController = nil
    }
    
    fileprivate func setupFetchedREsultController(){
        let fetchRequest: NSFetchRequest<NewsData> = NewsData.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "appNoticias")
        
        fetchedResultController.delegate = self
        
        do{
            try fetchedResultController.performFetch()
        }catch{
            print("No Fetched Controller")
        }
    }
    
    fileprivate func deleteData(){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NewsData.fetchRequest()
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        do{
            let context = dataController.viewContext
            let result = try context.execute(deleteRequest)
            
            guard let deleteResult = result as? NSBatchDeleteResult,
                  let ids = deleteResult.result as? [NSManagedObjectID] else{
                return
            }
            
            let changes = [NSDeletedObjectsKey: ids]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        }catch{
            print("error: \(error as Any)")
        }
        DispatchQueue.main.async {
           self.tableView.reloadData()
       }
    }
    
    func callnewsdata(){
        NetworkManager.shared.getNews { [weak self] result in
            guard let self = self else {return}
            
            switch result{
            case .success(let response):
                deleteData()
                for item in response{
                    
                    let data = NewsData(context: self.dataController.viewContext)
                    data.url = item.url
                    data.title = item.title
                    data.byline = item.byline
                    
                    if let image = item.media.first?.mediaMetadata.last?.url {
//                        let data = NewsData(title: item.title, byline: item.byline, image: imageURL, url: item.url)
//                        self.newsData.append(data)
                        guard let imageURL = URL(string: image) else {return}
                        guard let imageData = try? Data(contentsOf: imageURL) else{return}
                        
                        data.image = image
                        data.imagedata = imageData
                        
                    }
                    
                    try? self.dataController.viewContext.save()
                    
                }
                
            case .failure(let error):
                print("Error chamada api: \(error)")
            
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.hideIndicator()
            }
        }
    }
    
    func showIndicator(){
        activityIndicator = UIActivityIndicatorView(style: .large)
        guard let activityIndicator = activityIndicator else{
            return
        }
        
        self.view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.widthAnchor.constraint(equalToConstant: 70),
            activityIndicator.heightAnchor.constraint(equalToConstant: 70),
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func hideIndicator(){
        guard let activityIndicator = activityIndicator else{
            return
        }
        activityIndicator.stopAnimating()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let aNewsData = fetchedResultController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NetworkTableViewCell
        
        cell.celltitlelabel.text = aNewsData.title
        cell.bylinelabel.text = aNewsData.byline
        
        if let imageData = aNewsData.imagedata{
            cell.cellimageview.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Linha => \(indexPath.row)")
        let aNewsData = fetchedResultController.object(at: indexPath)
        
        guard let url = aNewsData.url else{ return}
        
        if let url = URL(string: url){
            UIApplication.shared.open(url)
        }
    }


}

extension MainTableViewController: NSFetchedResultsControllerDelegate{
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if  newIndexPath != nil{
                tableView.insertRows(at: [newIndexPath!], with: .none)
            }
            break
        case .delete:
            if  let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .none)
            }
            break
        case .move, .update:
            break
        @unknown default:
            print("Erro")
        }
    }
    
}
