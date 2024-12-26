//
//  ViewController.swift
//  BookDataApp
//
//  Created by 유태호 on 12/26/24.
//

import UIKit
import SnapKit

// MARK: - ViewController (TabBarController)
class ViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        // 첫 번째 탭 - 검색 화면
        let searchVC = BookSearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "magnifyingglass.fill")
        )
        
        // 두 번째 탭 - 북마크 화면
        let bookmarkVC = BookmarkViewController()
        let bookmarkNav = UINavigationController(rootViewController: bookmarkVC)
        bookmarkNav.tabBarItem = UITabBarItem(
            title: "저장된 책",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )
        
        // 탭바 컨트롤러 설정
        self.viewControllers = [searchNav, bookmarkNav]
        self.tabBar.tintColor = .systemBlue
        self.tabBar.backgroundColor = .white
    }
}

// MARK: - BookSearchViewController
class BookSearchViewController: UIViewController {
    
    // MARK: - Properties
    /// 검색바
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "검색할 책 제목을 입력해주세요"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.layer.cornerRadius = 8
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.systemGray5.cgColor
        return searchBar
    }()
    
    /// 필터 섹션 레이블
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 본 책"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    /// 컬러 필터 컨테이너 뷰
    private let filterContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 컬러 필터 뷰들
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
    
    /// 검색 결과 테이블뷰
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
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        setupBackground()
        setupComponents()
        setupConstraints()
    }
    
    private func setupBackground() {
        view.backgroundColor = .white
    }
    
    private func setupComponents() {
        // 컬러 필터 설정
        [redFilterView, orangeFilterView, yellowFilterView, greenFilterView].forEach {
            $0.layer.cornerRadius = 15
            filterContainerView.addSubview($0)
        }
        redFilterView.backgroundColor = .red
        orangeFilterView.backgroundColor = .orange
        yellowFilterView.backgroundColor = .yellow
        greenFilterView.backgroundColor = .green
        
        // 뷰에 컴포넌트 추가
        [searchBar, filterLabel, filterContainerView, resultLabel, bookListTableView].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupTableView() {
        bookListTableView.delegate = self
        bookListTableView.dataSource = self
        bookListTableView.register(BookSearchCell.self, forCellReuseIdentifier: "BookSearchCell")
    }
    
    private func setupConstraints() {
        // 검색바 제약조건
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
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
        
        // 컬러 필터 제약조건
        let filterSize = 30
        let spacing = 10
        
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
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)  // bottomButtonStackView.snp.top 대신 view.safeAreaLayoutGuide 사용
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension BookSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookSearchCell", for: indexPath) as! BookSearchCell
        cell.configure(title: "세이노의 가르침", price: "14,000원")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = BookDetailViewController()
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
}

// MARK: - BookSearchCell
class BookSearchCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func configure(title: String, price: String) {
        titleLabel.text = title
        priceLabel.text = price
    }
}

// MARK: - BookDetailViewController
class BookDetailViewController: UIViewController {
    
    // MARK: - Properties
    private let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "세이노의 가르침"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "14,000원"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("담기", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupActions()
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        view.backgroundColor = .white
        
        [bookImageView, titleLabel, priceLabel, addButton, closeButton].forEach {
            view.addSubview($0)
        }
        
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
        
        addButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func addTapped() {
        // 책 저장 로직 구현
        let alert = UIAlertController(title: "성공", message: "책이 저장되었습니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            self.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - BookmarkViewController
class BookmarkViewController: UIViewController {
    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "담은 책"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
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
    private func configureUI() {
        view.backgroundColor = .white
        
        [titleLabel, bookmarkTableView].forEach {
            view.addSubview($0)
        }
        
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
    
    private func setupTableView() {
        bookmarkTableView.delegate = self
        bookmarkTableView.dataSource = self
        bookmarkTableView.register(BookSearchCell.self, forCellReuseIdentifier: "BookSearchCell")
    }
}

// MARK: - BookmarkViewController Extension
extension BookmarkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // 저장된 책 수에 따라 변경
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookSearchCell", for: indexPath) as! BookSearchCell
        cell.configure(title: "세이노의 가르침", price: "14,000원")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detailVC = BookDetailViewController()
        detailVC.modalPresentationStyle = .pageSheet
        present(detailVC, animated: true)
    }
}

// MARK: - SwiftUI Preview
#Preview {
    ViewController()
}
