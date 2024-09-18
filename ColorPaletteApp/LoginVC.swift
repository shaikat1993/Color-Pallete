import UIKit

class LoginVC: UIViewController, StoryboardInstantiable {
    static var storyboardName: String = "Main"
    static let identifier: String = "LoginVC"
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    private let networkManager: NetworkManager
    
    // Dependency Injection
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.networkManager = NetworkManager()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        setupTextAnimation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearTextFields()
        loginButton.isEnabled = false
    }
    
    private func setupUI() {
        titleLabel.text = ""
        usernameTextField.placeholder = "Username"
        passwordTextField.placeholder = "Password"
        loginButton.setTitle("Login", for: .normal)
        updateLoginButtonState()
        errorLabel.isHidden = true
    }
    
    private func clearTextFields() {
        [usernameTextField, 
         passwordTextField].forEach {
            $0.text = ""
        }
    }
    
    private func setupTextFields() {
        [usernameTextField,
         passwordTextField].forEach { textField in
            textField.addTarget(self,
                                action: #selector(textFieldsDidChange),
                                for: .editingChanged)
        }
    }

    private func setupTextAnimation() {
        let title = "Color Palette"
        let attributedString = NSMutableAttributedString(string: "")
        
        for (index, char) in title.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) { [weak self] in
                guard let self = self else { return }
                let coloredChar = NSAttributedString(string: String(char), 
                                                     attributes: [
                    .foregroundColor: UIColor.random()
                ])
                attributedString.append(coloredChar)
                self.titleLabel.attributedText = attributedString
            }
        }
    }

    @IBAction private func loginButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
//        // for testing purpose
//        let validUsername = "fsc-oboe"
//        let validPassword = "zYghYGem"
        guard let username = usernameTextField.text,
                let password = passwordTextField.text else {
            handleLoginError(error: "Missing username or password")
            return
        }
        
        PPHUD.show()
        networkManager.login(username: username, 
                             password: password) { [weak self] token, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                PPHUD.dismiss()
                if let token = token {
                    self.handleLoginSuccess(token: token, username: username)
                } else {
                    PPHUD.showError(withStatus: "Something went wrong!")
                    self.handleLoginError(error: error ?? "Unknown error")
                }
            }
        }
    }
    
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func handleLoginSuccess(token: String, username: String) {
        // Store token securely in Keychain
        TokenHandler.save(token, for: username)
        UserDefaultsManager.shared.storedUsername = username
        
        // Navigate to the main screen
        let mainVC = ViewController.instance()
        navigationController?.pushViewController(mainVC, animated: true)
        errorLabel.isHidden = true
    }
    
    private func handleLoginError(error: String) {
        errorLabel.text = "Username or Password is incorrect."
        errorLabel.isHidden = false
    }
    
    // update the login button state
    private func updateLoginButtonState() {
        let isFormValid = !(usernameTextField.text?.isEmpty ?? true) &&
                          !(passwordTextField.text?.isEmpty ?? true)
        loginButton.isEnabled = isFormValid
        loginButton.backgroundColor = isFormValid ? #colorLiteral(red: 0, green: 0.4192638397, blue: 0.7753102183, alpha: 1) : #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    }
}

extension LoginVC {
    @objc private func textFieldsDidChange() {
        errorLabel.isHidden = true
        updateLoginButtonState()
    }
}
