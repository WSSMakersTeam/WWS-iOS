//
//  FeedEditViewModel.swift
//  WSSiOS
//
//  Created by Hyowon Jeon on 6/29/24.
//

import UIKit

import RxSwift
import RxCocoa

enum FeedDetailWomanKoreanGenreDummy: String, CaseIterable {
    case 판타지 = "판타지"
    case 현판 = "현판"
    case 로맨스 = "로맨스"
    case 로판 = "로판"
    case 무협 = "무협"
    case 드라마 = "드라마"
    case 미스터리 = "미스터리"
    case 라노벨 = "라노벨"
    case BL = "BL"
    case 기타 = "기타"
    
    var toEnglish: String {
        switch self {
        case .판타지:
            return "fantasy"
        case .현판:
            return "modernFantasy"
        case .로맨스:
            return "romance"
        case .로판:
            return "romanceFantasy"
        case .무협:
            return "wuxia"
        case .드라마:
            return "drama"
        case .미스터리:
            return "mystery"
        case .라노벨:
            return "lightNovel"
        case .BL:
            return "BL"
        case .기타:
            return "etc"
        }
    }
}

final class FeedEditViewModel: ViewModelType {
    
    //MARK: - Properties
        
    private let memoRepository: MemoRepository
    
    private var isValidFeedContent: Bool = false
    private let feedId: Int?
    let initialFeedContent: String?
    private var novelId: Int?
    var relevantCategories: [String] = []
    private var updatedFeedContent: String = ""
    private let feedContentPredicate = NSPredicate(format: "SELF MATCHES %@", "^[\\s]+$")
    private let maximumFeedContentCount: Int = 2000
    
    //TODO: - 성별에 따른 리스트는 추후 구현
    let relevantCategoryList = FeedDetailWomanKoreanGenreDummy.allCases.map { $0.rawValue }
    
    // Output
    private let endEditing = PublishRelay<Bool>()
    private let categoryListData = PublishRelay<[String]>()
    private let popViewController = PublishRelay<Void>()
    private let isSpoiler = BehaviorRelay<Bool>(value: false)
    private let feedContentWithLengthLimit = BehaviorRelay<String>(value: "")
    private let completeButtonIsAbled = BehaviorRelay<Bool>(value: false)
    private let showPlaceholder = PublishRelay<Bool>()
    private let presentFeedEditNovelConnectModalViewController = PublishRelay<Void>()
    private let connectedNovelTitle = PublishRelay<String?>()
    private let showAlreadyConnectedToast = PublishRelay<Void>()
    private let showStopEditingAlert = PublishRelay<Void>()
       
    //MARK: - Life Cycle
    
    init(memoRepository: MemoRepository, feedId: Int? = nil, relevantCategories: [String] = [], initialFeedContent: String? = nil, novelId: Int? = nil, isSpoiler: Bool = false) {
        self.memoRepository = memoRepository
        self.feedId = feedId
        self.relevantCategories = relevantCategories
        self.initialFeedContent = initialFeedContent
        self.novelId = novelId
        self.isSpoiler.accept(isSpoiler)
    }
    
    struct Input {
        let viewWillAppearEvent: Observable<Void>
        let viewDidTap: Observable<UITapGestureRecognizer>
        let backButtonDidTap: ControlEvent<Void>
        let completeButtonDidTap: ControlEvent<Void>
        let spoilerButtonDidTap: ControlEvent<Void>
        let categoryCollectionViewItemSelected: Observable<IndexPath>
        let categoryCollectionViewItemDeselected: Observable<IndexPath>
        let feedContentUpdated: Observable<String>
        let feedContentViewDidBeginEditing: ControlEvent<Void>
        let feedContentViewDidEndEditing: ControlEvent<Void>
        let novelConnectViewDidTap: Observable<UITapGestureRecognizer>
        let feedNovelConnectedNotification: Observable<Notification>
        let novelRemoveButtonDidTap: ControlEvent<Void>
        let stopEditButtonDidTap: Observable<Void>
    }
    
    struct Output {
        let endEditing: Observable<Bool>
        let categoryListData: Observable<[String]>
        let popViewController: Observable<Void>
        let isSpoiler: Observable<Bool>
        let feedContentWithLengthLimit: Observable<String>
        let completeButtonIsAbled: Observable<Bool>
        let showPlaceholder: Observable<Bool>
        let presentFeedEditNovelConnectModalViewController: Observable<Void>
        let connectedNovelTitle: Observable<String?>
        let showAlreadyConnectedToast: Observable<Void>
        let showStopEditingAlert: Observable<Void>
    }
    
