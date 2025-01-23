//
//  HomeNoticeView.swift
//  WSSiOS
//
//  Created by Seoyeon Choi on 5/12/24.
//

import UIKit

import SnapKit
import Then

final class HomeNoticeView: UIView {
    
    //MARK: - UI Components
    
    let backButton = UIButton()
    let noticeTableView = UITableView(frame: .zero, style: .plain)
    let loadingView = WSSLoadingView()
    
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
        backButton.do {
            $0.setImage(.icNavigateLeft.withRenderingMode(.alwaysOriginal).withTintColor(.wssBlack), for: .normal)
        }

        noticeTableView.do {
            $0.showsVerticalScrollIndicator = false
            $0.separatorStyle = .singleLine
            $0.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            $0.separatorColor = .wssGray50
            $0.rowHeight = 110
        }
        
        loadingView.do {
            $0.isHidden = true
        }
    }
    
    private func setHierarchy() {
        self.addSubviews(noticeTableView,
                         loadingView)
    }
    
    private func setLayout() {
        noticeTableView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.bottom.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    //MARK: - Custom Methods
    
    func showLoadingView(isShow: Bool) {
        loadingView.do {
            $0.isHidden = !isShow
        }
    }
    
    func updateTableViewHeight(height: CGFloat) {
        noticeTableView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }
}
