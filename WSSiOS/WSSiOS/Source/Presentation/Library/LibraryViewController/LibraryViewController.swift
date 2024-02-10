//
//  LibraryPageViewController.swift
//  WSSiOS
//
//  Created by 신지원 on 1/14/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class LibraryViewController: UIViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let tabBarList = Observable.just(StringLiterals.Library.TabBar.allCases.map { $0.rawValue })
    private let readStatusList = StringLiterals.Library.ReadStatus.allCases.map { $0.rawValue }
    private let sortTypeList = StringLiterals.Library.SortType.allCases.map { $0.rawValue }
    var currentPageIndex = 0
    private var readStatusData: Int = 0
    
    //MARK: - UI Components
    
    private var libraryPageViewController = UIPageViewController(transitionStyle: .scroll,
                                                                 navigationOrientation: .horizontal,
                                                                 options: nil)
    private let libraryPageBar = LibraryPageBar()
    private let libraryDescriptionView = LibraryDescriptionView()
    private let libraryListView = LibraryListView()
    private lazy var libraryPages = [LibraryBaseViewController]()
    private let userNovelListRepository: DefaultUserNovelRepository
    
    init(userNovelListRepository: DefaultUserNovelRepository) {
        self.userNovelListRepository = userNovelListRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showTabBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preparationSetNavigationBar(title: StringLiterals.Navigation.Title.library,
                                    left: nil,
                                    right: nil)
        setupPages()
        setUI()
        setHierarchy()
        delegate()
        register()
        bindCell()
        setLayout()
        setAction()
        addNotificationCenter()
    }
   
    //MARK: - Custom TabBar
    
    private func register() {
        libraryPageBar.libraryTabCollectionView
            .register(LibraryTabCollectionViewCell.self,
                      forCellWithReuseIdentifier: "LibraryTabCollectionViewCell")
    }
    
    private func bindCell() {
        tabBarList.bind(to: libraryPageBar.libraryTabCollectionView.rx.items(
            cellIdentifier: "LibraryTabCollectionViewCell",
            cellType: LibraryTabCollectionViewCell.self)) { (row, element, cell) in
                cell.bindData(data: element)
            }
            .disposed(by: disposeBag)
        
        libraryPageBar.libraryTabCollectionView.rx.itemSelected
            .map { indexPath in
                return indexPath.row
            }
            .bind(to: self.libraryPageBar.selectedTabIndex)
            .disposed(by: disposeBag)
        
        Observable.just(Void())
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in 
                owner.libraryPageBar.libraryTabCollectionView.selectItem(at: IndexPath(item: 0, section: 0),
                                                                         animated: true,
                                                                         scrollPosition: [])
                owner.libraryPageBar.selectedTabIndex.onNext(0)
            })
            .disposed(by: disposeBag)
    }
    
    private func delegate() {
        libraryPageViewController.delegate = self
        libraryPageViewController.dataSource = self
    }
    
    private func setupPages() {
        for i in 0..<readStatusList.count {
            let viewController = LibraryBaseViewController(
                userNovelListRepository: DefaultUserNovelRepository(
                    userNovelService: DefaultUserNovelService()),
                readStatusData: readStatusList[i],
                lastUserNovelIdData: 999999,
                sizeData: 500,
                sortTypeData: sortTypeList[0])
            
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
    
    private func setAction() {
        libraryPageBar.selectedTabIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self, self.libraryPages.indices.contains(index) else { return }
                let direction: UIPageViewController.NavigationDirection = index > (self.libraryPageViewController.viewControllers?.first?.view.tag ?? 0) ? .forward : .reverse
                self.libraryPageViewController.setViewControllers([self.libraryPages[index]],
                                                                  direction: direction,
                                                                  animated: true,
                                                                  completion: nil)
            })
            .disposed(by: disposeBag)
        
        libraryDescriptionView.libraryNovelListButton.rx.tap
            .bind(with: self, onNext: { owner, _ in 
                owner.libraryListView.isHidden.toggle()
            })
            .disposed(by: disposeBag)
        
        libraryListView.libraryNewestButton.rx.tap
            .bind(with: self) { owner , _ in
                owner.updatePages(sort: owner.sortTypeList[0])
                owner.resetUI(title: StringLiterals.Library.newest)
                owner.libraryListView.isHidden.toggle()
            }
            .disposed(by: disposeBag)
        
        libraryListView.libraryOldesttButton.rx.tap
            .bind(with: self) { owner , _ in
                owner.updatePages(sort: owner.sortTypeList[1])
                owner.resetUI(title: StringLiterals.Library.oldest)
                owner.libraryListView.isHidden.toggle()
            }
            .disposed(by: disposeBag)
    }
    
    private func updatePages(sort: String) {
            let viewController = libraryPages[currentPageIndex]
        viewController.reloadView(sortType: sort)
    }
}

//MARK: - set PageController

extension LibraryViewController : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) { 
        if completed, let currentViewController = pageViewController.viewControllers?.first, let index = libraryPages.firstIndex(of: currentViewController as! LibraryBaseViewController) {
            libraryPageBar.libraryTabCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            currentPageIndex = index
        }
    }
}

extension LibraryViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentIndex = libraryPages.firstIndex(of: viewController as! LibraryBaseViewController), currentIndex > 0 {
            return libraryPages[currentIndex - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentIndex = libraryPages.firstIndex(of: viewController as! LibraryBaseViewController), currentIndex < libraryPages.count - 1 {
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
    
    //MARK: - set Design
    
    private func setUI() {
        self.view.backgroundColor = .White
        
        libraryListView.isHidden = true
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
            configuration.image = ImageLiterals.icon.dropDown
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
            configuration.imagePlacement = .trailing
            configuration.baseBackgroundColor = UIColor.clear
            $0.configuration = configuration
        }
    }
    
    //MARK: - notification
    
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
        self.navigationController?.pushViewController(NovelDetailViewController(
            repository: DefaultUserNovelRepository(
                userNovelService: DefaultUserNovelService()
            ),
            userNovelId: userNovelId,
            selectedMenu: 1
        ), animated: true)
    }
    
    @objc
    func showNovelMemo(_ notification: Notification) {
        guard let userNovelId = notification.object as? Int else { return }
        self.navigationController?.pushViewController(NovelDetailViewController(
            repository: DefaultUserNovelRepository(
                userNovelService: DefaultUserNovelService()
            ),
            userNovelId: userNovelId,
            selectedMenu: 0
        ), animated: true)
    }
}


