//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Евгений on 12.09.2024.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let context: NSManagedObjectContext
    
    private init() {
        context = persistentContainer.viewContext
    }
    
    // MARK: - CRUD Methods
    func fetchTasks(completion: @escaping ([ToDoTask]) -> Void) {
        let fetchRequest: NSFetchRequest<ToDoTask> = ToDoTask.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            completion(tasks)
        } catch let error {
            print("Failed to fetch tasks: \(error)")
            completion([])
        }
    }
    
    func createTask(_ title: String, completion: @escaping (ToDoTask) -> Void) {
        let task = ToDoTask(context: context)
        task.title = title
        
        do {
            try context.save()
            completion(task)
        } catch let error {
            print("Failed to save task: \(error)")
        }
    }
    
    func updateTask(_ task: ToDoTask, withTitle title: String) {
        task.title = title
        
        do {
            try context.save()
        } catch let error {
            print("Failed to update task: \(error)")
        }
    }
    
    func deleteTask(_ task: ToDoTask) {
        context.delete(task)
        
        do {
            try context.save()
        } catch let error {
            print("Failed to delete task: \(error)")
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print("Failed to save context: \(error)")
            }
        }
    }
}
