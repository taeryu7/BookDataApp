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
    
    // 컬렉션뷰 선언 추가
    private let recentBooksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 140)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.clipsToBounds = true
        return collectionView
    }()
    
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadRecentBooks()
    }
    
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
            guard let self = self else { return }
            self.bookListTableView.reloadData()
            self.recentBooksCollectionView.reloadData()
            
            // 최근 본 책 섹션 표시/숨김 처리
            let hasRecentBooks = !self.viewModel.recentBooks.isEmpty
            self.filterLabel.isHidden = !hasRecentBooks
            self.recentBooksCollectionView.isHidden = !hasRecentBooks
            
            // 결과 레이블의 제약조건 동적 업데이트
            self.resultLabel.snp.remakeConstraints { make in
                if hasRecentBooks {
                    make.top.equalTo(self.recentBooksCollectionView.snp.bottom).offset(20)
                } else {
                    make.top.equalTo(self.searchBar.snp.bottom).offset(20)
                }
                make.leading.equalToSuperview().offset(20)
            }
            
            // 제약조건 업데이트 적용
            self.view.layoutIfNeeded()
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
        // 컬렉션뷰 설정
        recentBooksCollectionView.delegate = self
        recentBooksCollectionView.dataSource = self
        recentBooksCollectionView.register(RecentBookCell.self, forCellWithReuseIdentifier: RecentBookCell.identifier)
        
        // 메인 컴포넌트들을 뷰에 추가
        [searchBar, filterLabel, recentBooksCollectionView, resultLabel, bookListTableView].forEach {
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
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        
        // 필터 레이블 제약조건
        filterLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        // 컬렉션뷰 제약조건
        recentBooksCollectionView.snp.makeConstraints { make in
            make.top.equalTo(filterLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(140)  // 책 이미지 높이
        }
        
        // 결과 레이블 제약조건
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(recentBooksCollectionView.snp.bottom).offset(20)
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

// 커스텀 컬렉션뷰 셀 추가
class RecentBookCell: UICollectionViewCell {
    static let identifier = "RecentBookCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .systemGray6
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }.resume()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1  // 검색 결과 섹션만 표시
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.books.count  // 검색 결과만 표시
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "검색 결과"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookSearchCell", for: indexPath) as! BookSearchCell
        let book = viewModel.books[indexPath.row]
        cell.configure(title: book.title, price: "\(book.price)원")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let book = viewModel.books[indexPath.row]
        // 검색결과에서 책을 터치했을 때 최근 본 책에 추가하고 컬렉션뷰를 갱신
        CoreDataManager.shared.saveRecentBook(book)
        viewModel.loadRecentBooks() // 최근 본 책 목록 다시 로드
        
        let detailVC = BookDetailViewController()
        detailVC.viewModel = BookDetailViewModel(book: book)
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.bounds.height
        
        if position > contentHeight - screenHeight - 100 {
            viewModel.loadNextPageIfNeeded()
        }
    }
}
extension BookSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.recentBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentBookCell.identifier, for: indexPath) as! RecentBookCell
        let book = viewModel.recentBooks[indexPath.row]
        cell.configure(with: book.thumbnail)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = viewModel.recentBooks[indexPath.row]
        let detailVC = BookDetailViewController()
        detailVC.viewModel = BookDetailViewModel(book: book)
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
    // MARK: - Properties
    /// 책 상세 정보를 처리하는 뷰모델
    var viewModel: BookDetailViewModel!
    
    /// 북마크 상태를 저장할 프로퍼티
    var isBookmarked: Bool = false
    
    // MARK: - UI Components
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
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    /// 책 가격 레이블
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()
    
    /// 책 설명 레이블
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    /// 북마크 추가/삭제 버튼
    private let actionButton: UIButton = {
        let button = UIButton()
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
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupActions()
        updateUI()
        setupActionButton()
    }
    
    // MARK: - Setup Methods
    /// 버튼 상태 설정
    private func setupActionButton() {
        if !isBookmarked {  // 북마크되지 않은 경우(검색 탭)에만 담기 버튼 설정
            actionButton.setTitle("담기", for: .normal)
            actionButton.backgroundColor = .systemGreen
        }
    }
    
    /// UI 구성 메서드
    private func configureUI() {
        view.backgroundColor = .white
        
        // isBookmarked가 true일 때는 actionButton을 추가하지 않음
        let components = isBookmarked ?
            [bookImageView, titleLabel, priceLabel, descriptionLabel, closeButton] :
            [bookImageView, titleLabel, priceLabel, descriptionLabel, actionButton, closeButton]
        
        components.forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    /// UI 컴포넌트들의 제약조건 설정
    private func setupConstraints() {
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
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-20)  // 하단 여백 추가
        }
        
        // actionButton의 제약조건은 버튼이 있을 때만 설정
        if !isBookmarked {
            actionButton.snp.makeConstraints { make in
                make.top.greaterThanOrEqualTo(descriptionLabel.snp.bottom).offset(20)
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
                make.leading.trailing.equalToSuperview().inset(20)
                make.height.equalTo(50)
            }
        }
    }
    
    /// 버튼 액션 설정
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    /// UI 업데이트 메서드
    private func updateUI() {
        titleLabel.text = viewModel.title
        priceLabel.text = viewModel.priceText
        descriptionLabel.text = viewModel.description
        
        viewModel.loadImage { [weak self] image in
            self?.bookImageView.image = image
        }
    }
    
    // MARK: - Action Methods
    /// 닫기 버튼 액션 메서드
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    /// 액션 버튼 탭 처리
    @objc private func actionButtonTapped() {
        if isBookmarked {
            // 삭제 로직
            viewModel.deleteBook()
            let alert = UIAlertController(title: "완료", message: "책이 삭제되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .cancel) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        } else {
            // 담기 로직
            viewModel.saveBook()
            let alert = UIAlertController(title: "성공", message: "책이 저장되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        }
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
    
    /// 전체 삭제 버튼
    private let deleteAllButton: UIButton = {
        let button = UIButton()
        button.setTitle("전체삭제", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
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
        setupActions()
    }
    
    // MARK: - UI Configuration
    /// UI 구성 메서드
    private func configureUI() {
        view.backgroundColor = .white
        
        [titleLabel, deleteAllButton, bookmarkTableView].forEach {
            view.addSubview($0)
        }
        
        // UI 컴포넌트들의 제약조건 설정
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.equalToSuperview().offset(20)
        }
        
        // 전체삭제 버튼 제약조건 추가
        deleteAllButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
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
    
    // 액션 설정 메서드 추가
    private func setupActions() {
        deleteAllButton.addTarget(self, action: #selector(deleteAllButtonTapped), for: .touchUpInside)
    }
    
    // 전체 삭제 버튼 액션
    @objc private func deleteAllButtonTapped() {
        // 저장된 책이 없을 경우 얼럿 표시
        guard viewModel.bookmarkCount > 0 else {
            let alert = UIAlertController(title: "알림", message: "저장된 책이 없습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        // 삭제 확인 얼럿
        let alert = UIAlertController(title: "전체 삭제",
                                    message: "저장된 모든 책을 삭제하시겠습니까?",
                                    preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteAllBookmarks()
            self?.bookmarkTableView.reloadData()
            
            // 삭제 완료 얼럿
            let completionAlert = UIAlertController(title: "완료",
                                                  message: "모든 책이 삭제되었습니다.",
                                                  preferredStyle: .alert)
            completionAlert.addAction(UIAlertAction(title: "확인", style: .default))
            self?.present(completionAlert, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
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
        detailVC.isBookmarked = true  // 저장된 책 탭에서 열린 상세화면임을 표시
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
    
    /// 스와이프 삭제 기능
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] (action, view, completion) in
            guard let self = self else { return }
            
            let bookmarks = self.viewModel.getBookmarks()
            let bookToDelete = bookmarks[indexPath.row]
            
            let alert = UIAlertController(title: "완료",
                                        message: "책이 삭제되었습니다.",
                                        preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.viewModel.removeBookmark(isbn: bookToDelete.isbn)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            alert.addAction(confirmAction)
            self.present(alert, animated: true)
            completion(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
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
