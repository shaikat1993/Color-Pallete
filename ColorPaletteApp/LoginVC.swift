//
//  LoginVC.swift
//  ColorPaletteApp
//
//  Created by Md Sadidur Rahman on 16/9/24.
//

import UIKit

class LoginVC: UIViewController,StoryboardInstantiable {
    static var storyboardName: String = "Main"
    static let identifier: String = "LoginVC"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginButton.isEnabled = false
        
        [usernameTextField, 
         passwordTextField].forEach({
            $0.text = ""
            
        })
        
        setupUI()
        setupTextAnimation()
        setupTextfield()
    }
    
    func setupUI() {
        titleLabel.text = ""
        usernameTextField.placeholder = "Username"
        passwordTextField.placeholder = "Password"
        loginButton.setTitle("Login",
                             for: .normal)
        errorLabel.isHidden = true
    }
    
    func setupTextAnimation() {
        let title = "Color Palette"
        var charIndex = 0.0
        // Initialize an empty mutable attributed string
        let attributedString = NSMutableAttributedString(string: "")
        
        for char in title {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex,
                                 repeats: false) { [weak self] timer in
                let coloredChar = NSAttributedString(string: String(char), attributes: [
                    .foregroundColor: UIColor.random()
                ])
                // Append the colored character to the main attributed string
                attributedString.append(coloredChar)
                // Update the label with the new attributed string
                self?.titleLabel.attributedText = attributedString
            }
            charIndex += 1
        }
    }
    
    func setupTextfield() {
        // Add target for text field changes to enable/disable login button based on input
        usernameTextField.addTarget(self, 
                                    action: #selector(textFieldsDidChange),
                                    for: .editingChanged)
        passwordTextField.addTarget(self, 
                                    action: #selector(textFieldsDidChange),
                                    for: .editingChanged)
    }
    
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // when the button is pressed call resign first responder for both textfield
        [usernameTextField,
         passwordTextField].forEach({
            $0?.resignFirstResponder()
            
        })
        let validUsername = "fsc-oboe"
        let validPassword = "zYghYGem"
        
        networkManager.login(username: validUsername,
                             password: validPassword) { [weak self] token, error in
            DispatchQueue.main.async {
                if let token = token {
                    TokenHandler.save(token, for: validUsername)
                    UserDefaultsManager.shared.storedUsername = validUsername
                    
                    // Store token securely in Keychain
                    UserDefaultsManager.shared.storedUsername = validUsername
                    KeychainHelper.shared.saveToken(token,
                                                    for: validUsername)
                    
                    
                    self?.handleLoginSuccess(token: token)
                    // Proceed to the next screen
                    self?.errorLabel.isHidden = true
                } else if let error = error {
                    self?.handleLoginError(error: error)
                }
            }
        }
    }
    
    func handleLoginSuccess(token: String) {
        // Store the token securely using Keychain or another secure storage
        
       
        
        // TokenManager.shared.storeToken(token: token)
        
        // Login successful
        //TokenHandler.save(token)
        
        // set isLoggedIn(for testing purpose)
        UserDefaultsManager.shared.isLoggedIn = true
        
        // Navigate to the main screen
        let mainVC = ViewController.instance()
        navigationController?.pushViewController(mainVC, animated: true)
    }
    
    func handleLoginError(error: String) {
        errorLabel.text = "Login failed: \(error)"
        errorLabel.isHidden = false
    }
}

extension LoginVC {
    // Function to handle text field changes and enable/disable login button
    @objc func textFieldsDidChange() {
        // Enable login button only when both username and password fields are not empty
        let isUsernameEmpty = usernameTextField.text?.isEmpty ?? true
        let isPasswordEmpty = passwordTextField.text?.isEmpty ?? true
        
        loginButton.isEnabled = (!isUsernameEmpty &&
                                !isPasswordEmpty)
    }
}
