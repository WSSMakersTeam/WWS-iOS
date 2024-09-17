//
//  ModuleFactory.swift
//  WSSiOS
//
//  Created by 이윤학 on 2/24/24.
//

import UIKit

protocol RegisterModuleFactory {
    func makeRegisterNormalViewController(novelId: Int) -> UIViewController
    func makeRegisterSuccessViewController(userNovelId: Int) -> UIViewController
}

protocol OnboardingModuleFactory {
    func makeLoginViewController() -> UIViewController
}

protocol NovelDetailModuleFactory {
    func makeNovelDetailViewController(novelId: Int) -> UIViewController
}

final class ModuleFactory {
    static let shared = ModuleFactory()
    private init() {}
}

extension ModuleFactory: RegisterModuleFactory {
    func makeRegisterNormalViewController(novelId: Int) -> UIViewController {
        return RegisterNormalViewController(viewModel: RegisterViewModel(
            novelRepository: DefaultNovelRepository(novelService: DefaultNovelService()),
            userNovelRepository: DefaultUserNovelRepository(userNovelService:DefaultUserNovelService()),
            novelId: novelId))
    }
    
    func makeRegisterSuccessViewController(userNovelId: Int) -> UIViewController {
        return RegisterSuccessViewController(userNovelId: userNovelId)
    }
}

extension ModuleFactory: NovelDetailModuleFactory {
    func makeNovelDetailViewController(novelId: Int) -> UIViewController {
        return NovelDetailViewController(
            viewModel: NovelDetailViewModel(
                detailRepository: DefaultDetailRepository(novelDetailService: DefaultNovelDetailService()),
                novelId: novelId))
    }
}

extension ModuleFactory: OnboardingModuleFactory {
    func makeLoginViewController() -> UIViewController {
        return LoginViewController(viewModel: LoginViewModel())
    }
}
