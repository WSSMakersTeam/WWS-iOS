//
//  HomeNoticeDetailContentView.swift
//  WSSiOS
//
//  Created by Seoyeon Choi on 7/6/24.
//

import UIKit

import SnapKit
import Then

final class HomeNoticeDetailContentView: UIView {
    
    //MARK: - UI Components
    
    private let noticeTitleLabel = UILabel()
    private let createdDateLabel = UILabel()
    private let dividerView = UIView()
    private let noticeContentTextView = UITextView()
    
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
        noticeTitleLabel.do {
            $0.textColor = .wssBlack
        }
        
        createdDateLabel.do {
            $0.textColor = .wssGray200
        }
        
        dividerView.do {
            $0.backgroundColor = .wssGray50
        }
        
        noticeContentTextView.do {
            $0.textColor = .wssBlack
            $0.dataDetectorTypes = .link
            $0.isEditable = false
            $0.isScrollEnabled = false
        }
    }
    
    private func setHierarchy() {
        self.addSubviews(noticeTitleLabel,
                         createdDateLabel,
                         dividerView,
                         noticeContentTextView)
    }
    
    private func setLayout() {
        noticeTitleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(20)
        }
        
        createdDateLabel.snp.makeConstraints {
            $0.top.equalTo(noticeTitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(noticeTitleLabel.snp.leading)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(createdDateLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        noticeContentTextView.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(40)
            $0.height.equalTo(0)
        }
    }
    
    func bindData(data: NotificationDetailEntity) {
        noticeTitleLabel.do {
            $0.applyWSSFont(.headline1, with: data.title)
            $0.numberOfLines = 0
        }
        createdDateLabel.applyWSSFont(.body5, with: data.createdDate)
        noticeContentTextView.do {
            $0.applyWSSFont(.body2, with: data.content)
        }
        
        noticeContentTextView.snp.updateConstraints {
            $0.height.equalTo(getTextViewLabelHeight(text: data.content))
        }
    }
    
    private func getTextViewLabelHeight(text: String) -> CGFloat {
        let labelWidth = UIScreen.main.bounds.width - 40
        let label = UILabel(frame: .init(x: .zero,
                                         y: .zero,
                                         width: labelWidth,
                                         height: .greatestFiniteMagnitude)
        )
        label.do {
            $0.applyWSSFont(.body2, with: text)
            $0.textAlignment = .left
            $0.lineBreakStrategy = .hangulWordPriority
            $0.numberOfLines = 0
        }
        label.sizeToFit()
        
        let labelHeight = label.frame.height
        let resizedLabelHeight = ceil(labelHeight)
        return resizedLabelHeight
    }
}
