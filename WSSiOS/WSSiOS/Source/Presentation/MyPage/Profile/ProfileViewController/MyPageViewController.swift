//
//  MyPageViewController.swift
//  WSSiOS
//
//  Created by 신지원 on 7/9/24.
//

import UIKit

import RxSwift
import RxCocoa

enum EntryType {
    case tabBar
    case otherVC
}

final class MyPageViewController: UIViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: MyPageViewModel
    var entryType: EntryType = .otherVC
    
    private let isEntryTabbarRelay = BehaviorRelay<Bool>(value: false)
    private var dropDownCellTap = PublishSubject<String>()
    private let headerViewHeightRelay = BehaviorRelay<Double>(value: 0)
    private let alertButtonRelay = PublishRelay<Bool>()
    
    //MARK: - UI Components
    
    private var rootView = MyPageView()
    
    // MARK: - Life Cycle
    
    init(viewModel: MyPageViewModel) {
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
        
        delegate()
        register()
        
        bindViewModel()
        
        switch entryType {
        case .tabBar:
            print("탭바에서 진입")
            isEntryTabbarRelay.accept(true)
        case .otherVC:
            print("다른 VC에서 진입")
            isEntryTabbarRelay.accept(false)
            hideTabBar()
            swipeBackGesture()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerViewHeightRelay.accept(rootView.headerView.layer.frame.height)
    }
    
    private func register() {
        rootView.myPageLibraryView.novelPrefrerencesView.preferencesCollectionView.register(
            MyPageNovelPreferencesCollectionViewCell.self,
            forCellWithReuseIdentifier: MyPageNovelPreferencesCollectionViewCell.cellIdentifier)
        
        rootView.myPageLibraryView.genrePrefrerencesView.otherGenreView.genreTableView.register(MyPageGenrePreferencesOtherTableViewCell.self, forCellReuseIdentifier: MyPageGenrePreferencesOtherTableViewCell.cellIdentifier)
    }
    
    private func delegate() {
        rootView.myPageLibraryView.novelPrefrerencesView.preferencesCollectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        rootView.myPageLibraryView.genrePrefrerencesView.otherGenreView.genreTableView.delegate = self
    }
    
    //MARK: - Bind
    
    private func bindViewModel() {
        let genrePreferenceButtonDidTap = Observable.merge(
            rootView.myPageLibraryView.genrePrefrerencesView.myPageGenreOpenButton.rx.tap.map { true },
            rootView.myPageLibraryView.genrePrefrerencesView.myPageGenreCloseButton.rx.tap.map { false }
        )
        
        let libraryButtonDidTap = Observable.merge(
            rootView.mainStickyHeaderView.libraryButton.rx.tap.map { true },
            rootView.scrolledStstickyHeaderView.libraryButton.rx.tap.map { true }
        )
        
        let feedButtonDidTap = Observable.merge(
            rootView.mainStickyHeaderView.feedButton.rx.tap.map { true },
            rootView.scrolledStstickyHeaderView.feedButton.rx.tap.map { true }
        )
        
        let input = MyPageViewModel.Input(
            isEntryTabbar: isEntryTabbarRelay.asObservable(),
            headerViewHeight: headerViewHeightRelay.asDriver(),
            scrollOffset: rootView.scrollView.rx.contentOffset.asDriver(),
            settingButtonDidTap: rootView.settingButton.rx.tap,
            dropdownButtonDidTap: dropDownCellTap,
            editButtonDidTap: rootView.headerView.userImageChangeButton.rx.tap,
            backButtonDidTap: rootView.backButton.rx.tap,
            genrePreferenceButtonDidTap: genrePreferenceButtonDidTap,
            libraryButtonDidTap: libraryButtonDidTap,
            feedButtonDidTap: feedButtonDidTap,
            alertButtonDidTap: alertButtonRelay)
        
        let output = viewModel.transform(from: input, disposeBag: disposeBag)
        
        output.isMyPage
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, data in
                let (myPage, title) = data
                owner.decideNavigation(myPage: myPage, title: title)
            })
            .disposed(by: disposeBag)
        
        output.isExistPreference
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, exist in
                owner.rootView.myPageLibraryView.isExist = exist
                owner.rootView.myPageLibraryView.updateLibraryView(isExist: exist)
            })
            .disposed(by: disposeBag)
        
        output.profileData
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, data in
                owner.rootView.headerView.bindData(data: data)
            })
            .disposed(by: disposeBag)
        
        output.updateNavigationEnabled
            .asDriver()
            .drive(with: self, onNext: { owner, update in
                owner.rootView.scrolledStstickyHeaderView.isHidden = !update
                owner.rootView.mainStickyHeaderView.isHidden = update
                owner.rootView.headerView.isHidden = update
                
                if update {
                    owner.navigationItem.title = StringLiterals.Navigation.Title.myPage
                } else {
                    owner.navigationItem.title = ""
                }
            })
            .disposed(by: disposeBag)
        
        output.pushToSettingViewController
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                owner.pushToSettingViewController()
            })
            .disposed(by: disposeBag)
        
        output.pushToEditViewController
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, data in
                owner.pushToMyPageEditViewController(profile: data)
            })
            .disposed(by: disposeBag)
        
        output.popViewController
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, data in
                owner.popToLastViewController()
            })
            .disposed(by: disposeBag)
        
        output.isProfilePrivate
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, data in
                let (isPrivate, nickname) = data
                owner.rootView.myPageLibraryView.isPrivateUserView(isPrivate: isPrivate, nickname: nickname)
                
            })
            .disposed(by: disposeBag)
        
        output.bindGenreData
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] data in
                self?.rootView.myPageLibraryView.genrePrefrerencesView.bindData(data: data)
            })
            .map { Array($0.genrePreferences.dropFirst(3)) }
            .bind(to: rootView.myPageLibraryView.genrePrefrerencesView.otherGenreView.genreTableView.rx.items(cellIdentifier: MyPageGenrePreferencesOtherTableViewCell.cellIdentifier, cellType: MyPageGenrePreferencesOtherTableViewCell.self)) { row, data, cell in
                cell.bindData(data: data)
            }
            .disposed(by: disposeBag)
        
        output.bindattractivePointsData
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, data in
                owner.rootView.myPageLibraryView.novelPrefrerencesView.bindData(data: data)
                
            })
            .disposed(by: disposeBag)
        
        output.bindKeywordCell
            .observe(on: MainScheduler.instance)
            .bind(to: rootView.myPageLibraryView.novelPrefrerencesView.preferencesCollectionView.rx.items(cellIdentifier: MyPageNovelPreferencesCollectionViewCell.cellIdentifier, cellType: MyPageNovelPreferencesCollectionViewCell.self)){ row, data, cell in
                cell.bindData(data: data)
            }
            .disposed(by: disposeBag)
        
        output.bindInventoryData
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, data in
                owner.rootView.myPageLibraryView.inventoryView.bindData(data: data)
            })
            .disposed(by: disposeBag)
        
        output.showGenreOtherView
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, show in
                owner.rootView.myPageLibraryView.genrePrefrerencesView.updateView(showOtherGenreView: show)
                
                UIView.animate(withDuration: 0.3) {
                    owner.rootView.myPageLibraryView.updateGenreViewHeight(isExpanded: show)
                    owner.rootView.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        output.stickyHeaderAction
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, library in
                owner.rootView.mainStickyHeaderView.updateSelection(isLibrarySelected: library)
                owner.rootView.scrolledStstickyHeaderView.updateSelection(isLibrarySelected: library)
                
                owner.rootView.myPageLibraryView.isHidden = !library
                owner.rootView.myPageFeedView.isHidden = library
                
                owner.rootView.contentView.snp.remakeConstraints {
                    $0.edges.equalToSuperview()
                    $0.width.equalToSuperview()
                    
                    if library {
                        $0.bottom.equalTo(owner.rootView.myPageLibraryView.snp.bottom)
                    } else {
                        $0.bottom.equalTo(owner.rootView.myPageFeedView.snp.bottom)
                    }
                }
                
                UIView.animate(withDuration: 0.3) {
                    owner.rootView.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        output.showUnknownUserAlert
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                self.rootView.isUnknownUserProfile()
                self.presentToAlertViewController(iconImage: .icAlertWarningCircle,
                                                  titleText: StringLiterals.MyPage.Profile.unknownUserNickname,
                                                  contentText: StringLiterals.MyPage.Profile.unknownAlertContent,
                                                  leftTitle: StringLiterals.MyPage.Profile.unknownAlertButtonTitle,
                                                  rightTitle: nil,
                                                  rightBackgroundColor: nil)
                .bind(with: self, onNext: { owner, buttonType in
                    if buttonType == .left {
                        owner.alertButtonRelay.accept(true)
                    }
                })
                .disposed(by: owner.disposeBag)
            })
            .disposed(by: disposeBag)
    }
}

