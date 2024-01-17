//
//  MemoEditContentView.swift
//  WSSiOS
//
//  Created by Hyowon Jeon on 1/13/24.
//

import UIKit

import SnapKit
import Then

final class MemoEditContentView: UIView {

    // MARK: - UI Components
    
    public let memoTextView = UITextView()
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHierachy()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - set UI
    
    private func setUI() {
        self.backgroundColor = .Gray50
        
        memoTextView.do {
            $0.backgroundColor = .clear
            $0.textColor = .Black
            $0.font = .Body1
            $0.showsVerticalScrollIndicator = false
        }
    }
    
    // MARK: - set Hierachy
    
    private func setHierachy() {
        self.addSubview(memoTextView)
    }
    
    // MARK: - set Layout
    
    private func setLayout() {
        memoTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
    }
    
    func updateTextViewConstraint(keyboardHeight: CGFloat) {
        self.memoTextView.snp.updateConstraints {
            $0.bottom.equalToSuperview().inset(keyboardHeight + 20)
        }
    }
    
    func bindData(memoContent: String) {
        self.memoTextView.do {
            $0.makeAttribute(with: memoContent)?
                .lineSpacing(spacingPercentage: 140)
                .kerning(kerningPixel: -0.8)
                .applyAttribute()
            $0.font = .Body1
        }
    }
}
