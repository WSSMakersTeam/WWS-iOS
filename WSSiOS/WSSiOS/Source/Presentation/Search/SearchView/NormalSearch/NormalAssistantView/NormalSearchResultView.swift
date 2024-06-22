//
//  NormalSearchResultView.swift
//  WSSiOS
//
//  Created by Seoyeon Choi on 5/27/24.
//

import UIKit

import SnapKit
import Then

final class NormalSearchResultView: UIView {
    
    //MARK: - Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    let normalSearchHeaderView = NormalSearchHeaderCollectionView()
    let normalSearchCollectionView = UICollectionView(frame: .zero,
                                                      collectionViewLayout: UICollectionViewLayout())
    private let normalSearchCollectionViewLayout = UICollectionViewFlowLayout()
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    
    private func setUI() {
        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }
        
        normalSearchCollectionView.do {
            $0.showsVerticalScrollIndicator = false
            $0.isUserInteractionEnabled = false
        }
        
        normalSearchCollectionViewLayout.do {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 6
            $0.itemSize = CGSize(width: 335, height: 105)
            $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
            normalSearchCollectionView.setCollectionViewLayout($0, animated: false)
        }
    }
    
    private func setHierarchy() {
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(normalSearchHeaderView,
                         normalSearchCollectionView)
    }
    
    private func setLayout() {
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.height.greaterThanOrEqualTo(self.snp.height).priority(.low)
            $0.width.equalTo(scrollView.snp.width)
        }
        
        normalSearchHeaderView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(20)
        }
        
        normalSearchCollectionView.snp.makeConstraints {
            $0.top.equalTo(normalSearchHeaderView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
            // 무한 스크롤을 위한 컬렉션뷰 동적 높이 조절 필요
            $0.height.equalTo(1000)
        }
    }
}
