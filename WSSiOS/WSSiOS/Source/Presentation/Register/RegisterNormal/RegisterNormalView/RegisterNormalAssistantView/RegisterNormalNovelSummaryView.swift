//
//  NovelSummaryView.swift
//  WSSiOS
//
//  Created by 이윤학 on 1/11/24.
//

import UIKit

import SnapKit
import Then

final class RegisterNormalNovelSummaryView: UIView {
    
    // MARK: - UI Components
    
    private let novelSummaryStackView = UIStackView()
    private let plotTitleLabel = WSSSectionTitleView()
    private let plotLabel = UILabel()
    private let genreTitleLabel = WSSSectionTitleView()
    private let genreLabel = UILabel()
    private let platformTitleLabel = WSSSectionTitleView()
    private let platformButtonStackView = UIStackView()
    private let spacer = UIView()
    private lazy var platformButtons = [
        RegisterNormalPlatformSelectButton(platformName: "네이버시리즈"),
        RegisterNormalPlatformSelectButton(platformName: "카카오페이지"),
        spacer
    ]
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setHieararchy()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom Method
    
    private func setUI() {
        self.do {
            $0.backgroundColor = .Gray50
        }
        novelSummaryStackView.do {
            $0.axis = .vertical
            $0.spacing = 35
            $0.alignment = .fill
        }
        
        plotTitleLabel.do {
            $0.setText("작품 소개")
        }
        
        plotLabel.do {
            $0.text = "왕실에는 막대한 빚이 있었고, 그들은 빚을 갚기 위해 왕녀인 바이올렛을 막대한 돈을 지녔지만 공작의 사생/아인 윈터에게 시집보낸다. '태어나서 이렇게 멋있는 남자는 처음 봐…….' 왕실에는 막대한 빚이 있었고, 그들은 빚을 갚기 위해 왕녀인 바이올렛을 막대한 돈을 지녔지만 공작의 사생/아인 윈터에게 시집보낸다."
            bodyStyle(of: plotLabel)
        }
        
        genreTitleLabel.do {
            $0.setText("장르")
        }
        
        genreLabel.do {
            $0.text = "로판"
            bodyStyle(of: genreLabel)
        }
        
        platformTitleLabel.do {
            $0.setText("작품 보러가기")
        }
        
        platformButtonStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
        }
    }
    
    private func setHieararchy() {
        self.addSubview(novelSummaryStackView)
        novelSummaryStackView.addArrangedSubviews(plotTitleLabel,
                                                  plotLabel,
                                                  genreTitleLabel,
                                                  genreLabel,
                                                  platformTitleLabel,
                                                  platformButtonStackView)
        platformButtons.forEach {
            platformButtonStackView.addArrangedSubview($0)
        }
    }
    
    private func setLayout() {
        novelSummaryStackView.do {
            $0.snp.makeConstraints {
                $0.top.equalToSuperview().inset(32)
                $0.bottom.equalToSuperview().inset(100)
                $0.horizontalEdges.equalToSuperview().inset(20)
            }
            
            $0.setCustomSpacing(10, after: plotTitleLabel)
            $0.setCustomSpacing(10, after: genreTitleLabel)
            $0.setCustomSpacing(10, after: platformTitleLabel)
        }
    }
    
    private func bodyStyle(of label: UILabel) {
        label.do {
            $0.makeAttribute(with: label.text)?
                .lineSpacing(spacingPercentage: 150)
                .kerning(kerningPixel: -0.6)
                .applyAttribute()
            $0.font = .Body2
            $0.numberOfLines = 0
            $0.textColor = .Gray300
        }
    }
    
    func bindData(plot: String?, genre: String?) {
        plotLabel.text = plot
        genreLabel.text = genre
        bodyStyle(of: plotLabel)
        bodyStyle(of: genreLabel)
    }
}
