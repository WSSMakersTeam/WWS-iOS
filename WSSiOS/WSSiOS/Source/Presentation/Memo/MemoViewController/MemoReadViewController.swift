//
//  MemoReadViewController.swift
//  WSSiOS
//
//  Created by Hyowon Jeon on 1/13/24.
//

import UIKit

import RxCocoa
import RxSwift

final class MemoReadViewController: UIViewController {
    
    //MARK: - Properties
    
    private let repository: MemoRepository
    private let disposeBag = DisposeBag()
    private let memoId: Int
    private var novelTitle = ""
    private var novelAuthor = ""
    private var novelImage = ""
    private var memoContent = ""

    //MARK: - Components
    
    private let rootView = MemoReadView()
    private let backButton = UIButton()
    private let editButon = UIButton()

     //MARK: - Life Cycle
    
    init(repository: MemoRepository, memoId: Int) {
        self.repository = repository
        self.memoId = memoId
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
        
        getMemoDetail()
    }

     override func viewDidLoad() {
         super.viewDidLoad()
         
         setNavigationBar()
         setUI()
         setNotificationCenter()
         setTapGesture()
         bindUI()
     }
    
    //MARK: - UI
    
    private func setUI() {
        backButton.do {
            $0.setImage(.icNavigateLeft.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        editButon.do {
            $0.setButtonAttributedTitle(text: StringLiterals.Memo.edit, font: .Title2, color: .wssPrimary100)
        }
    }
    
    private func setNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.editButon)
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    private func setNotificationCenter() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.deletedMemo(_:)),
            name: NSNotification.Name("DeletedMemo"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.patchedMemo(_:)),
            name: NSNotification.Name("PatchedMemo"),
            object: nil
        )
    }
    
    private func setTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Bind
    
    private func bindUI() {
        backButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        editButon.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                owner.navigationController?.pushViewController(MemoEditViewController(
                    repository: DefaultMemoRepository(
                        memoService: DefaultMemoService()
                    ),
                    memoId: owner.memoId,
                    novelTitle: owner.novelTitle,
                    novelAuthor: owner.novelAuthor,
                    novelImage: owner.novelImage,
                    memoContent: owner.memoContent
                ), animated: true)
            })
            .disposed(by: disposeBag)
        
        rootView.memoReadContentView.deleteButton.rx.tap
            .throttle(.seconds(3), latest: false, scheduler: MainScheduler.instance)
            .bind(with: self, onNext: { owner, _ in
                let vc = DeletePopupViewController(
                    memoRepository: DefaultMemoRepository(
                        memoService: DefaultMemoService()
                    ),
                    popupStatus: .memoDelete,
                    memoId: owner.memoId
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                owner.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - API
    
    private func getMemoDetail() {
        repository.getMemoDetail(memoId: self.memoId)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, data in
                owner.bindData(data)
            },onError: { owner, error in
                print(error)
            }).disposed(by: disposeBag)
    }
    
    //MARK: - Custom Method
    
    private func bindData(_ memoDetail: MemoDetail) {
        self.novelTitle = memoDetail.userNovelTitle
        self.novelAuthor = memoDetail.userNovelAuthor
        self.novelImage = memoDetail.userNovelImg
        self.memoContent = memoDetail.memoContent
        
        self.rootView.memoHeaderView.bindData(
            novelTitle: memoDetail.userNovelTitle,
            novelAuthor: memoDetail.userNovelAuthor,
            novelImage: memoDetail.userNovelImg
        )
        
        self.rootView.memoReadContentView.bindData(
            date: memoDetail.memoDate,
            memoContent: memoDetail.memoContent
        )
    }
    
    @objc func viewDidTap() {
        view.endEditing(true)
    }
    
    @objc func deletedMemo(_ notification: Notification) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func patchedMemo(_ notification: Notification) {
        showToast(.memoEditSuccess)
    }
}
