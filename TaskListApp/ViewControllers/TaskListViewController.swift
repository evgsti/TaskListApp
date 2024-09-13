//
//  ViewController.swift
//  TaskListApp
//
//  Created by Alexey Efimov on 11.02.2024.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private var taskList: [ToDoTask] = []
    private let cellID = "task"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        fetchData()
    }
    
    private func showTaskAlert(
        withTitle title: String,
        message: String,
        taskToEdit: ToDoTask? = nil,
        completion: @escaping (String) -> Void
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = taskToEdit?.title
            textField.placeholder = "Task name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            completion(taskName)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - Data Management
extension TaskListViewController {
    private func fetchData() {
        StorageManager.shared.fetchTasks { [weak self] tasks in
            self?.taskList = tasks
            self?.tableView.reloadData()
        }
    }
    
    private func create(_ taskName: String) {
        StorageManager.shared.createTask(taskName) { [weak self] task in
            guard let self = self else { return }
            
            self.taskList.append(task)
            let indexPath = IndexPath(row: self.taskList.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func update(_ task: ToDoTask, with newTitle: String, at indexPath: IndexPath) {
        StorageManager.shared.updateTask(task, withTitle: newTitle)
        taskList[indexPath.row] = task
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let toDoTask = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = toDoTask.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskToEdit = taskList[indexPath.row]
        showTaskAlert(
            withTitle: "Edit Task",
            message: "Update your task",
            taskToEdit: taskToEdit
        ) { [weak self] newTaskName in
            self?.update(taskToEdit, with: newTaskName, at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToDelete = taskList[indexPath.row]
            
            StorageManager.shared.deleteTask(taskToDelete)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.backgroundColor = .milkBlue
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        let addAction = UIAction { [weak self] _ in
            self?.showTaskAlert(
                withTitle: "New Task",
                message: "What do you want to do?"
            ) { taskName in
                self?.create(taskName)
            }
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: addAction
        )
        navigationController?.navigationBar.tintColor = .white
    }
}
