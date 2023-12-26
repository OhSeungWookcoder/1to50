//
//  ViewController.swift
//  1to50
//
//  Created by dream on 12/6/23.
//

import UIKit

class ChangePWViewController: BaseViewController {

    

    @IBOutlet weak var currentPWTextField: CustomTextField!
    
    @IBOutlet weak var PWTextField: CustomTextField!
    
    @IBOutlet weak var PWEyeButton: UIButton!
    
    @IBOutlet weak var PWCheckTextField: CustomTextField!
    
    @IBOutlet weak var PWCheckEyeButton: UIButton!
    
    @IBOutlet weak var errorTextField: UILabel!
    
    // 전역변수
    let baseVC = BaseViewController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PWTextField.secureToggleActions(PWEyeButton, mode: PWTextField.rightViewMode)
        
        PWCheckTextField.secureToggleActions(PWCheckEyeButton, mode: PWCheckTextField.rightViewMode)
        
    }

    @IBAction func clickPWChangeButton(_ sender: Any) {
        // 비밀번호 입력칸들이 빈칸이면 return
        if currentPWTextField.text == nil || PWTextField.text == nil || PWCheckTextField.text == nil || PWTextField.text != PWCheckTextField.text {
            return
        }
        
        // 비밀번호가 맞고 비밀번호 정규식에 통과시 비밀번호 바꾸기
        if currentPWTextField.text == baseVC.userProfile!.userPWD && isPasswordValid(PWTextField.text!) {
            databaseManager.changeUserPWD(userName: baseVC.userProfile!.userID as NSString, currentPassword: currentPWTextField.text! as NSString, newPassword: PWTextField.text! as NSString, result: &myResult)
            // 성공시
            if myResult.0 {
                baseVC.userProfile!.userPWD = PWTextField.text!
            }
        }
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
