//
//  ViewController.swift
//  ebac-noticias
//
//  Created by Josaphat Campos Pereira on 30/01/23.
//

import UIKit

class MainTableViewController: UITableViewController {

    var items: Array = ["Jo", "Luiza", "João", "Aline"]
    var newsData = [NewsData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("View did load chamado")
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.barTintColor = UIColor.purple
        self.navigationController?.navigationBar.isOpaque = false
        
        callnewsdata()
    }
    
    func callnewsdata(){
        NetworkManager.shared.getNews { [weak self] result in
            guard let self = self else {return}
            
            switch result{
            case .success(let response):
                for item in response{
                    if let imageURL = item.media.first?.mediaMetadata.last?.url {
                        let data = NewsData(title: item.title, byline: item.byline, image: imageURL, url: item.url)
                        self.newsData.append(data)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error chamada api: \(error)")
            
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsData.count
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100.0
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NetworkTableViewCell
//        cell.textLabel?.text = newsData[indexPath.row].title
//        print("Linha => \(newsData[indexPath.row].title)")
        let celldata = newsData[indexPath.row]
        cell.prepare(with: celldata)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Linha => \(indexPath.row)")
    }


}

