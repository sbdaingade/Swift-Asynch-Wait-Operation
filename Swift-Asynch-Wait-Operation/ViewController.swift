//
//  ViewController.swift
//  Swift-Asynch-Wait-Operation
//
//  Created by Sachin Daingade on 16/12/21.
//

import UIKit

struct User: Codable {
    let name: String
}

class ViewController: UIViewController, UITableViewDataSource {
    
    
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")
    private var users = [User]()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        fetchUsers { result in
            switch result {
            case .success(let newUsers):
                self.users = newUsers
                DispatchQueue.main.async {[weak self] in
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    enum UserError: Error {
        case failToFetchResult
    }
    
    private func fetchUsers(complition:@escaping (Result<[User],Error>)-> Void) {
        guard let url = url else {
            return  complition(.failure(UserError.failToFetchResult))
        }
        
        URLSession.shared.dataTask(with: url) {data,response,error  in
            do {
                if error != nil {
                    complition(.failure(UserError.failToFetchResult))
                }
                let newUsers = try JSONDecoder().decode([User].self, from: data!)
                complition(.success(newUsers))
            }catch {
                complition(.failure(UserError.failToFetchResult))
            }
        }.resume()
    }
    
    //MARK: Note xcode 13 required
    
    //    private func fetchUsers() async -> Result<[User],Error> {
    //    guard let url = url else {
    //    return .failure(UserError.failToFetchResult)
    //    }
    //    do {
    //    let (data,_) = try await URLSession.shared.data(from:url)
    //    let users = try JSONDecoder().decode([User].self, from: data)
    //    return .success(users)
    //    } catch {
    //    return .failure(UserError.failToFetchResult)
    //    }
    //    }
    //
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
    
    
}