    func transform(from input: Input, disposeBag: DisposeBag) -> Output {
        input.viewDidTap
            .subscribe(with: self, onNext: { owner, _ in
                owner.endEditing.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.viewWillAppearEvent
            .subscribe(with: self, onNext: { owner, _ in
                owner.categoryListData.accept(owner.relevantCategoryList)
            })
            .disposed(by: disposeBag)
        
        input.backButtonDidTap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                owner.showStopEditingAlert.accept(())
            })
            .disposed(by: disposeBag)
        
        if let feedId {
            input.completeButtonDidTap
                .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
                .withLatestFrom(isSpoiler)
                .flatMapLatest { isSpoiler in
                    self.putFeed(feedId: feedId, relevantCategories: self.relevantCategories, feedContent: self.updatedFeedContent, novelId: self.novelId, isSpoiler: isSpoiler)
                }
                .subscribe(with: self, onNext: { owner, _ in
                    owner.popViewController.accept(())
                }, onError: { owner, error  in
                    print(error)
                })
                .disposed(by: disposeBag)
        } else {
            input.completeButtonDidTap
                .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
                .withLatestFrom(isSpoiler)
                .flatMapLatest { isSpoiler in
                    self.postFeed(relevantCategories: self.relevantCategories, feedContent: self.updatedFeedContent, novelId: self.novelId, isSpoiler: isSpoiler)
                }
                .subscribe(with: self, onNext: { owner, _ in
                    owner.popViewController.accept(())
                }, onError: { owner, error  in
                    print(error)
                })
                .disposed(by: disposeBag)
        }
        
        input.spoilerButtonDidTap
            .withLatestFrom(isSpoiler)
            .subscribe(with: self, onNext: { owner, isSpoiler in
                owner.isSpoiler.accept(!isSpoiler)
            })
            .disposed(by: disposeBag)
        
        input.categoryCollectionViewItemSelected
            .subscribe(with: self, onNext: { owner, indexPath in
                let selectedCategory = owner.relevantCategoryList[indexPath.item]
                if let englishCategory = FeedDetailWomanKoreanGenreDummy(rawValue: selectedCategory)?.toEnglish {
                    owner.relevantCategories.append(englishCategory)
                }
                owner.completeButtonIsAbled.accept(owner.isValidFeedContent && !owner.relevantCategories.isEmpty)
            })
            .disposed(by: disposeBag)
        
        input.categoryCollectionViewItemDeselected
            .subscribe(with: self, onNext: { owner, indexPath in
                let deselectedCategory = owner.relevantCategoryList[indexPath.item]
                if let englishCategory = FeedDetailWomanKoreanGenreDummy(rawValue: deselectedCategory)?.toEnglish {
                    owner.relevantCategories.removeAll { $0 == englishCategory }
                }
                owner.completeButtonIsAbled.accept(owner.isValidFeedContent && !owner.relevantCategories.isEmpty)
            })
            .disposed(by: disposeBag)
        
        input.feedContentUpdated
            .subscribe(with: self, onNext: { owner, text in
                owner.updatedFeedContent = text
                owner.feedContentWithLengthLimit.accept(String(text.prefix(owner.maximumFeedContentCount)))
                
                let isEmpty = text.count == 0
                let isOverLimit = text.count > owner.maximumFeedContentCount
                let isWrongFormat = owner.feedContentPredicate.evaluate(with: text)
                let isNotChanged = text == owner.initialFeedContent
                
                owner.isValidFeedContent = !(isEmpty || isOverLimit || isWrongFormat || isNotChanged)
                
                owner.showPlaceholder.accept(isEmpty)
                owner.completeButtonIsAbled.accept(owner.isValidFeedContent && !owner.relevantCategories.isEmpty)
            })
            .disposed(by: disposeBag)
        
        input.feedContentViewDidBeginEditing
            .subscribe(with: self, onNext: { owner, _ in
                owner.showPlaceholder.accept(false)
            })
            .disposed(by: disposeBag)
        
        input.feedContentViewDidEndEditing
            .subscribe(with: self, onNext: { owner, _ in
                owner.showPlaceholder.accept(owner.updatedFeedContent.count == 0 ? true : false)
            })
            .disposed(by: disposeBag)
        
        input.novelConnectViewDidTap
            .subscribe(with: self, onNext: { owner, _ in
                if owner.novelId != nil {
                    owner.showAlreadyConnectedToast.accept(())
                } else {
                    owner.presentFeedEditNovelConnectModalViewController.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        input.feedNovelConnectedNotification
            .subscribe(with: self, onNext: { owner, notification in
                guard let connectedNovel = notification.object as? NormalSearchNovel else { return }
                owner.novelId = connectedNovel.novelId
                owner.connectedNovelTitle.accept(connectedNovel.novelTitle)
            })
            .disposed(by: disposeBag)
        
        input.novelRemoveButtonDidTap
            .subscribe(with: self, onNext: { owner, _ in
                owner.novelId = nil
                owner.connectedNovelTitle.accept(nil)
            })
            .disposed(by: disposeBag)
        
        input.stopEditButtonDidTap
            .subscribe(with: self, onNext: { owner, _ in
                owner.popViewController.accept(())
            })
            .disposed(by: disposeBag)
        
        return Output(endEditing: endEditing.asObservable(),
                      categoryListData: categoryListData.asObservable(),
                      popViewController: popViewController.asObservable(),
                      isSpoiler: isSpoiler.asObservable(),
                      feedContentWithLengthLimit: feedContentWithLengthLimit.asObservable(),
                      completeButtonIsAbled: completeButtonIsAbled.asObservable(),
                      showPlaceholder: showPlaceholder.asObservable(),
                      presentFeedEditNovelConnectModalViewController: presentFeedEditNovelConnectModalViewController.asObservable(),
                      connectedNovelTitle: connectedNovelTitle.asObservable(),
                      showAlreadyConnectedToast: showAlreadyConnectedToast.asObservable(),
                      showStopEditingAlert: showStopEditingAlert.asObservable())
    }
    
    //MARK: - API
    
    private func postFeed(relevantCategories: [String], feedContent: String, novelId: Int?, isSpoiler: Bool) -> Observable<Void> {
        memoRepository.postFeed(relevantCategories: relevantCategories, feedContent: feedContent, novelId: novelId, isSpoiler: isSpoiler)
            .observe(on: MainScheduler.instance)
    }
    
    private func putFeed(feedId: Int, relevantCategories: [String], feedContent: String, novelId: Int?, isSpoiler: Bool) -> Observable<Void> {
        memoRepository.putFeed(feedId: feedId, relevantCategories: relevantCategories, feedContent: feedContent, novelId: novelId, isSpoiler: isSpoiler)
            .observe(on: MainScheduler.instance)
    }
}
