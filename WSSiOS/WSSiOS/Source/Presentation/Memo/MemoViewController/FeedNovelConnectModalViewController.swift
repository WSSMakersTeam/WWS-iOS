//
//  FeedNovelConnectModalViewController.swift
//  WSSiOS
//
//  Created by Hyowon Jeon on 8/17/24.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

final class FeedNovelConnectModalViewController: UIViewController {
    
    //MARK: - Properties
    
    private let feedNovelConnectModalViewModel: FeedNovelConnectModalViewModel
    private let disposeBag = DisposeBag()
    
    //MARK: - Components
    
    private let rootView = FeedNovelConnectModalView()
    
    //MARK: - Life Cycle
    
    init(viewModel: FeedNovelConnectModalViewModel) {
        self.feedNovelConnectModalViewModel = viewModel
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - UI
    
    private func register() {
        rootView.feedNovelConnectSearchResultView.searchResultCollectionView.register(FeedNovelConnectCollectionViewCell.self, forCellWithReuseIdentifier: FeedNovelConnectCollectionViewCell.cellIdentifier)
    }
    
    //MARK: - Bind
    
    private func bindViewModel() {
        let input = FeedNovelConnectModalViewModel.Input(
            closeButtonDidTap: rootView.closeButton.rx.tap,
            searchButtonDidTap: rootView.feedNovelConnectSearchBarView.searchButton.rx.tap,
            searchResultCollectionViewItemSelected: rootView.feedNovelConnectSearchResultView.searchResultCollectionView.rx.itemSelected.asObservable(),
            searchResultCollectionViewSwipeGesture: rootView.feedNovelConnectSearchResultView.searchResultCollectionView.rx.swipeGesture([.up, .down])
                .when(.recognized)
                .asObservable(),
            connectNovelButtonDidTap: rootView.feedNovelConnectSearchResultView.connectNovelButton.rx.tap
        )
        
        let output = self.feedNovelConnectModalViewModel.transform(from: input, disposeBag: self.disposeBag)
        
        output.dismissModalViewController
            .subscribe(with: self, onNext: { owner, _ in
                owner.dismissModalViewController()
            })
            .disposed(by: disposeBag)
        
        output.endEditing
            .subscribe(with: self, onNext: { owner, _ in
                owner.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        output.searchResultList.bind(to: rootView.feedNovelConnectSearchResultView.searchResultCollectionView.rx.items(cellIdentifier: FeedNovelConnectCollectionViewCell.cellIdentifier, cellType: FeedNovelConnectCollectionViewCell.self)) { item, element, cell in
            cell.bindData(data: element)
        }
        .disposed(by: disposeBag)
        
        output.showConnectNovelButton
            .subscribe(with: self, onNext: { owner, _ in
                owner.rootView.feedNovelConnectSearchResultView.showConnectNovelButton()
            })
            .disposed(by: disposeBag)
    }
}
