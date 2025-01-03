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

extension CoreDataManager {
    func saveRecentBook(_ book: Book) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecentBook")
        fetchRequest.predicate = NSPredicate(format: "isbn == %@", book.isbn)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existing = results.first {
                existing.setValue(Date(), forKey: "viewedAt")
                existing.setValue(book.thumbnail, forKey: "thumbnail")
                existing.setValue(book.title, forKey: "title")
                existing.setValue(book.contents, forKey: "contents")
                existing.setValue(book.price, forKey: "price")
            } else {
                let entity = NSEntityDescription.entity(forEntityName: "RecentBook", in: context)!
                let recentBook = NSManagedObject(entity: entity, insertInto: context)
                recentBook.setValue(book.isbn, forKey: "isbn")
                recentBook.setValue(Date(), forKey: "viewedAt")
                recentBook.setValue(book.thumbnail, forKey: "thumbnail")
                recentBook.setValue(book.title, forKey: "title")
                recentBook.setValue(book.contents, forKey: "contents")
                recentBook.setValue(book.price, forKey: "price")
            }
            saveContext()
            
            // 10개 제한 유지
            cleanupOldRecentBooks()
        } catch {
            print("Error saving recent book: \(error)")
        }
    }

    func fetchRecentBooks() -> [Book] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecentBook")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "viewedAt", ascending: false)]
        fetchRequest.fetchLimit = 10

        do {
            let recentResults = try context.fetch(fetchRequest)
            
            // 최근 본 순서대로 책 정보 매핑
            return recentResults.compactMap { recentEntity -> Book in
                let isbn = recentEntity.value(forKey: "isbn") as? String ?? ""
                let thumbnail = recentEntity.value(forKey: "thumbnail") as? String ?? ""
                let title = recentEntity.value(forKey: "title") as? String ?? ""
                let contents = recentEntity.value(forKey: "contents") as? String ?? ""
                let price = recentEntity.value(forKey: "price") as? Int ?? 0
                
                return Book(
                    authors: [],
                    contents: contents,
                    datetime: "",
                    isbn: isbn,
                    price: price,
                    publisher: "",
                    sale_price: 0,
                    status: "",
                    thumbnail: thumbnail,
                    title: title,
                    translators: [],
                    url: ""
                )
            }
        } catch {
            print("Error fetching recent books: \(error)")
            return []
        }
    }
    
    private func cleanupOldRecentBooks() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecentBook")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "viewedAt", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 10 {
                for index in 10..<results.count {
                    context.delete(results[index])
                }
                saveContext()
            }
        } catch {
            print("Error cleaning up old recent books: \(error)")
        }
    }
}
