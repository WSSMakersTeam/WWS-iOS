//
//  LibraryPageViewController.swift
//  WSSiOS
//
//  Created by 신지원 on 1/14/24.
//

import UIKit

import RxSwift
import RxCocoa

final class LibraryViewController: UIViewController {
    
    //MARK: - Properties
    
    private let libraryViewModel: LibraryViewModel
    
    private let disposeBag = DisposeBag()
    private let sortTypeList = StringLiterals.Alignment.self
    
    private let readStatusList = StringLiterals.ReadStatus.allCases.map { $0.rawValue }
    private var currentPageIndex = 0
    
    let libraryPageBar = LibraryPageBar()
    let libraryDescriptionView = LibraryDescriptionView()
    let libraryListView = LibraryListView()
    var libraryPages = [LibraryChildViewController]()
    
    let backButton = UIButton()
    
    //MARK: - UI Components

    private let libraryPageViewController = UIPageViewController(transitionStyle: .scroll,
                                                                 navigationOrientation: .horizontal,
                                                                 options: nil)
    
    
    // MARK: - Life Cycle
    
    init(libraryViewModel: LibraryViewModel) {
        self.libraryViewModel = libraryViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupPages()
        
        setUI()
        setHierarchy()
        setLayout()
        
        delegate()
        register()
        bindViewModel()
        
        addNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showTabBar()
        preparationSetNavigationBar(title: StringLiterals.Navigation.Title.library,
                                    left: backButton,
                                    right: nil)
    }
    
    //MARK: - Bind
    
    private func register() {
        libraryPageBar.libraryTabCollectionView
            .register(LibraryTabCollectionViewCell.self,
                      forCellWithReuseIdentifier: "LibraryTabCollectionViewCell")
    }
    
    private func delegate() {
        libraryPageViewController.delegate = self
        libraryPageViewController.dataSource = self
    }
    
    private func bindViewModel() {
        let input = LibraryViewModel.Input(
            tabBarDidTap:libraryPageBar.libraryTabCollectionView.rx.itemSelected,
            listButtonDidTap: libraryDescriptionView.libraryNovelListButton.rx.tap,
            newestButtonDidTap: libraryListView.libraryNewestButton.rx.tap,
            oldestButtonDidTap: libraryListView.libraryOldestButton.rx.tap,
            backButtonDidTap: backButton.rx.tap
        )
        
        let output = libraryViewModel.transform(from: input, disposeBag: disposeBag)
        
        output.bindCell
            .bind(to: libraryPageBar.libraryTabCollectionView.rx.items(
                cellIdentifier: LibraryTabCollectionViewCell.cellIdentifier,
                cellType: LibraryTabCollectionViewCell.self)) { (row, element, cell) in
                    cell.bindData(data: element)
                }
                .disposed(by: disposeBag)
        
        output.moveToTappedTabBar
            .subscribe(with: self, onNext: { owner, index in
                let direction: UIPageViewController.NavigationDirection = index > (owner.libraryPageViewController.viewControllers?.first?.view.tag ?? 0) ? .forward : .reverse
                owner.libraryPageViewController.setViewControllers([owner.libraryPages[index]],
                                                                   direction: direction,
                                                                   animated: true,
                                                                   completion: nil)
            })
            .disposed(by: disposeBag)
        
        output.showListView
            .bind(with: self, onNext: { owner, isShown in
                owner.libraryListView.isHidden = isShown
            })
            .disposed(by: disposeBag)
        
        output.changeListType
            .bind(with: self, onNext: { owner, listType in
                owner.resetUI(title: listType.title)
            })
            .disposed(by: disposeBag)
        
        output.updateChildViewController
            .bind(with: self, onNext: { owner, sortType in
                guard owner.currentPageIndex >= 0 && owner.currentPageIndex < owner.libraryPages.count else { return }
                let viewController = owner.libraryPages[owner.currentPageIndex]
                let sortTypeQuery = ShowNovelStatus(readStatus: owner.readStatusList[owner.currentPageIndex],
                                                    lastUserNovelId: sortType.lastId,
                                                    size: sortType.sizeData,
                                                    sortType: sortType.sortType)
                viewController.updateNovelListRelay.accept(sortTypeQuery)
            })
            .disposed(by: disposeBag)
        
        output.popLastViewController
            .bind(with: self, onNext: { owner, _ in
                owner.popToLastViewController()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupPages() {
        self.addChild(libraryPageViewController)
        self.view.addSubviews(libraryPageViewController.view)
        libraryPageViewController.didMove(toParent: self)
        
        for i in 0..<readStatusList.count {
            let sortTypeList = sortTypeList.newest
            let sortTypeQuery = ShowNovelStatus(readStatus: readStatusList[i],
                                                lastUserNovelId: sortTypeList.lastId,
                                                size: sortTypeList.sizeData,
                                                sortType: sortTypeList.sortType)
            let viewController = libraryChildViewController(data: sortTypeQuery)
            
            viewController.delegate = self
            libraryPages.append(viewController)
        }
        
        for (index, viewController) in libraryPages.enumerated() {
            viewController.view.tag = index
        }
        
        libraryPageViewController.setViewControllers([libraryPages[0]],
                                                     direction: .forward,
                                                     animated: false,
                                                     completion: nil)
    }
}

//MARK: - Set PageController

extension LibraryViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) { 
        if completed, let currentViewController = pageViewController.viewControllers?.first, let index = libraryPages.firstIndex(of: currentViewController as! LibraryChildViewController) {
            libraryPageBar.libraryTabCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            currentPageIndex = index
        }
    }
}

extension LibraryViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentIndex = libraryPages.firstIndex(of: viewController as! LibraryChildViewController), currentIndex > 0 {
            return libraryPages[currentIndex - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentIndex = libraryPages.firstIndex(of: viewController as! LibraryChildViewController), currentIndex < libraryPages.count - 1 {
            return libraryPages[currentIndex + 1]
        }
        return nil
    }
}

extension LibraryViewController: NovelDelegate {
    func sendData(data: Int) {
        libraryDescriptionView.libraryNovelCountLabel.text = "\(data)개"
    }
}

extension LibraryViewController {
    
