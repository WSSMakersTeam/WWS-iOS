//
//  MyPageLibraryView.swift
//  WSSiOS
//
//  Created by 신지원 on 11/16/24.
//

import UIKit

import SnapKit
import Then

final class MyPageLibraryView: UIView {
    
    
    // MARK: - Components
    
    let stackView = UIStackView()
    let inventoryView = MyPageInventoryView()
    let genrePrefrerencesView = MyPageGenrePreferencesView()
    let novelPrefrerencesView = MyPageNovelPreferencesView()
    
    private let preferencesEmptyView = MyPagePreferencesEmptyView()
    private let myPagePrivateView = MyPagePrivateView()
    
    private let firstDividerView = UIView()
    private let secondDividerView = UIView()
    
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
            $0.alignment = .fill
            $0.distribution = .fill
        }
        
        [firstDividerView, secondDividerView].forEach {
            $0.backgroundColor = .wssGray50
        }
        
        myPagePrivateView.isHidden = true
        preferencesEmptyView.isHidden = true
    }
    
    private func setHierarchy() {
        self.addSubview(stackView)
        stackView.addArrangedSubviews(inventoryView,
                                      firstDividerView,
                                      genrePrefrerencesView,
                                      secondDividerView,
                                      novelPrefrerencesView,
                                      myPagePrivateView,
                                      preferencesEmptyView)
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        inventoryView.snp.makeConstraints {
            $0.height.equalTo(160)
        }
        
        genrePrefrerencesView.snp.makeConstraints {
            $0.height.equalTo(221.5)
        }
        
        [firstDividerView, secondDividerView].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(3)
            }
        }
        
        myPagePrivateView.snp.makeConstraints {
            $0.height.equalTo(450)
        }
        
        preferencesEmptyView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalTo(363)
        }
    }
    
    func updateGenreViewHeight(isExpanded: Bool) {
        genrePrefrerencesView.snp.updateConstraints {
            $0.height.equalTo(isExpanded ? 514 : 224.5)
        }
    }
    
    //MARK: - Data
    
    func isPrivateUserView(isPrivate: Bool, nickname: String) {
        if isPrivate {
            [inventoryView,
             firstDividerView,
             genrePrefrerencesView,
             secondDividerView,
             novelPrefrerencesView] .forEach { view in
                view.do {
                    $0.isHidden = true
                }
            }
            
            myPagePrivateView.isHidden = false
            
            let text = nickname + StringLiterals.MyPage.Profile.privateLabel
            myPagePrivateView.isPrivateDescriptionLabel.do {
                $0.applyWSSFont(.body2, with: text)
                $0.textAlignment = .center
            }
        }
    }
    
    func updatePreferencesEmptyView(isEmpty: Bool) {
        [genrePrefrerencesView,
         secondDividerView,
         novelPrefrerencesView] .forEach { view in
            view.do {
                $0.isHidden = isEmpty
            }
            
            preferencesEmptyView.isHidden = !isEmpty
        }
    }
}
