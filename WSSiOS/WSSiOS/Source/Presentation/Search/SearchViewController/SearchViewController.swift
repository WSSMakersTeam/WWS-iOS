//
//  SearchViewController.swift
//  WSSiOS
//
//  Created by 최서연 on 1/6/24.
//

import UIKit

import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    
    //MARK: - Properties
    
    private let novelRepository: NovelRepository
    private var searchResultListRelay = BehaviorRelay<[SearchNovel]>(value: [])
    private let disposeBag = DisposeBag()
    
    //MARK: - Components
    
    private let rootView = SearchView()
    private let emptyView = SearchEmptyView()
    private let backButton = UIButton()
    
    //MARK: - Life Cycle
    
    init(novelRepository: NovelRepository) {
        self.novelRepository = novelRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showSearchBarAndFocus()
        hideTabBar()
        preparationSetNavigationBar(title: StringLiterals.Navigation.Title.search,
                                    left: backButton,
                                    right: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        delegate()
        register()
        
        bindUI()
    }
    
    //MARK: - UI
    
    private func setUI() {
        backButton.do {
            $0.setImage(.icNavigateLeft.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    //MARK: - Bind
    
    private func delegate() {
        rootView.headerView.searchBar.delegate = self
    }
    
    private func register() {
        rootView.mainResultView.searchCollectionView.register(
            SearchCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchCollectionViewCell.cellIdentifier)
        
        searchResultListRelay
            .bind(to: rootView.mainResultView.searchCollectionView.rx.items(
                cellIdentifier: SearchCollectionViewCell.cellIdentifier,
                cellType: SearchCollectionViewCell.self)) { (row, element, cell) in
                    cell.bindData(data: element)
                }
                .disposed(by: disposeBag)
    }
    
    private func bindUI() {
        rootView.headerView.searchBar.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner ,searchText in
                owner.emptyView.removeFromSuperview()
                
                if searchText.isEmpty {
                    owner.searchResultListRelay.accept([])
                }
                else {
                    owner.searchNovels(with: searchText)
                    
                    if owner.searchResultListRelay.value.isEmpty {
                        owner.view.addSubview(owner.emptyView)
                        owner.emptyView.snp.makeConstraints {
                            $0.edges.equalToSuperview()
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
        
        backButton
            .rx.tap
            .subscribe(with: self, onNext: { owner, event in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        rootView.mainResultView.searchCollectionView
            .rx
            .itemSelected
            .subscribe(with: self, onNext: { owner, indexPath in
                owner.navigationController?.pushViewController(
                    RegisterNormalViewController(
                        novelRepository: DefaultNovelRepository(
                            novelService: DefaultNovelService()),
                        userNovelRepository: DefaultUserNovelRepository(
                            userNovelService: DefaultUserNovelService()),
                        novelId: owner.searchResultListRelay.value[indexPath.row].novelId),
                    animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Actions
    
    private func searchNovels(with searchText: String) {
        let searchWord = searchText.isEmpty ? "" : searchText
        self.getDataFromAPI(disposeBag: disposeBag, searchWord: searchWord)
    }
    
    //MARK: - API
    
    private func getDataFromAPI(disposeBag: DisposeBag,
                                searchWord: String) {
        self.novelRepository.getSearchNovels(searchWord: searchWord)
            .subscribe (with: self, onNext: { owner, search in
                owner.searchResultListRelay.accept(search.novels)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Custom Method
    
    private func showSearchBarAndFocus() {
        rootView.headerView.searchBar.becomeFirstResponder()
    }
}

//MARK: - Extension

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        rootView.headerView.searchBar.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
}
