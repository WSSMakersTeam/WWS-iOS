//
//  FeedGenreViewModel.swift
//  WSSiOS
//
//  Created by 신지원 on 9/28/24.
//

import Foundation

import RxSwift
import RxCocoa

final class FeedGenreViewModel: ViewModelType {
    
    //MARK: - Properties
    
    private let feedRepository: FeedRepository
    private let category: String
    private var lastFeedId: Int = 0
    private var isLoading = false
    
    // output
    
    private let feedList = BehaviorRelay<[TotalFeeds]>(value: [])
    private let pushToFeedDetailViewController = PublishRelay<Int>()

    //MARK: - Life Cycle
    
    init(feedRepository: FeedRepository, category: String) {
        self.feedRepository = feedRepository
        self.category = category
    }
    
    struct Input {
        let loadMoreTrigger: Observable<Void>
        let feedTableViewItemSelected: Observable<IndexPath>
        let feedProfileViewDidTap: Observable<Int>
//        let profileTapped: PublishSubject<Int>
//        let contentTapped: PublishSubject<Int>
//        let novelTapped: PublishSubject<Int>
//        let likedTapped: PublishSubject<Bool>
//        let commentTapped: PublishSubject<Int>
    }
    
    struct Output {
        let feedList: Observable<[TotalFeeds]>
        let pushToFeedDetailViewController: Observable<Int>
        let pushToUserViewController: Observable<Int>
//        let pushToMyPageViewController = PublishRelay<Int>()
//        let dropdownTapped = PublishRelay<Void>()
//        let pushToNovelDetailViewController = PublishRelay<Int>()
//        let likedTapped = PublishRelay<Void>()
//        let pushToFeedDetailViewControllerWithKeyboard = PublishRelay<Int>()
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        getFeedData(category: category, lastFeedId: lastFeedId)
            .subscribe(with: self, onNext: { owner, data in
                owner.lastFeedId = data.feeds.last?.feedId ?? owner.lastFeedId
                owner.feedList.accept(data.feeds)
            }, onError: { owner, error in
                print(error)
            })
            .disposed(by: disposeBag)
        
        input.feedTableViewItemSelected
            .subscribe(with: self, onNext: { owner, indexPath in
                owner.pushToFeedDetailViewController.accept(owner.feedList.value[indexPath.item].feedId)
            })
            .disposed(by: disposeBag)
        
//        input.profileTapped
//            .throttle(.seconds(2), scheduler: MainScheduler.instance)
//            .bind(with: self, onNext: { owner, userId in
//                output.pushToMyPageViewController.accept(userId)
//            })
//            .disposed(by: disposeBag)
//        
//        input.contentTapped
//            .throttle(.seconds(2), scheduler: MainScheduler.instance)
//            .bind(with: self, onNext: { owner, feedId in
//                output.pushToFeedDetailViewController.accept(feedId)
//            })
//            .disposed(by: disposeBag)
//        
//        input.novelTapped
//            .throttle(.seconds(2), scheduler: MainScheduler.instance)
//            .bind(with: self, onNext: { owner, novelId in
//                output.pushToNovelDetailViewController.accept(novelId)
//            })
//            .disposed(by: disposeBag)
//        
//        input.commentTapped
//            .throttle(.seconds(2), scheduler: MainScheduler.instance)
//            .bind(with: self, onNext: { owner, feedId in
//                output.pushToFeedDetailViewController.accept(feedId)
//            })
//            .disposed(by: disposeBag)
//                  
//        
//        input.loadMoreTrigger
//            .filter { [weak self] in self?.isLoading == false }
//            .flatMapLatest { [weak self] _ -> Observable<TotalFeed> in
//                guard let self = self else { return Observable.empty() }
//                self.isLoading = true
//                return self.getFeedData(category: self.category, lastFeedId: self.lastFeedId)
//            }
//            .subscribe(with: self, onNext: { owner, data in
//                owner.isLoading = false
//                owner.lastFeedId = data.feeds.last?.feedId ?? owner.lastFeedId
//                var currentFeeds = output.feedList.value
//                currentFeeds.append(contentsOf: data.feeds)
//                output.feedList.accept(currentFeeds)
//            }, onError: { owner, error in
//                owner.isLoading = false
//                print(error)
//            })
//            .disposed(by: disposeBag)
        
        return Output(
            feedList: feedList.asObservable(),
            pushToFeedDetailViewController: pushToFeedDetailViewController.asObservable(),
            pushToUserViewController: input.feedProfileViewDidTap.asObservable()
        )
    }
    
    //MARK: - API
    
    private func getFeedData(category: String, lastFeedId: Int) -> Observable<TotalFeed> {
        return self.feedRepository.getFeedData(category: category, lastFeedId: lastFeedId)
    }
}

