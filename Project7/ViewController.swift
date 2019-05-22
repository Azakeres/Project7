//
//  ViewController.swift
//  Project7
//
//  Created by Arash Zakeresfahani on 3/26/19.
//  Copyright © 2019 Arash Zakeresfahani. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var searchedPetitions = [Petition]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(credits))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
        }
    
        @objc func fetchJSON(){
            let urlString: String
            if navigationController?.tabBarItem.tag == 0 {
                urlString = "https://hackingwithswift.com/samples/petitions-1.json"
            }else {
                urlString = "https://hackingwithswift.com/samples/petitions-2.json"
            }
                if let url = URL(string: urlString){
                    if let data = try? Data(contentsOf: url){
                        parse(json: data)
                        return
                    }
                }
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }

    
    @objc func search(){
        
        let ac = UIAlertController(title: "Credits", message: "The People API of the Whitehouse", preferredStyle: .alert)
        ac.addTextField()
        let submiteAction = UIAlertAction(title: "Submit", style: .default){
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            DispatchQueue.global(qos: .userInitiated).async {
                self?.submit(answer)
            }
            }
        ac.addAction(submiteAction)
        present(ac, animated: true)
        
    }
    
    @objc func submit(_ answer: String){
        searchedPetitions.removeAll()
        for pet in petitions {
            let title = pet.title.lowercased()
            if answer.isEmpty{
                searchedPetitions = petitions
            }else if title.contains(answer.lowercased()){
                searchedPetitions.append(pet)
            }
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            
        }
    }
    
    @objc func credits(){
        let ac = UIAlertController(title: "Credits", message: "The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    
    func parse(json: Data){
        
        let decoder = JSONDecoder()
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json){
            petitions = jsonPetitions.results
            searchedPetitions = petitions
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        }else{
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    @objc func showError(){
        let ac = UIAlertController(title: "Loading error", message: "Could not load the URL", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = searchedPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = searchedPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

