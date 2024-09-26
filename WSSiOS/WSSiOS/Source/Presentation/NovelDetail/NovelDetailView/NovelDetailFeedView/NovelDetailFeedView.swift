//
//  NovelDetailFeedView.swift
//  WSSiOS
//
//  Created by 이윤학 on 6/23/24.
//

import UIKit

import SnapKit
import Then

final class NovelDetailFeedView: UIButton {
    
    //MARK: - Components
    
    private let emptyView = NovelDetailFeedEmptyView()
    let feedListView = NovelDetailFeedListView()
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierarchy()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    
    private func setUI() {
    
    }
    
    private func setHierarchy() {
        self.addSubviews(feedListView)
    }
    
    private func setLayout() {
        feedListView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
