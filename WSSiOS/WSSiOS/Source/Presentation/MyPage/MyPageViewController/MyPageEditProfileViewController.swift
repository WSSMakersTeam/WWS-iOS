//
//  MyPageProfileEditViewController.swift
//  WSSiOS
//
//  Created by 신지원 on 7/26/24.
//

import UIKit

import RxSwift
import RxGesture

final class MyPageEditProfileViewController: UIViewController, UIScrollViewDelegate {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let viewModel: MyPageEditProfileViewModel
    
    //MARK: - Components
    
    private let rootView = MyPageEditProfileView()
    
    // MARK: - Life Cycle
    
    init(viewModel: MyPageEditProfileViewModel) {
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigation()
        hideTabBar()
        swipeBackGesture()
    }
    
    //MARK: - Bind
    
    private func register() {
        rootView.genreCollectionView.register(
            MyPageEditProfileGenreCollectionViewCell.self,
            forCellWithReuseIdentifier: MyPageEditProfileGenreCollectionViewCell.cellIdentifier)
    }
    
    private func delegate() {
        rootView.genreCollectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let input = MyPageEditProfileViewModel.Input(
            backButtonDidTap: rootView.backButton.rx.tap,
            completeButtonDidTap: rootView.completeButton.rx.tap,
            profileViewDidTap: rootView.profileView.rx.tapGesture().when(.recognized).asObservable(), 
            updateNicknameText: rootView.nicknameTextField.rx.text.orEmpty.asObservable(), 
            textFieldBeginEditing: rootView.nicknameTextField.rx.controlEvent(.editingDidBegin),
            clearButtonDidTap: rootView.clearButton.rx.tap,
            checkButtonDidTap: rootView.checkButton.rx.tap,
            updateIntroText: rootView.introTextView.rx.text.orEmpty.asObservable(),
            textViewBeginEditing: rootView.introTextView.rx.didBeginEditing,
            textViewEndEditing: rootView.introTextView.rx.didEndEditing,
            genreCellTap: rootView.genreCollectionView.rx.modelSelected(String.Type.self)
        )
        
        let output = self.viewModel.transform(from: input, disposeBag: self.disposeBag)
        
        output.bindGenreCell
            .bind(to: rootView.genreCollectionView.rx.items(
                cellIdentifier: MyPageEditProfileGenreCollectionViewCell.cellIdentifier,
                cellType: MyPageEditProfileGenreCollectionViewCell.self)) { row, element, cell in
                    cell.bindData(genre: element, isSelected: false)
                }
                .disposed(by: disposeBag)
        
        output.popViewController
            .subscribe(with: self, onNext: { owner, _ in
                owner.popToLastViewController()
            })
            .disposed(by: disposeBag)
        
        output.nicknameText
            .bind(with: self, onNext: { owner, text in
                owner.rootView.updateNickname(text: text)
            })
            .disposed(by: disposeBag)
        
        output.updateTextField
            .bind(with: self, onNext: { owner, _ in
                owner.rootView.updateNicknameTextFieldColor(update: true)
            })
            .disposed(by: disposeBag)
        
        output.checkNickname
            .bind(with: self, onNext: { owner, update in
                //                owner.rootView.warningNickname(isWarning: .exist)
            })
            .disposed(by: disposeBag)
        
        output.introText
            .bind(with: self, onNext: { owner, text in
                owner.rootView.updateIntro(text: text)
            })
            .disposed(by: disposeBag)
        
        output.introBeginEditing
            .bind(with: self, onNext: { owner, _ in
                owner.rootView.updateIntroTextViewColor(update: true)
            })
            .disposed(by: disposeBag)
        
        output.introEndEditing
            .bind(with: self, onNext: { owner, _ in
                owner.rootView.updateIntroTextViewColor(update: false)
            })
            .disposed(by: disposeBag)
    }
}

extension MyPageEditProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text: String?

        text = self.viewModel.genreList[indexPath.item]

        guard let unwrappedText = text else {
            return CGSize(width: 0, height: 0)
        }

        let width = (unwrappedText as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.Body2]).width + 26
        return CGSize(width: width, height: 37)
    }
}

//MARK: - UI

extension MyPageEditProfileViewController {
    private func setNavigation() {
        preparationSetNavigationBar(title: StringLiterals.Navigation.Title.editProfile,
                                    left: self.rootView.backButton,
                                    right: self.rootView.completeButton)
    }
}
