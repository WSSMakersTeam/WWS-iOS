//
//  FeedGenreViewController.swift
//  WSSiOS
//
//  Created by 신지원 on 5/19/24.
//

import UIKit

import RxSwift
import RxRelay

class FeedGenreViewController: UIViewController, UIScrollViewDelegate {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let loadMoreTrigger = PublishSubject<Void>()
    private let feedData = BehaviorRelay<[TotalFeeds]>(value: [])
    
    private let novelDetailFeedProfileViewDidTap = PublishRelay<Int>()
    private let novelDetailFeedDropdownButtonDidTap = PublishRelay<(Int, Bool)>()
    private let novelDetailFeedConnectedNovelViewDidTap = PublishRelay<Int>()
    private let novelDetailFeedLikeViewDidTap = PublishRelay<(Int, Bool)>()
    
    //MARK: - Components
    
    private var rootView = FeedGenreView()
    private var viewModel: FeedGenreViewModel
    
    // MARK: - Life Cycle
    
    init(viewModel: FeedGenreViewModel) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        register()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        showTabBar()
    }
    
    //MARK: - Bind
    
    private func register() {
        rootView.feedTableView.register(NovelDetailFeedTableViewCell.self,
                                        forCellReuseIdentifier: NovelDetailFeedTableViewCell.cellIdentifier)
    }
    
    private func bindViewModel() {
        
        let profileTapped = PublishSubject<Int>()
        let contentTapped = PublishSubject<Int>()
        let novelTapped = PublishSubject<Int>()
        let likedTapped = PublishSubject<Bool>()
        let commentTapped = PublishSubject<Int>()
        
        let input = FeedGenreViewModel.Input(
            loadMoreTrigger: loadMoreTrigger,
            feedTableViewItemSelected: rootView.feedTableView.rx.itemSelected.asObservable(),
            feedProfileViewDidTap: novelDetailFeedProfileViewDidTap.asObservable()
        )
        let output = viewModel.transform(from: input, disposeBag: disposeBag)
        
        output.feedList
            .bind(to: feedData)
            .disposed(by: disposeBag)
        
        feedData
            .bind(to: rootView.feedTableView.rx.items(
                cellIdentifier: NovelDetailFeedTableViewCell.cellIdentifier,
                cellType: NovelDetailFeedTableViewCell.self)) { _, element, cell in
                    cell.bindData(feed: element)
                    cell.delegate = self
                }
                .disposed(by: disposeBag)
        
        output.pushToFeedDetailViewController
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, feedId in
                owner.pushToFeedDetailViewController(feedId: feedId)
            })
            .disposed(by: disposeBag)
        
        output.pushToUserViewController
            .subscribe(with: self, onNext: { owner, userId in
                owner.pushToMyPageViewController(isMyPage: false)
            })
            .disposed(by: disposeBag)
    }
}

extension FeedGenreViewController: FeedTableViewDelegate {
    func profileViewDidTap(userId: Int) {
        self.novelDetailFeedProfileViewDidTap.accept(userId)
    }
    
    func dropdownButtonDidTap(feedId: Int, isMyFeed: Bool) {
        self.novelDetailFeedDropdownButtonDidTap.accept((feedId, isMyFeed))
    }
    
    func connectedNovelViewDidTap(novelId: Int) {
        self.novelDetailFeedConnectedNovelViewDidTap.accept(novelId)
    }
    
    func likeViewDidTap(feedId: Int, isLiked: Bool) {
        self.novelDetailFeedLikeViewDidTap.accept((feedId, isLiked))
    }
}
