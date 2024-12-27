//
//  ViewModels.swift
//  BookDataApp
//
//  Created by 유태호 on 12/27/24.
//

import UIKit

/// 책 검색 화면의 비즈니스 로직을 처리하는 뷰모델
class BookSearchViewModel {
    /// 카카오 API 키
    private let apiKey = "ff02cd54f624b6cfc75f5477a8eb84ed"
    /// 검색된 책 목록
    private(set) var books: [Book] = []
    /// 책 목록이 업데이트될 때 호출되는 클로저
    var onBooksUpdated: (() -> Void)?
    
    /// 책을 검색하는 메서드
    /// - Parameter query: 검색어
    func searchBooks(query: String) {
        // 검색어를 URL 인코딩하고 URL 생성
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://dapi.kakao.com/v3/search/book?query=\(encodedQuery)") else {
            return
        }
        
        // API 요청 설정
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Authorization": "KakaoAK \(apiKey)"]
        
        // API 호출 및 응답 처리
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode(BookSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.books = response.documents
                    self.onBooksUpdated?()
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }.resume()
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
}

/// 북마크 화면의 비즈니스 로직을 처리하는 뷰모델
class BookmarkViewModel {
    /// 북마크된 책 목록
    private var bookmarks: [Book] = []
    /// 북마크 목록이 업데이트될 때 호출되는 클로저
    var onBookmarksUpdated: (() -> Void)?
    
    /// 책을 북마크에 추가하는 메서드
    /// - Parameter book: 추가할 책 정보
    func addBookmark(_ book: Book) {
        bookmarks.append(book)
        onBookmarksUpdated?()
    }
    
    /// 북마크된 책 목록을 반환하는 메서드
    /// - Returns: 북마크된 책 배열
    func getBookmarks() -> [Book] {
        return bookmarks
    }
    
    /// 북마크된 책의 개수
    var bookmarkCount: Int {
        return bookmarks.count
    }
}