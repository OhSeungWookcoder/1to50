//
//  MainViewController.swift
//  1to50
//
//  Created by dream on 2023/08/28.
//

import UIKit

class MainViewController: BaseViewController {
    
    // 화면이 로드 되었을때 실행되는 함수입니다.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 뒤로가기 버튼 없애기
        self.navigationItem.hidesBackButton = true
    }
    
    // 게임 시작 버튼
    @IBAction func startGameBtn(_ sender: Any) {
        moveView(index: 5)
    }
    
    @IBAction func startGameLogo(_ sender: Any) {
        moveView(index: 5)
    }
    
    // Ranking 이동 버튼
    @IBAction func showRankingBtn(_ sender: Any) {
        moveView(index: 4)
    }
    
    @IBAction func RankingLogoBtn(_ sender: Any) {
        moveView(index: 4)
    }
    
    // 프로필 화면 이동 버튼
    @IBAction func showProfile(_ sender: Any) {
        moveView(index: 3)
    }
    
    @IBAction func ProfileLogoBtn(_ sender: Any) {
        moveView(index: 3)
    }
}
