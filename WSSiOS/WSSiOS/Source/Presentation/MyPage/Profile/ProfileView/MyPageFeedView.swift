//
//  MyPageActivyView.swift
//  WSSiOS
//
//  Created by 신지원 on 12/1/24.
//

import UIKit

import SnapKit
import Then

final class MyPageFeedView: UIView {
    
    // MARK: - Properties
    
    // MARK: - Components
    
    let stackView = UIStackView()
    
    let myPageFeedTableView = FeedListView()
    
    private let showMoreActivityButtonView = UIView()
    let myPageFeedDetailButton = UIButton()
    let myPageFeedDetailButtonLabel = UILabel()
    private let paddingViewAfterButton = UIView()
    
    private let myPagePrivateView = MyPagePrivateView()
    private let myPageFeedEmptyView = MyPageFeedEmptyView()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.backgroundColor = .wssWhite
        
        stackView.do {
            $0.axis = .vertical
        }
        
        showMoreActivityButtonView.do {
            $0.isHidden = true
        }
        
        myPageFeedDetailButton.do {
            $0.layer.cornerRadius = 8
            $0.layer.borderColor = UIColor.wssPrimary100.cgColor
            $0.layer.borderWidth = 1
            
            myPageFeedDetailButtonLabel.do {
                $0.applyWSSFont(.title2, with: StringLiterals.MyPage.Profile.activyButton)
                $0.textColor = .wssPrimary100
            }
        }
        
        paddingViewAfterButton.do {
            $0.backgroundColor = .wssWhite
        }
        
        myPagePrivateView.isHidden = true
        myPageFeedEmptyView.isHidden = true
    }
    
    private func setHierarchy() {
        self.addSubview(stackView)
        stackView.addArrangedSubviews(myPageFeedTableView,
                                      showMoreActivityButtonView,
                                      paddingViewAfterButton,
                                      myPagePrivateView,
                                      myPageFeedEmptyView)
        showMoreActivityButtonView.addSubview(myPageFeedDetailButton)
        myPageFeedDetailButton.addSubview(myPageFeedDetailButtonLabel)
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
        
        myPageFeedDetailButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        myPageFeedDetailButtonLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        paddingViewAfterButton.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        myPagePrivateView.snp.makeConstraints {
            $0.height.equalTo(450)
        }
        
        myPageFeedEmptyView.snp.makeConstraints {
            $0.height.equalTo(450)
        }
    }
    
    //MARK: - Data
    
    func isPrivateUserView(isPrivate: Bool, nickname: String) {
        if isPrivate {
            myPagePrivateView.isHidden = false
            
            [myPageFeedTableView,
             showMoreActivityButtonView,
             paddingViewAfterButton,
             myPageFeedEmptyView].forEach { view in
                view.do {
                    $0.isHidden = true
                }
            }
            
            let text = nickname + StringLiterals.MyPage.Profile.privateLabel
            myPagePrivateView.isPrivateDescriptionLabel.do {
                $0.applyWSSFont(.body2, with: text)
                $0.textAlignment = .center
            }
            
        }
    }
    
    func isEmptyView(isEmpty: Bool) {
        myPageFeedEmptyView.isHidden = !isEmpty
        
        [myPageFeedTableView,
         showMoreActivityButtonView,
         paddingViewAfterButton].forEach { view in
            view.do {
                $0.isHidden = isEmpty
            }
        }
    }
    
    func showMoreButton(isShow: Bool) {
        showMoreActivityButtonView.isHidden = !isShow
        paddingViewAfterButton.isHidden = !isShow
        
        if isShow {
            paddingViewAfterButton.snp.makeConstraints {
                $0.width.equalToSuperview()
                $0.height.equalTo(40)
            }
        } else {
            paddingViewAfterButton.snp.makeConstraints {
                $0.width.bottom.equalToSuperview()
                $0.height.greaterThanOrEqualTo(40)
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.stackView.layoutIfNeeded()
        }
    }
}
