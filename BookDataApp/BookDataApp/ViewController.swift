//
//  ViewController.swift
//  BookDataApp
//
//  Created by 유태호 on 12/26/24.
//

import UIKit
import SnapKit
import CoreData

// MARK: - ViewController (TabBarController)
/// 앱의 메인 탭바 컨트롤러
class ViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    /// 탭바 설정을 위한 메서드
    private func setupTabBar() {
        // 첫 번째 탭 - 검색 화면 설정
        let searchVC = BookSearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass.fill")
        )
        
        // 두 번째 탭 - 북마크 화면 설정
        let bookmarkVC = BookmarkViewController()
        let bookmarkNav = UINavigationController(rootViewController: bookmarkVC)
        bookmarkNav.tabBarItem = UITabBarItem(
            title: "저장된 책",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )
        
        // 탭바 컨트롤러 기본 설정
        self.viewControllers = [searchNav, bookmarkNav]
        self.tabBar.tintColor = .systemBlue
        self.tabBar.backgroundColor = .white
    }
}

// MARK: - BookSearchViewController
/// 책 검색 화면 뷰 컨트롤러
class BookSearchViewController: UIViewController {
    
    // MARK: - Properties
    /// 검색 화면의 비즈니스 로직을 처리하는 뷰모델
    private let viewModel = BookSearchViewModel()
    
