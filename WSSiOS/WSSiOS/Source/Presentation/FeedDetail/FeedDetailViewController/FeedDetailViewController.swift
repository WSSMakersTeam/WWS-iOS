//
//  FeedDetailViewController.swift
//  WSSiOS
//
//  Created by Seoyeon Choi on 6/23/24.
//

import UIKit

import RxSwift
import RxCocoa
import RxKeyboard

final class FeedDetailViewController: UIViewController {
    
    //MARK: - Properties
    
    private let viewModel: FeedDetailViewModel
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    private let rootView = FeedDetailView()
    
    // MARK: - Life Cycle
    
    init(viewModel: FeedDetailViewModel) {
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
        
        hideTabBar()
        setNavigationBar()
        
        bindViewModel()
        registerCell()
        delegate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - UI
    
    private func setNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.titleView = self.rootView.viewTitleLabel
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.rootView.backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rootView.dotsButton)
    }
    
    //MARK: - Bind
    
    private func registerCell() {
        rootView.replyView.replyCollectionView.register(FeedDetailReplyCollectionViewCell.self,
                                                        forCellWithReuseIdentifier: FeedDetailReplyCollectionViewCell.cellIdentifier)
    }
    
    private func delegate() {
        rootView.replyView.replyCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        rootView.replyWritingView.replyWritingTextView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let input = FeedDetailViewModel.Input(
            replyCollectionViewContentSize: rootView.replyView.replyCollectionView.rx.observe(CGSize.self, "contentSize"))
        let output = viewModel.transform(from: input, disposeBag: disposeBag)
        
        output.feedProfileData
            .drive(with: self, onNext: { owner, data in
                if let data = data {
                    owner.rootView.profileView.bindData(data: data)
                }
            })
            .disposed(by: disposeBag)
        
        output.feedDetailData
            .drive(with: self, onNext: { owner, data in
                if let data = data {
                    owner.rootView.feedContentView.bindData(data: data)
                }
            })
            .disposed(by: disposeBag)
        
        output.commentCountLabel
            .drive(with: self, onNext: { owner, data in
                owner.rootView.replyView.bindData(commentCount: data)
            })
            .disposed(by: disposeBag)
        
        output.commentsData
            .drive(rootView.replyView.replyCollectionView.rx.items(
                cellIdentifier: FeedDetailReplyCollectionViewCell.cellIdentifier,
                cellType: FeedDetailReplyCollectionViewCell.self)) { row, element, cell in
                    cell.bindData(data: element)
                }
                .disposed(by: disposeBag)
        
        output.replyCollectionViewHeight
            .drive(with: self, onNext: { owner, height in
                owner.rootView.replyView.updateCollectionViewHeight(height: height)
            })
            .disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(with: self, onNext: { owner, keyboardHeight in
                print("현재 키보드 높이: \(keyboardHeight)")
                let height = keyboardHeight > 0 ? -keyboardHeight + self.rootView.safeAreaInsets.bottom : 0
                self.rootView.replyWritingView.snp.updateConstraints {
                    $0.bottom.equalTo(self.rootView.safeAreaLayoutGuide).offset(height)
                }
                self.rootView.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
}

extension FeedDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let text = viewModel.replyContentForItemAt(indexPath: indexPath) else {
            return CGSize(width: 0, height: 0)
        }
        
        guard let numberOfLines = viewModel.replyContentNumberOfLines(indexPath: indexPath) else {
            return CGSize(width: 0, height: 0)
        }
        
        let height = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.Body2,
                                                              NSAttributedString.Key.kern: -0.6]).height
        let finalHeight = height * CGFloat(numberOfLines) + 28
        return CGSize(width: UIScreen.main.bounds.width - 40, height: finalHeight)
    }
}

extension FeedDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: rootView.replyWritingView.replyWritingTextView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        let lineHeight = textView.font?.lineHeight ?? 0
        let numberOfLines = Int(estimatedSize.height / lineHeight)
        
        rootView.replyWritingView.replyWritingTextView.snp.updateConstraints {
            $0.height.equalTo(min(estimatedSize.height, 84))
        }
        
        rootView.replyWritingView.textViewBackgroundView.snp.updateConstraints {
            $0.height.equalTo(min(estimatedSize.height + 14, 98))
        }
        
        rootView.replyWritingView.replyWritingTextView.isScrollEnabled = numberOfLines > 4
        
        UIView.animate(withDuration: 0.2) {
            self.rootView.replyWritingView.layoutIfNeeded()
        }
    }
}
