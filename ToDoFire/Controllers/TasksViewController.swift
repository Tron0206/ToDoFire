//
//  TasksViewController.swift
//  ToDoFire
//
//  Created by Zhasur Sidamatov on 03/05/2022.
//

import UIKit
import Firebase

final class TasksViewController: UIViewController {
    
    var user: Client!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    
    private let cellIdentifier = "Cell"
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUser()
        createRef()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value) { [weak self] snapshot in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tableView.reloadData()
        }
    }
    
    //Get current user
    private func getUser() {
        guard let currentUser = Auth.auth().currentUser else { return }
        user = Client(user: currentUser)
    }
    
    //Create reference to database
    private func createRef() {
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Task Name"
        }
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first,
                  textField.text != "" else { return }
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            let tasksRef = self?.ref.child(task.title.lowercased())
            tasksRef?.setValue(task.convertToDictionary())
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
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
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        configureCell(&cell, indexPath: indexPath)
        return cell
    }
    
    
    private func configureCell(_ cell: inout UITableViewCell, indexPath: IndexPath) {
        var config = cell.defaultContentConfiguration()
        let taskTitle = tasks[indexPath.row].title
        config.text = taskTitle
        config.textProperties.color = .white
        cell.contentConfiguration = config
    }
    
    
}