extension MyPageViewController: UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UITableViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let keywords = try? viewModel.bindKeywordRelay.value,
              indexPath.row < keywords.count else {
            return CGSize(width: 0, height: 0)
        }
        
        let keyword = keywords[indexPath.row]
        let text = "\(keyword.keywordName) \(keyword.keywordCount)"
        
        
        let width = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.Body2]).width + 24
        return CGSize(width: width, height: 37)
    }
}

extension MyPageViewController {
    
    //MARK: - UI
    
    private func decideNavigation(myPage: Bool, title: String) {
        if myPage {
            preparationSetNavigationBar(title: title,
                                        left: nil,
                                        right: rootView.settingButton)
        } else {
            let dropdownButton = WSSDropdownButton().then {
                $0.makeDropdown(dropdownRootView: self.rootView,
                                dropdownWidth: 120,
                                dropdownLayout: .autoInNavigationBar,
                                dropdownData: [StringLiterals.MyPage.BlockUser.toastText],
                                textColor: .wssBlack)
                .bind(to: dropDownCellTap)
                .disposed(by: disposeBag)
            }
            
            preparationSetNavigationBar(title: title,
                                        left: rootView.backButton,
                                        right: dropdownButton)
        }
        
        rootView.headerView.userImageChangeButton.isHidden = !myPage
    }
}
