//
//  CreateAccountViewController.swift
//  1to50
//
//  Created by dream on 2023/08/25.
//

import UIKit

class CreateAccountViewController: BaseViewController {

    // ID입력칸
    @IBOutlet weak var idTextField: UITextField!
    
    // PWD입력칸
    @IBOutlet weak var pwdTextField: UITextField!
    
    // PWD확인칸
    @IBOutlet weak var pwdCheck: UITextField!
    
    // PWD칸의 눈
    @IBOutlet weak var pwdEye: UIButton!
    
    // PWD확인칸의 눈
    @IBOutlet weak var pwdCheckEye: UIButton!
    
    // 화면이 로드되었을 때 호출되는 함수입니다.
    override func viewDidLoad() {
        
        // 눈 버튼 기본 설정
        pwdTextField.secureToggleActions(pwdEye, mode: pwdCheck.rightViewMode)
        pwdCheck.secureToggleActions(pwdCheckEye, mode: pwdCheck.rightViewMode)
        
        // pwd숨기기
        pwdTextField.isSecureTextEntry = true
        pwdCheck.isSecureTextEntry = true
        
    }
    
    
    // 이 함수는 '생성' 버튼를 누렀을 때 실행되는 함수입니다.
    @IBAction func createBtn(_ sender: Any) {
        
        // 아이디 또는 비밀번호가 빈킨이면 오류출력후 리턴합니다.
        if idTextField.text!.isEmpty || pwdTextField.text!.isEmpty {
            showToast(message: "아이디또는 비밀번호를 입력하십시오.")
            return
        // 입력한 비밀번호가 다르면 오류출력후 리턴합니다.
        } else if pwdTextField.text! != pwdCheck.text! {
            showToast(message: "입력하신 비밀번호가 서로 다릅니다.")
            return
        // 비밀번호 정규식이 틀렸을 때 오류출력후 리턴합니다.
        } else if !isPasswordValid(pwdTextField.text!) {
            showToast(message: "비밀번호는 8~20자 이상의 영어,숫자,특수문자가 포함되어야 합니다.")
            return
        }
        
        let userID : NSString = idTextField.text! as NSString
        let userPWD: NSString = pwdTextField.text! as NSString
        
        // 회원가입 함수를 호출합니다.
        databaseManager.registerUser(userID: userID, userPWD: userPWD, result: &myResult)
        
        // 회원가입 함수 성공시 화면 이동합니다
        if myResult.0 {
            self.navigationController?.popViewController(animated: true)
        // 회원가입 함수 실패시 오류출력후 리턴합니다
        } else {
            showToast(message: myResult.1)
            return
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        // Back버튼 클릭 시 전 화면으로 이동
        moveView(index: 0)

    }
    
    
}
