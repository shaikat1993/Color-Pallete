import UIKit
import EFColorPicker

class ViewController: UIViewController,
                      StoryboardInstantiable {
    static var storyboardName: String = "Main"
    static let identifier: String = "ViewController"

    //@IBOutlet weak var colorView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var createPaletteLabel: UILabel!
    
    // for testing
//    var counter = 1 {
//        didSet {
//            colorCollectionView.reloadData()
//        }
//    }
    
    
    private var favoriteColors:[String] = []

    
    @IBOutlet weak var colorCollectionView: AutoHeightCollectionView! {
        didSet {
            configureCollectionView()
        }
    }
    
    private let saveButton: UIButton = {
           let button = UIButton(type: .system)
           button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
           button.setTitle("SAVE MY PALETTE", for: .normal)
           button.setTitleColor(.black, for: .normal)
           button.backgroundColor = .clear
           button.layer.cornerRadius = 8
           button.translatesAutoresizingMaskIntoConstraints = false
           return button
       }()

    let networkManager = NetworkManager()

    private var currentColor: UIColor? {
        didSet {
            DispatchQueue.main.async {
                //self.colorView.backgroundColor = self.currentColor
                self.view.backgroundColor = self.currentColor
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSaveButton()
        loadFavoriteColors()
        //fetchSavedColor()
        
        // change later// comment for testing
//        if TokenHandler.currentToken() == nil {
//            networkManager.login { token, error in
//                if let token = token {
//                    TokenHandler.save(token)
//                }
//            }
//        }

        let savedColorId = UserDefaults.standard.integer(forKey: "saved_color_id")
        guard savedColorId != 0 else { return }

        networkManager.getColorWithId(savedColorId) { color, error in
            // print(color)
            // print(error)

            guard let color = color else  { return }
            let colorData = self.networkManager.parseColorData(color.data)
            self.currentColor = UIColor(rgba: colorData ?? [])
            
            print(self.currentColor)
            //UIColor(rgba: color.data)
            //UIColor.fromString(string: color.data)
        }
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    
    private func setupSaveButton() {
        saveButton.addTarget(self,
                             action: #selector(saveBtnPressed),
                             for: .touchUpInside)
    }
    
    private func configureCollectionView() {
           let cellNib = UINib(nibName: ColorCell.id, bundle: nil)
           colorCollectionView.register(cellNib, forCellWithReuseIdentifier: ColorCell.id)
           
           let addCellNib = UINib(nibName: AddColorCell.id, bundle: nil)
           colorCollectionView.register(addCellNib, forCellWithReuseIdentifier: AddColorCell.id)

           colorCollectionView.alwaysBounceVertical = false
           colorCollectionView.allowsMultipleSelection = false
           colorCollectionView.dataSource = self
           colorCollectionView.delegate = self
           
           let columnLayout = FlowLayout(itemSize: CGSize(width: 50, height: 50),
                                          minimumInteritemSpacing: 8,
                                          minimumLineSpacing: 8,
                                          sectionInset: UIEdgeInsets(top: 8, left: 8,
                                                                     bottom: 8, right: 8))
           
           colorCollectionView.collectionViewLayout = columnLayout
           colorCollectionView.contentInsetAdjustmentBehavior = .always
           colorCollectionView.showsVerticalScrollIndicator = false
           colorCollectionView.showsHorizontalScrollIndicator = false
           
           colorCollectionView.reloadData()
       }
    
    private func loadFavoriteColors() {
        favoriteColors = ColorStorage.shared.getFavoriteColors()
//         if let savedColorsData = UserDefaults.standard.array(forKey:"favoriteColors") as? [Data] {
//             favoriteColors = savedColorsData.compactMap { try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData($0) as? UIColor }
//         }
         colorCollectionView.reloadData()
     }

//    @IBAction func pickColorButtonTapped(_ sender: UIButton) {
//        let colorSelectionVC = EFColorSelectionViewController()
//        
//        colorSelectionVC.isColorTextFieldHidden = true
//        colorSelectionVC.setMode(mode: .all)
//        
//        colorSelectionVC.view.addSubview(saveButton)
//        
//        NSLayoutConstraint.activate([
//            //saveButton.topAnchor.constraint(equalTo: colorSelectionVC.view.bottomAnchor, constant: -120),
//            saveButton.leadingAnchor.constraint(equalTo: colorSelectionVC.view.leadingAnchor, constant: 16),
//            saveButton.trailingAnchor.constraint(equalTo: colorSelectionVC.view.trailingAnchor, constant: -16),
//            saveButton.equalCenterYConstraint(colorSelectionVC.view),
//            //saveButton.bottomAnchor.constraint(equalTo: colorSelectionVC.view.bottomAnchor, constant: -232),
//            saveButton.heightAnchor.constraint(equalToConstant: 32)
//            ])
//        
//        
//       
//        colorSelectionVC.modalPresentationStyle = UIModalPresentationStyle.custom
//        colorSelectionVC.transitioningDelegate = self
//        
////        if #available(iOS 15.0, *) {
////            if let sheet = colorSelectionVC.sheetPresentationController {
////                sheet.detents = [.medium()]
////                sheet.preferredCornerRadius = 16
////            }
////        } else {
////            // Fallback on earlier versions
////            colorSelectionVC.modalPresentationStyle = UIModalPresentationStyle.custom
////            colorSelectionVC.transitioningDelegate = self
////
////        }
//        colorSelectionVC.delegate = self
//        colorSelectionVC.color = currentColor ?? .white
//
//        present(colorSelectionVC, animated: true, completion: nil)
//    }
    
    // for saving the color to the array
    
    func saveFavoriteColor(_ color: UIColor) {
        // Convert UIColor to Data for storage in UserDefaults or Core Data.
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding:false) {

             var savedColorsArray:[Data]

             // Load existing colors or create new array.
             if var existingColorsArray = UserDefaults.standard.array(forKey:"favoriteColors") as? [Data]{
                  existingColorsArray.append(colorData)
                  savedColorsArray=existingColorsArray
             }else{
                  savedColorsArray=[colorData]
             }

             UserDefaults.standard.set(savedColorsArray ,forKey:"favoriteColors")
         }
    }

    @IBAction func saveColorButtonTapped(_ sender: UIButton) {
        guard let currentColor = currentColor else { return }
        networkManager.create(color: currentColor.asString()) { color, error in
            print(color)
            // print(error)
            guard let color = color else  { return }
            UserDefaults.standard.set(color.id, forKey: "saved_color_id")
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        UserDefaultsManager.shared.isLoggedIn = false
        let username = UserDefaultsManager.shared.storedUsername
        
        // Delete token from Keychain
        KeychainHelper.shared.deleteToken(for: username)
        UserDefaultsManager.shared.storedUsername = ""
        poptoRootVC()
    }
    
    func poptoRootVC() {
        // Pop back to the login view controller
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveBtnPressed() {
        // Dismiss the modal view controller
        
        guard let currentColor = currentColor else { return }
        networkManager.create(color: currentColor.asString()) { color, error in
            print(color)
            // print(error)
            guard let color = color else  { return }
            UserDefaults.standard.set(color.id, forKey: "saved_color_id")
        }
        ColorStorage.shared.saveFavoriteColor(currentColor.asString())
        loadFavoriteColors()
        self.view.backgroundColor = .systemBackground
        
        
       
//        networkManager.create(color: currentColor?.asString() ?? "") { [weak self] color, error in
//            
//            
//            if let error = error {
//                print("Error saving color: \(error)") // Improved error handling
//                return
//            }
//            
//            guard let color = color else {
//                print("Color not received in response")
//                return
//            }
//            
//            UserDefaults.standard.set(color.id, forKey: "saved_color_id")
//            
////
////            print(color)
////            // print(error)
////            guard let color = color else  { return }
////            UserDefaults.standard.set(color.id, forKey: "saved_color_id")
////            self?.dismiss(animated: true, completion: nil)
//        }
//        
//       // self.counter+=1
//        DispatchQueue.main.async {
//            self.networkManager.create(color: self.currentColor?.asString() ?? "") { [weak self] color, error in
//                
//                
//                if let error = error {
//                    print("Error saving color: \(error)") // Improved error handling
//                    return
//                }
//                
//                guard let color = color else {
//                    print("Color not received in response")
//                    return
//                }
//                
//                UserDefaults.standard.set(color.id, forKey: "saved_color_id")
//                
//                print(color.id)
//                
//    //
//    //            print(color)
//    //            // print(error)
//    //            guard let color = color else  { return }
//    //            UserDefaults.standard.set(color.id, forKey: "saved_color_id")
//    //            self?.dismiss(animated: true, completion: nil)
//            }
//        }
        self.dismiss(animated: true, completion: nil)
        self.colorCollectionView.reloadData()
        
        
    }
}


extension ViewController: UICollectionViewDelegate,
                          UICollectionViewDataSource,
                          UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        self.createPaletteLabel.isHidden = (favoriteColors.count != 0)
        // Always return the number of favorite colors + 1 for the "Add" button
        return favoriteColors.count + 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        if indexPath.item < colors.count {
//                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorBoxCellIdentifier, for: indexPath) as! ColorBoxCell
//                        cell.backgroundColor = colors[indexPath.item]
//                        return cell
//                    } else {
//                        // Last cell is the "Add" button
//                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorBoxCellIdentifier, for: indexPath) as! ColorBoxCell
//                        cell.backgroundColor = .gray // Set a default color for the "Add" button
//                        return cell
//                    }
        
        
        if indexPath.item < (favoriteColors.count){
            guard let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.id,
                                                                     for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
                
            }
            
            colorCell.colorView.backgroundColor = UIColor.fromString(string: favoriteColors[indexPath.item])
            //hintLabel.text = hintArray[indexPath.row]
            return colorCell
        } else {
            // Last cell is the "Add" button
            guard let addCell = collectionView.dequeueReusableCell(withReuseIdentifier: AddColorCell.id,
                                                                for: indexPath) as? AddColorCell else {
                                                                    return UICollectionViewCell()
               
            }
            addCell.addColorButtonAction = { [weak self] in
                self?.presentColorPicker()
            }
            addCell.contentView.backgroundColor = .red
            //hintLabel.text = hintArray[indexPath.row]
            return addCell
        }
        
//        guard let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.id,
//                                                            for: indexPath) as? ColorCell else {
//                                                                return UICollectionViewCell()
//           
//        }
//        colorCell.contentView.backgroundColor = .red
//        //hintLabel.text = hintArray[indexPath.row]
//        return colorCell
    }
    
//    func collectionView(_ collectionView: UICollectionView, 
//                        didSelectItemAt indexPath: IndexPath) {
//        if (indexPath.row) == (counter - 1) {
//            
//        }
//    }
    
    
    func presentColorPicker() {
        let colorSelectionVC = EFColorSelectionViewController()
        
        colorSelectionVC.isColorTextFieldHidden = true
        colorSelectionVC.setMode(mode: .all)
        
        colorSelectionVC.view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            //saveButton.topAnchor.constraint(equalTo: colorSelectionVC.view.bottomAnchor, constant: -120),
            saveButton.leadingAnchor.constraint(equalTo: colorSelectionVC.view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: colorSelectionVC.view.trailingAnchor, constant: -16),
            saveButton.equalCenterYConstraint(colorSelectionVC.view),
            //saveButton.bottomAnchor.constraint(equalTo: colorSelectionVC.view.bottomAnchor, constant: -232),
            saveButton.heightAnchor.constraint(equalToConstant: 32)
            ])
        colorSelectionVC.modalPresentationStyle = UIModalPresentationStyle.custom
        colorSelectionVC.transitioningDelegate = self
        
        colorSelectionVC.delegate = self
        colorSelectionVC.color = currentColor ?? .white

        present(colorSelectionVC, animated: true, completion: nil)
    }
}


// MARK: - EFColorSelectionViewControllerDelegate
extension ViewController: EFColorSelectionViewControllerDelegate {
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController,
                             didChangeColor color: UIColor) {
        currentColor = color
    }
}

extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented,
                               presenting: presenting)
    }
}
