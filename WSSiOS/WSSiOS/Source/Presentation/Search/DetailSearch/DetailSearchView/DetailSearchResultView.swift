//
//  DetailSearchResultView.swift
//  WSSiOS
//
//  Created by Seoyeon Choi on 10/23/24.
//

import UIKit

import SnapKit
import Then

final class DetailSearchResultView: UIView {
    
    //MARK: - UI Components
    
    let headerView = DetailSearchResultHeaderView()
    let novelView = DetailSearchResultNovelView()
    
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
    
    private func setUI() {
        self.backgroundColor = .wssWhite
    }
    
    private func setHierarchy() {
        self.addSubviews(headerView,
                         novelView)
    }
    
    private func setLayout() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(1)
            $0.horizontalEdges.equalToSuperview()
        }
        
        novelView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
}
