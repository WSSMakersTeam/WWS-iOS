//
//  HomeViewController.swift
//  WSSiOS
//
//  Created by 최서연 on 1/9/24.
//

import UIKit

import RxSwift
import RxCocoa

final class HomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private let userRepository: UserRepository
    private let recommendRepository: RecommendRepository
    private var characterId: Int = 0
    private var userNickname: String = ""
    private var userCharacter = UserCharacter(avatarId: 0, avatarTag: "", avatarComment: "", userNickname: "")
    private var sosopickListRelay = BehaviorRelay<[SosopickNovel]>(value: [])
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    private let rootView = HomeView()
    
    //MARK: - Life Cycle
    
    init(userRepository: UserRepository, recommendRepository: RecommendRepository) {
        self.userRepository = userRepository
        self.recommendRepository = recommendRepository
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
        
        bindDataToUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        
        registerCell()
        bindDataToSosoPickCollectionView()
    }
    
    private func setUI() {
        self.view.do {
            $0.backgroundColor = .White
        }
    }
    
    private func registerCell() {
        rootView.sosopickView.sosoPickCollectionView.register(HomeSosoPickCollectionViewCell.self,
                                                              forCellWithReuseIdentifier: HomeSosoPickCollectionViewCell.identifier)
    }
    
    func getDataFromAPI(disposeBag: DisposeBag,
                        completion: @escaping (Int, UserCharacter, SosopickNovels)
                        -> Void) {
        let userObservable = self.userRepository.getUserCharacter()
            .do(onNext: { [weak self] user in
                guard let self = self else { return }
                self.userCharacter = user
            })
        
        let sosopickObservable = self.recommendRepository.getSosopickNovels()
            .do(onNext: { [weak self] sosopicks in
                guard let self = self else { return }
                print("☘️☘️☘️☘️☘️☘️☘️☘️☘️☘️☘️☘️☘️☘️☘️☘️☘️")
                print(sosopicks)
            })
        
        Observable.zip(userObservable, sosopickObservable)
            .subscribe(
                onNext: { [weak self] user, sosopicks in
                    guard let self = self else { return }
                    completion(self.characterId, user, sosopicks)
                },
                onError: { error in
                    print(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func bindDataToSosoPickCollectionView() {
        sosopickListRelay.bind(to: rootView.sosopickView.sosoPickCollectionView.rx.items(
            cellIdentifier: HomeSosoPickCollectionViewCell.identifier,
            cellType: HomeSosoPickCollectionViewCell.self)) { (row, element, cell) in
                cell.bindData(data: element)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindDataToUI() {
        getDataFromAPI(disposeBag: disposeBag) { [weak self] characterId, user, sosopick in
            self?.updateUI(user: user, sosopickList: sosopick)
        }
    }
    
    private func updateUI(user: UserCharacter, sosopickList: SosopickNovels) {
        Observable.just(userCharacter)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { user in
                self.rootView.characterView.tagView.tagLabel.text = user.avatarTag
                self.rootView.characterView.characterCommentLabel.text = user.avatarComment
                self.characterId = user.avatarId
                self.userNickname = user.userNickname
                
                self.sosopickListRelay.accept(sosopickList.sosoPickNovels)
            })
            .disposed(by: disposeBag)
    }
}
