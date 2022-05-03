//
//  TasksViewController.swift
//  ToDoFire
//
//  Created by Zhasur Sidamatov on 03/05/2022.
//

import UIKit
import Firebase

final class TasksViewController: UIViewController {
    
    private let cellIdentifier = "Cell"
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
    }
    
    
    @IBAction func signOutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
}


//MARK: - Extensions

extension TasksViewController: UITableViewDelegate {
    
}

extension TasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        configureCell(&cell, indexPath: indexPath)
        return cell
    }
    
    
    private func configureCell(_ cell: inout UITableViewCell, indexPath: IndexPath) {
        var config = cell.defaultContentConfiguration()
        config.text = "This is cell number \(indexPath.row)"
        config.textProperties.color = .white
        cell.contentConfiguration = config
    }
    
    
}