    /// 검색바 UI 컴포넌트
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색할 책 제목을 입력해주세요"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .systemGray6
        return searchBar
    }()
    
    /// 필터 섹션 레이블
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 본 책"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    /// 필터 컨테이너 뷰
    private let filterContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 색상 필터 뷰들
    private let redFilterView = UIView()
    private let orangeFilterView = UIView()
    private let yellowFilterView = UIView()
    private let greenFilterView = UIView()
    
    /// 검색 결과 섹션 레이블
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    /// 검색 결과를 표시하는 테이블뷰
    private let bookListTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.systemGray5.cgColor
        tableView.layer.cornerRadius = 8
        return tableView
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupTableView()
        setupBindings()
        searchBar.delegate = self
    }
    
    // MARK: - Setup Methods
    /// 뷰모델과 뷰의 바인딩 설정
    private func setupBindings() {
        viewModel.onBooksUpdated = { [weak self] in
            self?.bookListTableView.reloadData()
        }
    }
    
    /// UI 구성을 위한 메서드
    private func configureUI() {
        setupBackground()
        setupComponents()
        setupConstraints()
    }
    
    /// 배경 설정
    private func setupBackground() {
        view.backgroundColor = .white
    }
    
    /// UI 컴포넌트 초기 설정
    private func setupComponents() {
        // 필터 뷰 설정
        [redFilterView, orangeFilterView, yellowFilterView, greenFilterView].forEach {
            $0.layer.cornerRadius = 15
            filterContainerView.addSubview($0)
        }
        redFilterView.backgroundColor = .red
        orangeFilterView.backgroundColor = .orange
        yellowFilterView.backgroundColor = .yellow
        greenFilterView.backgroundColor = .green
        
        // 메인 컴포넌트들을 뷰에 추가
        [searchBar, filterLabel, filterContainerView, resultLabel, bookListTableView].forEach {
            view.addSubview($0)
        }
    }
    /// 테이블뷰 초기 설정
    private func setupTableView() {
        bookListTableView.delegate = self
        bookListTableView.dataSource = self
        bookListTableView.register(BookSearchCell.self, forCellReuseIdentifier: "BookSearchCell")
    }
    
    /// UI 컴포넌트들의 제약조건 설정
    private func setupConstraints() {
        // 검색바 제약조건
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // 필터 레이블 제약조건
        filterLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        // 필터 컨테이너 제약조건
        filterContainerView.snp.makeConstraints { make in
            make.top.equalTo(filterLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        // 필터 뷰들의 크기 및 간격 설정
        let filterSize = 30
        let spacing = 10
        
        // 각 필터 뷰의 제약조건 설정
        redFilterView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(filterSize)
        }
        
        orangeFilterView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(redFilterView.snp.trailing).offset(spacing)
            make.width.height.equalTo(filterSize)
        }
        
        yellowFilterView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(orangeFilterView.snp.trailing).offset(spacing)
            make.width.height.equalTo(filterSize)
        }
        
        greenFilterView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(yellowFilterView.snp.trailing).offset(spacing)
            make.width.height.equalTo(filterSize)
        }
        
        // 결과 레이블 제약조건
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(filterContainerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        // 테이블뷰 제약조건
        bookListTableView.snp.makeConstraints { make in
            make.top.equalTo(resultLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
}

// MARK: - UISearchBarDelegate
extension BookSearchViewController: UISearchBarDelegate {
    /// 검색바에서 검색 버튼이 클릭되었을 때 호출되는 메서드
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchBar.resignFirstResponder()
        viewModel.searchBooks(query: query)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BookSearchViewController: UITableViewDelegate, UITableViewDataSource {
    /// 테이블뷰의 행 개수를 반환하는 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.books.count
    }
    
    /// 각 행의 셀을 구성하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookSearchCell", for: indexPath) as! BookSearchCell
        let book = viewModel.books[indexPath.row]
        cell.configure(title: book.title, price: "\(book.price)원")
        return cell
    }
    
    /// 각 행의 높이를 반환하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    /// 셀이 선택되었을 때 호출되는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = BookDetailViewController()
        detailVC.viewModel = BookDetailViewModel(book: viewModel.books[indexPath.row])
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
}

// MARK: - BookSearchCell
/// 책 검색 결과를 표시하는 테이블뷰 셀
class BookSearchCell: UITableViewCell {
    /// 책 제목 레이블
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    /// 책 가격 레이블
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    /// 셀 초기화 메서드
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 셀 UI 구성 메서드
    private func setupCell() {
        [titleLabel, priceLabel].forEach {
            contentView.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    /// 셀 데이터 구성 메서드
    /// - Parameters:
    ///   - title: 책 제목
    ///   - price: 책 가격
    func configure(title: String, price: String) {
        titleLabel.text = title
        priceLabel.text = price
    }
}

// MARK: - BookDetailViewController
/// 책 상세 정보를 표시하는 뷰 컨트롤러
class BookDetailViewController: UIViewController {
    /// 책 상세 정보를 처리하는 뷰모델
    var viewModel: BookDetailViewModel!
    
    /// 책 표지 이미지를 표시하는 이미지뷰
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    /// 책 제목 레이블
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    /// 책 가격 레이블
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()
    
    /// 북마크 추가 버튼
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("담기", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
    /// 닫기 버튼
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    /// 책 설명 레이블
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0  // 여러 줄 표시 가능
        return label
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupActions()
        updateUI()
    }
    
    /// UI 구성 메서드
    private func configureUI() {
        view.backgroundColor = .white
        
        [bookImageView, titleLabel, priceLabel, descriptionLabel, addButton, closeButton].forEach {
            view.addSubview($0)
        }
        
        setupDetailConstraints()
    }
    
    
    /// UI 컴포넌트들의 제약조건 설정
    private func setupDetailConstraints() {
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(30)
        }
        
        bookImageView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bookImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(descriptionLabel.snp.bottom).offset(20)  // 설명과 겹치지 않도록
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
    }
    
    /// 버튼 액션 설정
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    /// UI 업데이트 메서드
    private func updateUI() {
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.priceText
        descriptionLabel.text = viewModel.description  // 설명 업데이트
        
        viewModel.loadImage { [weak self] image in
            self?.bookImageView.image = image
        }
    }
    
    /// 닫기 버튼 액션 메서드
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    /// 담기 버튼 액션 메서드
    @objc private func addTapped() {
        viewModel.saveBook()
        
        let alert = UIAlertController(title: "성공", message: "책이 저장되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - BookmarkViewController
/// 북마크된 책 목록을 표시하는 뷰 컨트롤러
class BookmarkViewController: UIViewController {
    // MARK: - Properties
    /// 북마크 관련 비즈니스 로직을 처리하는 뷰모델
    private let viewModel = BookmarkViewModel()
    
    /// 화면 제목 레이블
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "담은 책"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    /// 북마크 목록을 표시하는 테이블뷰
    private let bookmarkTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.systemGray5.cgColor
        tableView.layer.cornerRadius = 8
        return tableView
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupTableView()
    }
    
    // MARK: - UI Configuration
    /// UI 구성 메서드
    private func configureUI() {
        view.backgroundColor = .white
        
        [titleLabel, bookmarkTableView].forEach {
            view.addSubview($0)
        }
        
        // UI 컴포넌트들의 제약조건 설정
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        bookmarkTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    /// 테이블뷰 초기 설정
    private func setupTableView() {
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
        bookmarkTableView.register(BookSearchCell.self, forCellReuseIdentifier: "BookSearchCell")
    }
}


// MARK: - BookmarkViewController TableView Extension
extension BookmarkViewController: UITableViewDelegate, UITableViewDataSource {
    /// 테이블뷰의 행 개수를 반환하는 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarkCount
    }
    
    /// 각 행의 셀을 구성하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookSearchCell", for: indexPath) as! BookSearchCell
        let bookmarks = viewModel.getBookmarks()
        let book = bookmarks[indexPath.row]
        cell.configure(title: book.title, price: "\(book.price)원")
        return cell
    }
    
    /// 각 행의 높이를 반환하는 메서드
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    /// 셀이 선택되었을 때 호출되는 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bookmarks = viewModel.getBookmarks()
        let detailVC = BookDetailViewController()
        detailVC.viewModel = BookDetailViewModel(book: bookmarks[indexPath.row])
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
}

extension BookmarkViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookmarkTableView.reloadData()
    }
}

// MARK: - SwiftUI Preview
/// SwiftUI 프리뷰를 위한 설정
#Preview {
    ViewController()
}
