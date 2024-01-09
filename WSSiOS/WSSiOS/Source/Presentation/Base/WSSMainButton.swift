//
//  WSSMainButton.swift
//  WSSiOS
//
//  Created by 신지원 on 1/9/24.
//

import UIKit

import SnapKit

class WSSMainButton: UIButton {
    
    //MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        setUI(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            setLayout()
        }
    }
    
    //MARK: - UI
    
    private func setUI(title: String) {
        setTitle(title, for: .normal)
        titleLabel?.font = .Title1
        setTitleColor(.White, for: .normal)
        backgroundColor = .Primary100
        layer.cornerRadius = 12
    }
    
    private func setLayout() {
        self.snp.makeConstraints() {
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(34)
            $0.height.equalTo(53)
        }
    }
}
