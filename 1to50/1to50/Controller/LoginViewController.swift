//
//  LoginViewController.swift
//  1to50
//
//  Created by dream on 2023/08/25.
//

import UIKit

class LoginViewController: BaseViewController, UIDocumentPickerDelegate {
    
    // 아이디 텍스트 필드
    @IBOutlet weak var idTextField: UITextField!
    
    // 비밀번호 텍스트 필드
    @IBOutlet weak var pwdTextField: UITextField!
    
    // 비밀번호 눈 버튼
    @IBOutlet weak var pwdEye: UIButton!
    
    // 로그인 버튼
    @IBOutlet weak var loginBtn: CustomButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    // 전역변수
    let baseVC = BaseViewController.shared
    
    // 화면이 로드되었을 때 호출되는 함수입니다.
    override func viewDidLoad() {
        
        // 뒤로가기 버튼 없애기
        self.navigationItem.hidesBackButton = true
        
        // 비밀번호 눈 버튼 설정를 해줍니다.
        pwdTextField.secureToggleActions(pwdEye, mode: pwdTextField.rightViewMode)
    
        // 비빌번호를 가려줍니다.
        pwdTextField.isSecureTextEntry = true
    }
    
     // 이 함수는 로그인 버튼을 눌렀을 때 호출되는 함수입니다.
    @IBAction func loginBtnClick(_ sender: Any) {
        
        // 아이디 또는 비밀번호칸이 빈칸일 때
        if idTextField.text!.isEmpty || pwdTextField.text!.isEmpty {
            errorLabel.text = "아이디또는 비밀번호를 입력하십시오."
            return
        // 비밀번호 정규식이 틀렸을 때
        } else if !isPasswordValid(pwdTextField.text!) {
            errorLabel.text = "비밀번호는 8~20자 이상의 영어,숫자,특수문자가 포함되어야 합니다."
            return
        }
        
        // 유저 로그인 함수를 호출합니다.
        baseVC.userProfile = databaseManager.loginUser(userID: idTextField.text! as NSString, password: pwdTextField.text! as NSString, keepLogin: true, result: &myResult)
    
        // 로그인 성공 시 화면 이동
        if myResult.0 {
            moveView(index: 2)
        } else {
        // 로그인 실패 시 에러 메시지 출력
            errorLabel.text = myResult.1
            return
        }
    }
    
    
    // 이 함수는 '회원가입'버튼을 누르면 회원가입 화면으로 이동하는 함수입니다.
    @IBAction func createAccount(_ sender: Any) {
        let createAccountVC = storyboard?.instantiateViewController(withIdentifier: "CreateAccountViewController")
        
        show(createAccountVC!, sender: nil)
    }
    
    // 아이디 찾기
    @IBAction func findID(_ sender: Any) {
        databaseManager.deleteTable(tableName: "users")
    }
    
    // 비밀번호 찾기
    @IBAction func findPWD(_ sender: Any) {
        
    }
    
    
}
                  

