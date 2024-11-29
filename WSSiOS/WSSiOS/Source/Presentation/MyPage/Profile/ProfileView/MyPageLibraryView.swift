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
    
    // MARK: - Properties
    
    var isExist: Bool = true {
        didSet {
            updateLibraryView(isExist: isExist)
        }
    }
    
    // MARK: - Components
    
    let stackView = UIStackView()
    let inventoryView = MyPageInventoryView()
    let preferencesEmptyView = MyPagePreferencesEmptyView()
    let genrePrefrerencesView = MyPageGenrePreferencesView()
    let novelPrefrerencesView = MyPageNovelPreferencesView()
    
    private let myPagePrivateView = MyPagePrivateView()
    
    private let dividerView = UIView()
    private let dividerView2 = UIView()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setHierarchy()
        setLayout()
        updateLibraryView(isExist: isExist)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        stackView.do {
            $0.axis = .vertical
            $0.spacing = 3
            $0.alignment = .fill
            $0.distribution = .fill
        }
        
        [dividerView, dividerView2].forEach {
            $0.backgroundColor = .wssGray50
        }
    }
    
    private func setHierarchy() {
        self.addSubview(stackView)
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        inventoryView.snp.makeConstraints {
            $0.height.equalTo(160)
        }
        
        genrePrefrerencesView.snp.makeConstraints {
            $0.height.equalTo(221.5)
        }
        
        novelPrefrerencesView.snp.makeConstraints {
            $0.height.equalTo(270)
        }
        
        [dividerView, dividerView2].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(3)
            }
        }
        
        myPagePrivateView.snp.makeConstraints {
            $0.height.equalTo(812)
        }
    }
    
    func updateGenreViewHeight(isExpanded: Bool) {
        genrePrefrerencesView.snp.updateConstraints {
            $0.height.equalTo(isExpanded ? 514 : 224.5)
        }
    }
    
    //MARK: - Data
    
    func updateLibraryView(isExist: Bool) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if isExist {
            stackView.addArrangedSubviews(inventoryView,
                                          dividerView,
                                          genrePrefrerencesView,
                                          dividerView2,
                                          novelPrefrerencesView)
        } else {
            stackView.addArrangedSubviews(inventoryView,
                                          dividerView,
                                          preferencesEmptyView)
            
            preferencesEmptyView.snp.remakeConstraints {
                $0.height.equalTo(363)
            }
        }
    }
    
    func isPrivateUserView(isPrivate: Bool, nickname: String) {
        if isPrivate {
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            stackView.addArrangedSubviews(myPagePrivateView)
            
            let text = nickname + StringLiterals.MyPage.Profile.privateLabel
            myPagePrivateView.isPrivateDescriptionLabel.do {
                $0.applyWSSFont(.body2, with: text)
                $0.textAlignment = .center
            }
        }
    }
}
