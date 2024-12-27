//
//  Models.swift
//  BookDataApp
//
//  Created by 유태호 on 12/27/24.
//

import Foundation

/// 카카오 책 검색 API 응답을 위한 최상위 모델
struct BookSearchResponse: Codable {
    /// 책 정보 배열
    let documents: [Book]
    /// 검색 결과 메타데이터
    let meta: Meta
}

/// 책 정보를 담는 모델
struct Book: Codable {
    /// 저자 배열
    let authors: [String]
    /// 책 소개
    let contents: String
    /// 출시일 (ISO 8601 형식)
    let datetime: String
    /// 국제 표준 도서번호
    let isbn: String
    /// 정가
    let price: Int
    /// 출판사
    let publisher: String
    /// 할인가
    let sale_price: Int
    /// 판매 상태
    let status: String
    /// 표지 이미지 URL
    let thumbnail: String
    /// 제목
    let title: String
    /// 번역자 배열
    let translators: [String]
    /// 도서 상세 URL
    let url: String
}

/// 검색 결과 메타데이터 모델
struct Meta: Codable {
    /// 현재 페이지가 마지막 페이지인지 여부
    let is_end: Bool
    /// 총 페이지 수
    let pageable_count: Int
    /// 검색된 문서 수
    let total_count: Int
}
