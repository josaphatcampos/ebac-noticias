//
//  NetworkManager.swift
//  ebac-noticias
//
//  Created by Josaphat Campos Pereira on 01/02/23.
//

import Foundation

enum ResultNewsError: Error{
    case badURL, noData, invalidJSON
}
class NetworkManager{
    
    static let shared = NetworkManager()
    
    struct Constants{
        // MARK: - CRIAR ENDPOINT
        static let newsAPI = URL(string: "https://api.jsonbin.io/v3/b/6422faa0c0e7653a0597f704")
    }
    
    private init(){}
    
    func getNews(completion: @escaping(Result<[ResultNews], ResultNewsError>) -> Void){
        
        //setup the url
        guard let url = Constants.newsAPI else {
            completion(.failure(.badURL))
            return
        }
        
        
        // create configuration
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["X-Master-Key": "$2b$10$yzkT/VzA/LlMlbq2LwGzE.RuhQqfBKyI6UOJsGjnc4XezSkFtX7iS"]
        //create a session
        let session = URLSession(configuration: configuration)
        
        //create the task
        let task = session.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else{
                completion(.failure(.invalidJSON))
                return
            }
            
            do{
                let decoder = JSONDecoder()
                let result = try decoder.decode(RecordsNews.self, from: data)
                completion(.success(result.record.results))
            }catch {
                print("Error info: \(error.localizedDescription)")
//                print("Response info: \(response)")
                completion(.failure(.noData))
            }
        }
        
        task.resume()
    }
}
