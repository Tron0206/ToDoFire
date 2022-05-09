//
//  TasksViewController.swift
//  ToDoFire
//
//  Created by Zhasur Sidamatov on 03/05/2022.
//

import UIKit
import Firebase

final class TasksViewController: UIViewController {
    
    //MARK: - Properties
    
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
        addRefObserve()
    }
    
    //MARK: - @IBAction
    
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
    
    
    //MARK: - Method
    
    private func getUser() {
        guard let currentUser = Auth.auth().currentUser else { return }
        user = Client(user: currentUser)
    }
    
    
    private func createRef() {
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    private func addRefObserve() {
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        
        toggleCompletion(cell, isCompleted: isCompleted)
        task.ref?.updateChildValues(["completed" : isCompleted])
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    private func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
    private func configureCell(_ cell: inout UITableViewCell, indexPath: IndexPath) {
        var config = cell.defaultContentConfiguration()
        let task = tasks[indexPath.row]
        config.text = task.title
        config.textProperties.color = .white
        toggleCompletion(cell, isCompleted: task.completed)
        cell.contentConfiguration = config
    }
    
    
}