    //MARK: - Notification
    
    private func addNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.showNovelInfo(_:)),
            name: NSNotification.Name("ShowNovelInfo"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.showNovelMemo(_:)),
            name: NSNotification.Name("ShowNovelMemo"),
            object: nil
        )
    }
    
    @objc
    func showNovelInfo(_ notification: Notification) {
        
        guard let userNovelId = notification.object as? Int else { return }
        self.moveToNovelDetailViewController(userNovelId: userNovelId)
    }
    
    @objc
    func showNovelMemo(_ notification: Notification) {
        guard let userNovelId = notification.object as? Int else { return }
        self.moveToNovelDetailViewController(userNovelId: userNovelId)
    }
    
    private func libraryChildViewController(data: ShowNovelStatus) -> LibraryChildViewController {
        return LibraryChildViewController(
            libraryViewModel: LibraryChildViewModel(
                userNovelListRepository: DefaultUserNovelRepository(
                    userNovelService: DefaultUserNovelService()),
                initData: data))
    }
}

extension LibraryViewController {
    
    //MARK: - UI
    
    private func setUI() {
        self.view.backgroundColor = .White
        
        libraryListView.isHidden = true
        
        backButton.do {
            $0.setImage(.icNavigateLeft.withRenderingMode(.alwaysOriginal).withTintColor(.wssGray300), for: .normal)
        }
    }
    
    private func setHierarchy() {
        self.view.addSubviews(libraryPageBar,
                              libraryDescriptionView)
        self.addChild(libraryPageViewController)
        self.view.addSubviews(libraryPageViewController.view)
        libraryPageViewController.didMove(toParent: self)
        self.view.addSubview(libraryListView)
    }
    
    private func setLayout() {
        libraryPageBar.snp.makeConstraints() {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.width.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        libraryDescriptionView.snp.makeConstraints() {
            $0.top.equalTo(libraryPageBar.snp.bottom)
            $0.width.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        libraryPageViewController.view.snp.makeConstraints {
            $0.top.equalTo(libraryDescriptionView.snp.bottom)
            $0.width.bottom.equalToSuperview()
        }
        
        libraryListView.snp.makeConstraints() {
            $0.top.equalTo(libraryDescriptionView.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(25)
            $0.width.equalTo(100)
            $0.height.equalTo(104)
        }
    }
    
    private func resetUI(title: String) {
        self.libraryDescriptionView.libraryNovelListButton.do {
            let title = title
            var attString = AttributedString(title)
            attString.font = UIFont.Label1
            attString.foregroundColor = UIColor.Gray300
            
            var configuration = UIButton.Configuration.filled()
            configuration.attributedTitle = attString
            configuration.image = UIImage.icDropDown
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
            configuration.imagePlacement = .trailing
            configuration.baseBackgroundColor = UIColor.clear
            $0.configuration = configuration
        }
    }
}

