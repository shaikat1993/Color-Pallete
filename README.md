# Color-Pallete
This is the private repo to work with Color-Palette iOS APP

Explanation:

* SceneDelegate:
 => UINavigationController Extension -> To provide a convenient method to pop to a specific view controller type within the navigation stack.

 => SceneDelegate: To manage the initial setup and authentication flow of the app.
    * Checks if the user is logged in by retrieving the username from UserDefaults and the token from the Keychain.
    * Based on the authentication state, sets the root view controller to either LoginVC or ViewController.
    * Uses a UINavigationController to manage navigation.

 => StoryboardInstantiable Protocol -> To simplify the instantiation of view controllers from storyboards.

* UserDefaultsManager: Useful for non-sensitive, user-specific settings or preferences. 

* KeychainHelper: Essential for securely storing sensitive data like tokens.

* ColorStorage: Needed for managing and persisting color data locally.

* LoginVC: It manages the login process, including user input validation, network login requests, and UI updates.

* Viewcontroller: 
    => It displays a collection view of favorite colors and allows users to create, update, or delete colors. 
    => It also provides functionality for logging out and saving color palettes.

* Additional Third party library:
    => SVProgressHUD (Creating a wrapper called PPHUD for loader)
