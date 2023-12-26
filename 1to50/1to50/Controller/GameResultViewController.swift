//
//  GameResultViewController.swift
//  1to50
//
//  Created by dream on 12/7/23.
//

import UIKit

class GameResultViewController: BaseViewController {
    
    @IBOutlet weak var resultView: UIView!
    
    @IBOutlet weak var recordLabel: UILabel!
    
    @IBOutlet weak var isHighScore: UILabel!
    
    // 전역변수
    let baseVC = BaseViewController.shared
    
    var count: Double = 0.0
    weak var delegate: ModalDelegate?
    
    let myStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultView.layer.borderWidth = 3
        resultView.layer.borderColor = UIColor.black.cgColor
        resultView.layer.cornerRadius = 20
        
        recordLabel.text = String(Float(count))
        
        if baseVC.userProfile!.highScore > count {
            print("2")
            isHighScore.text = "최고기록입니다!"
        } else {
            print("3")
            isHighScore.text = ""
        }
    }
    
    
    @IBAction func goMainBtn(_ sender: Any) {
        guard let presentingViewController = self.presentingViewController as? UINavigationController else {return}
        presentingViewController.popViewController(animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func restartBtn(_ sender: Any) {
        // 모달로 표시된 화면에서 다른 화면으로 이동
        self.dismiss(animated: true) {
            self.delegate?.didDismissModal()
        }
    }
}

protocol SendDataDelegate: AnyObject {
    func sendRecord(record: Float)
}
