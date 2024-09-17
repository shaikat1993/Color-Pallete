import UIKit

extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var rootViewController: UIViewController?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window.windowScene = windowScene
        

        // Create a UINavigationController
        let navigationController = UINavigationController()
        
        //---------------------//
        //implementing keychain helper
        let username = UserDefaultsManager.shared.storedUsername
        let token = KeychainHelper.shared.getToken(for: username)
        
        if !username.isEmpty,
            let _ = token {
       // if UserDefaultsManager.shared.isLoggedIn {
            // User is logged in, show the main view controller
            let mainVC = ViewController.instance()
            navigationController.viewControllers = [LoginVC.instance()] // Set LoginVC as root
            navigationController.pushViewController(mainVC, animated: false) // Push the main VC
        } else {
            // User is not logged in, show the login view controller
            let loginVC = LoginVC.instance()
            navigationController.viewControllers = [loginVC] // Set LoginVC as root
        }
        
        //-----------------------//
        
        // Check if the user is logged in
//        if UserDefaultsManager.shared.isLoggedIn {
//            // User is logged in, show the main view controller
//            let mainVC = ViewController.instance()
//            navigationController.viewControllers = [LoginVC.instance()] // Set LoginVC as root
//            navigationController.pushViewController(mainVC, animated: false) // Push the main VC
//        } else {
//            // User is not logged in, show the login view controller
//            let loginVC = LoginVC.instance()
//            navigationController.viewControllers = [loginVC] // Set LoginVC as root
//        }
        
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }
}

protocol StoryboardInstantiable {
    static var storyboardName: String { get }
    static func instance() -> Self
}

extension StoryboardInstantiable where Self: UIViewController {
    static func instance() -> Self {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard
                .instantiateViewController(
                    withIdentifier:String(describing: Self.self)) as! Self
    }
}
