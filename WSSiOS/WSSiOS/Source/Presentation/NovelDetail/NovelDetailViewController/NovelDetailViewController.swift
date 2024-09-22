//
//  NovelDetailViewController.swift
//  WSSiOS
//
//  Created by 이윤학 on 4/25/24.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

/// Detail View
final class NovelDetailViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: NovelDetailViewModel
    private let disposeBag = DisposeBag()
    
    private let viewWillAppearEvent = BehaviorRelay(value: false)
    
    private var navigationTitle: String = ""
    private let dateFormatter = DateFormatter().then {
        $0.dateFormat = StringLiterals.Register.Normal.DatePicker.dateFormat
        $0.timeZone = TimeZone(identifier: StringLiterals.Register.Normal.DatePicker.KoreaTimeZone)
    }
    
    //MARK: - Components
    
    private let rootView = NovelDetailView()
    
    //MARK: - Life Cycle
    
    init(viewModel: NovelDetailViewModel) {
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
        
        registerCell()
        delegate()
        bindViewModel()
        swipeBackGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewWillAppearEvent.accept(true)
        setNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavigationBarStyle(offset: 0)
    }
    
    //MARK: - UI
    
    private func setNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: rootView.backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rootView.dropDownButton)
    }
    
    //MARK: - Bind
    
    private func registerCell() {
        rootView.infoView.platformView.platformCollectionView.register(
            NovelDetailInfoPlatformCollectionViewCell.self,
            forCellWithReuseIdentifier: NovelDetailInfoPlatformCollectionViewCell.cellIdentifier)
        
        rootView.infoView.reviewView.keywordView.keywordCollectionView.register(
            NovelDetailInfoReviewKeywordCollectionViewCell.self,
            forCellWithReuseIdentifier: NovelDetailInfoReviewKeywordCollectionViewCell.cellIdentifier)
    }
    
    private func delegate() {
        rootView.infoView.reviewView.keywordView.keywordCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let input = createViewModelInput()
        let output = viewModel.transform(from: input,
                                         disposeBag: disposeBag)
        bindViewModelOutput(output)
    }
    
    private func bindViewModelOutput(_ output: NovelDetailViewModel.Output) {
        
        //MARK: - Bind/Total
        
        output.detailHeaderData
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, data in
                owner.rootView.bindHeaderData(data)
                owner.navigationTitle = data.novelTitle
            }, onError: { owner, error in
                print(error)
            })
            .disposed(by: disposeBag)
        
        output.detailInfoData
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, data in
                owner.rootView.bindInfoData(data)
            }, onError: { owner, error in
                print(error)
            })
            .disposed(by: disposeBag)
        
        output.scrollContentOffset
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, offset in
                owner.updateNavigationBarStyle(offset: offset.y)
                
                let stickyoffset = owner.rootView.headerView.frame.size.height - owner.view.safeAreaInsets.top
                let showStickyTabBar = offset.y > stickyoffset
                owner.rootView.updateStickyTabBarShow(showStickyTabBar)
                if offset.y < 0 {
                    owner.rootView.scrollView.rx.contentOffset.onNext(CGPoint(x: 0, y: 0))
                }
            })
            .disposed(by: disposeBag)
        
        output.popToLastViewController
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                owner.popToLastViewController()
            })
            .disposed(by: disposeBag)
        
        //MARK: - Bind/NovelDetailHeader
        
        output.showLargeNovelCoverImage
            .drive(with: self, onNext: { owner, isShow in
                owner.showLargeNovelCoverImageView(isShow)
            })
            .disposed(by: disposeBag)
        
        output.pushToReviewViewController
            .observe(on: MainScheduler.instance)
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind(with: self, onNext: { owner, value in
                // 작품 평가 View로 이동, readStatus버튼으로 이동한 경우,
                // 선택한 readStatus 값은 바로 반영해줌
                print("작품 평가 View로 이동, readStatus: \(String(describing: value))")
            })
            .disposed(by: disposeBag)
        
        output.isUserNovelInterested
            .drive(with: self, onNext: { owner, isInterested in
                owner.rootView.headerView.interestReviewButton.updateInterestButtonState(isInterested)
            })
            .disposed(by: disposeBag)
        
        output.pushTofeedWriteViewController
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                // 수다글 작성 View로 이동
                print("수다글 작성 View로 이동")
            })
            .disposed(by: disposeBag)
        
        //MARK: - Bind/Tab
        
        output.selectedTab
            .drive(with: self, onNext: { owner, tab in
                owner.rootView.updateTab(selected: tab)
            })
            .disposed(by: disposeBag)
        
        //MARK: - Bind/NovelDetailInfo
        
        output.isInfoDescriptionExpended
            .drive(with: self, onNext: { owner, isExpended in
                owner.rootView.infoView.descriptionView.updateAccordionButton(isExpended)
            })
            .disposed(by: disposeBag)
        
        output.platformList
            .drive(rootView.infoView.platformView.platformCollectionView.rx.items(
                cellIdentifier: NovelDetailInfoPlatformCollectionViewCell.cellIdentifier,
                cellType: NovelDetailInfoPlatformCollectionViewCell.self)) { _, element, cell in
                    cell.bindData(data: element)
                }
                .disposed(by: disposeBag)
        
        rootView.infoView.platformView.platformCollectionView.rx.itemSelected
            .withLatestFrom(output.platformList) {(indexPath: $0, platformList: $1)}
            .subscribe(with: self, onNext: { owner, data in
                if let url = URL(string: data.platformList[data.indexPath.item].platformURL) {
                    UIApplication.shared.open(url, options: [:])
                }
            })
            .disposed(by: disposeBag)
        
        output.keywordList
            .drive(rootView.infoView.reviewView.keywordView.keywordCollectionView.rx.items(
                cellIdentifier: NovelDetailInfoReviewKeywordCollectionViewCell.cellIdentifier,
                cellType: NovelDetailInfoReviewKeywordCollectionViewCell.self)) { _, element, cell in
                    cell.bindData(data: element)
                }
                .disposed(by: disposeBag)
        
        output.reviewSectionVisibilities
            .drive(with: self, onNext: { owner, visibilities in
                owner.rootView.infoView.updateVisibility(visibilities)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Actions
    
    private func createViewModelInput() -> NovelDetailViewModel.Input {
        let reviewResultButtonDidTap = Observable<ReadStatus?>.merge(
            rootView.headerView.reviewResultView.readStatusButtons
                .map{ button in
                    button.rx.tap.map { button.readStatus }
                }
            + rootView.headerView.reviewResultView.readInfoButtons
                .map{
                    button in
                    button.rx.tap.map { nil }
                })
        
        return NovelDetailViewModel.Input(
            viewWillAppearEvent: viewWillAppearEvent.asObservable(),
            scrollContentOffset: rootView.scrollView.rx.contentOffset,
            backButtonDidTap: rootView.backButton.rx.tap,
            novelCoverImageButtonDidTap: rootView.headerView.coverImageButton.rx.tap,
            largeNovelCoverImageDismissButtonDidTap: rootView.largeNovelCoverImageButton.dismissButton.rx.tap,
            largeNovelCoverImageBackgroundDidTap: rootView.largeNovelCoverImageButton.rx.tap,
            reviewResultButtonDidTap: reviewResultButtonDidTap,
            interestButtonDidTap: rootView.headerView.interestReviewButton.interestButton.rx.tap,
            feedWriteButtonDidTap: rootView.headerView.interestReviewButton.feedWriteButton.rx.tap,
            infoTabBarButtonDidTap: rootView.tabBarView.infoButton.rx.tap,
            feedTabBarButtonDidTap: rootView.tabBarView.feedButton.rx.tap,
            stickyInfoTabBarButtonDidTap: rootView.stickyTabBarView.infoButton.rx.tap,
            stickyFeedTabBarButtonDidTap: rootView.stickyTabBarView.feedButton.rx.tap,
            descriptionAccordionButtonDidTap: rootView.infoView.descriptionView.accordionButton.rx.tap
        )
    }
    
    //MARK: - Custom Method
    
    private func showLargeNovelCoverImageView(_ isShow: Bool) {
        rootView.largeNovelCoverImageButton.isHidden = !isShow
        self.navigationController?.setNavigationBarHidden(isShow, animated: false)
    }
    
    private func updateNavigationBarStyle(offset: CGFloat) {
        if offset > 0 {
            rootView.statusBarView.backgroundColor = .wssWhite
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.backgroundColor = .wssWhite
            navigationItem.title = navigationTitle
            setNavigationBarTextAttribute()
        } else {
            rootView.statusBarView.backgroundColor = .clear
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil
            navigationController?.navigationBar.backgroundColor = .clear
            navigationItem.title = ""
        }
    }
    
    private func setNavigationBarTextAttribute() {
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.Title2,
            NSAttributedString.Key.foregroundColor: UIColor.wssBlack,
            NSAttributedString.Key.kern: -0.6,
        ]
    }
}

extension NovelDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let text = viewModel.keywordNameForItemAt(indexPath: indexPath) else {
            return CGSize(width: 0, height: 0)
        }
        
        let width = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.Body2]).width + 24
        return CGSize(width: width, height: 37)
    }
}
