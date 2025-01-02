//
//  ViewModels.swift
//  BookDataApp
//
//  Created by 유태호 on 12/27/24.
//

import UIKit
import CoreData

/// 책 검색 화면의 비즈니스 로직을 처리하는 뷰모델
class BookSearchViewModel {
    private let apiKey = "ff02cd54f624b6cfc75f5477a8eb84ed"
    private(set) var books: [Book] = []
    private(set) var recentBooks: [Book] = []
    var onBooksUpdated: (() -> Void)?
    
    // 페이지네이션을 위한 속성 추가
    private var currentQuery = ""
    private var currentPage = 1
    private var isLastPage = false
    private var isFetching = false
    
    func searchBooks(query: String) {
        // 새로운 검색일 경우 기존 데이터 초기화
        if query != currentQuery {
            books = []
            currentPage = 1
            isLastPage = false
            currentQuery = query
        }
        
        guard !isFetching, !isLastPage else { return }
        
        fetchBooks(query: query, page: currentPage)
    }
    
    private func fetchBooks(query: String, page: Int) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://dapi.kakao.com/v3/search/book?query=\(encodedQuery)&page=\(page)&size=10") else {
            return
        }
        
        isFetching = true
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(apiKey)"]
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else {
                self?.isFetching = false
                return
            }
            
            do {
                let response = try JSONDecoder().decode(BookSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.books.append(contentsOf: response.documents)
                    self.currentPage += 1
                    self.isLastPage = response.meta.is_end
                    self.isFetching = false
                    self.onBooksUpdated?()
                }
            } catch {
                print("Decoding error: \(error)")
                self.isFetching = false
            }
        }.resume()
    }
    
    // 다음 페이지 로드 메서드
    func loadNextPageIfNeeded() {
        guard !currentQuery.isEmpty else { return }
        searchBooks(query: currentQuery)
    }
}

/// 책 상세 정보 화면의 비즈니스 로직을 처리하는 뷰모델
class BookDetailViewModel {
    /// 표시할 책 정보
    let book: Book
    
    /// 생성자
    /// - Parameter book: 표시할 책 정보
    init(book: Book) {
        self.book = book
    }
    
    /// 책 표지 이미지를 로드하는 메서드
    /// - Parameter completion: 이미지 로드 완료 시 호출되는 클로저
    func loadImage(completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: book.thumbnail) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    /// 책 제목
    var title: String {
        return book.title
    }
    
    /// 가격 텍스트 (원화 표시 포함)
    var priceText: String {
        return "\(book.price)원"
    }
    
    /// 책 설명 텍스트
    var description: String {
        return book.contents
    }
}

/// 북마크 화면의 비즈니스 로직을 처리하는 뷰모델
// BookmarkViewModel을 완전히 교체
class BookmarkViewModel {
    private let coreDataManager = CoreDataManager.shared
    var onBookmarksUpdated: (() -> Void)?
    
    var bookmarkCount: Int {
        return getBookmarks().count
    }
    
    func addBookmark(_ book: Book) {
        coreDataManager.saveBook(book)
        onBookmarksUpdated?()
    }
    
    func getBookmarks() -> [Book] {
        return coreDataManager.fetchBooks()
    }
    
    func removeBookmark(isbn: String) {
        coreDataManager.deleteBook(with: isbn)
        onBookmarksUpdated?()
    }
}

extension BookSearchViewModel {
    func loadRecentBooks() {
        recentBooks = CoreDataManager.shared.fetchRecentBooks()
        onBooksUpdated?()
    }
}

// BookDetailViewModel에 추가
extension BookDetailViewModel {
    func saveBook() {
        CoreDataManager.shared.saveBook(book)
    }
    
    func deleteBook() {
        CoreDataManager.shared.deleteBook(with: book.isbn)
    }
}

// BookmarkViewModel에 추가
extension BookmarkViewModel {
    func deleteAllBookmarks() {
        let bookmarks = getBookmarks()
        bookmarks.forEach { book in
            removeBookmark(isbn: book.isbn)
        }
        onBookmarksUpdated?()
    }
}
