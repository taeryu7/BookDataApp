//
//  CoreDataManager.swift
//  BookDataApp
//
//  Created by 유태호 on 12/30/24.
//

// MARK: - CoreDataManager.swift
import UIKit
import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.persistentContainer
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.saveContext()
    }
    
    func saveBook(_ book: Book) {
        let entity = NSEntityDescription.entity(forEntityName: "BookEntity", in: context)!
        let bookEntity = NSManagedObject(entity: entity, insertInto: context)
        
        bookEntity.setValue(book.title, forKey: "title")
        bookEntity.setValue(Int64(book.price), forKey: "price")
        bookEntity.setValue(book.isbn, forKey: "isbn")
        bookEntity.setValue(book.thumbnail, forKey: "thumbnail")
        bookEntity.setValue(book.contents, forKey: "bookDescription")
        bookEntity.setValue(book.publisher, forKey: "publisher")
        bookEntity.setValue(book.authors as NSObject, forKey: "authors")
        
        saveContext()
    }
    
    func fetchBooks() -> [Book] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BookEntity")
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { entity in
                Book(
                    authors: (entity.value(forKey: "authors") as? [String]) ?? [],
                    contents: entity.value(forKey: "bookDescription") as? String ?? "",
                    datetime: "",
                    isbn: entity.value(forKey: "isbn") as? String ?? "",
                    price: Int(entity.value(forKey: "price") as? Int64 ?? 0),
                    publisher: entity.value(forKey: "publisher") as? String ?? "",
                    sale_price: 0,
                    status: "",
                    thumbnail: entity.value(forKey: "thumbnail") as? String ?? "",
                    title: entity.value(forKey: "title") as? String ?? "",
                    translators: [],
                    url: ""
                )
            }
        } catch {
            print("Error fetching books: \(error)")
            return []
        }
    }
    
    func deleteBook(with isbn: String) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BookEntity")
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", isbn)
        
        do {
            let results = try context.fetch(fetchRequest)
            results.forEach { context.delete($0) }
            saveContext()
        } catch {
            print("Error deleting book: \(error)")
        }
    }
}
