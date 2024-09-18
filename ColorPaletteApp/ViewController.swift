import UIKit
import EFColorPicker

// MARK: - Enum for Create/Update Action
enum ColorActionType {
    case create
    case update
}

// MARK: - ViewController Class
class ViewController: UIViewController, StoryboardInstantiable {
    static var storyboardName: String = "Main"
    static let identifier: String = "ViewController"
    
    // MARK: - Outlets
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var createPaletteLabel: UILabel!
    @IBOutlet weak var colorCollectionView: AutoHeightCollectionView! {
        didSet {
            configureCollectionView()
        }
    }
    
    // MARK: - Properties
    private let networkManager: NetworkManager
    private var favoriteColors: [Color] = []
    var selectedIndexPath: IndexPath?
    var colorActionType: ColorActionType = .create
    private var currentColor: UIColor? {
        didSet {
            updateBackgroundColor()
        }
    }
    
    // MARK: - UI Elements
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
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSaveButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavoriteColors()
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    
    private func setupSaveButton() {
        saveButton.addTarget(self, 
                             action: #selector(saveColorPickerSelection),
                             for: .touchUpInside)
    }
    
    private func configureCollectionView() {
        colorCollectionView.register(UINib(nibName: ColorCell.id, bundle: nil), 
                                     forCellWithReuseIdentifier: ColorCell.id)
        colorCollectionView.register(UINib(nibName: AddColorCell.id, bundle: nil),
                                     forCellWithReuseIdentifier: AddColorCell.id)
        colorCollectionView.alwaysBounceVertical = false
        colorCollectionView.allowsMultipleSelection = false
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.collectionViewLayout = createCollectionViewLayout()
        colorCollectionView.reloadData()
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        return FlowLayout(itemSize: CGSize(width: 70, height: 70),
                          minimumInteritemSpacing: 8,
                          minimumLineSpacing: 8,
                          sectionInset: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
    }
    
    private func updateBackgroundColor() {
        DispatchQueue.main.async {
            self.view.backgroundColor = self.currentColor
        }
    }
    
    // MARK: - Favorite Colors Handling
    private func loadFavoriteColors() {
        DispatchQueue.global(qos: .userInitiated).async {
            let favoriteColors = ColorStorage.shared.getFavoriteColors()
            DispatchQueue.main.async {
                self.favoriteColors = favoriteColors
                self.colorCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - User Actions
    @IBAction func logoutButtonPressed(_ sender: Any) {
        PPHUD.show()
        handleLogout()
    }
    
    private func handleLogout() {
        //deleting token from key chain
        KeychainHelper.shared.deleteToken(for: UserDefaultsManager.shared.storedUsername)
        // setting storedUsername empty
        UserDefaultsManager.shared.storedUsername = ""
        navigationController?.popViewController(animated: true)
        PPHUD.dismiss()
    }
    
    // MARK: - Save Button Action
    @objc private func saveColorPickerSelection(_ sender: UIButton) {
        guard let selectedColor = currentColor else { return }
        
        switch colorActionType {
        case .create:
            createColor(color: selectedColor)
        case .update:
            if let indexPath = selectedIndexPath {
                updateColor(at: indexPath, with: selectedColor)
            }
        }
        view.backgroundColor = .systemBackground
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Create/Update/Delete Methods
    private func createColor(color: UIColor) {
        PPHUD.show()
        networkManager.create(color: color.asString()) { [weak self] color, error in
            guard let self = self else { return }
            if let newColor = color {
                PPHUD.dismiss()
                ColorStorage.shared.saveFavoriteColor(newColor)
                self.loadFavoriteColors()
            } else {
                PPHUD.dismiss()
                print("Failed to create color: \(error ?? "Unknown error")")
            }
        }
    }
    
    private func updateColor(at indexPath: IndexPath, 
                             with color: UIColor) {
        PPHUD.show()
        let colorId = favoriteColors[indexPath.item].id
        networkManager.updateColorForId(colorId, 
                                        color: color.asString()) { [weak self] color, error in
            guard let self = self else { return }
            if let updatedColor = color {
                PPHUD.dismiss()
                ColorStorage.shared.updateFavoriteColor(updatedColor)
                self.favoriteColors[indexPath.item] = updatedColor
                DispatchQueue.main.async {
                    self.colorCollectionView.reloadItems(at: [indexPath])
                }
            } else {
                PPHUD.dismiss()
                print("Failed to update color: \(error ?? "Unknown error")")
            }
        }
    }
    
    private func deleteColor(at indexPath: IndexPath) {
        PPHUD.show()
        let color = favoriteColors[indexPath.item]
        networkManager.deleteColorWithId(color.id) { [weak self] success, error in
            
            guard let self = self else { return }
            if success {
                PPHUD.dismiss()
                ColorStorage.shared.removeFavoriteColor(color)
                DispatchQueue.main.async {
                    self.loadFavoriteColors()
                }
            } else {
                PPHUD.dismiss()
                print("Failed to delete color: \(error ?? "Unknown error")")
            }
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension ViewController: UICollectionViewDelegate, 
                          UICollectionViewDataSource,
                          UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, 
                        numberOfItemsInSection section: Int) -> Int {
        createPaletteLabel.isHidden = !favoriteColors.isEmpty
        return favoriteColors.count + 1 // +1 for "Add" button
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < favoriteColors.count {
            return configureColorCell(at: indexPath)
        } else {
            return configureAddCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        didSelectItemAt indexPath: IndexPath) {
        showActionSheet(for: indexPath)
    }
    
    private func configureColorCell(at indexPath: IndexPath) -> ColorCell {
        guard let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.id,
                                                                 for: indexPath) as? ColorCell else {
            return ColorCell()
        }
        let color = favoriteColors[indexPath.item]
        cell.colorView.backgroundColor = UIColor.fromString(string: color.data)
        return cell
    }
    
    private func configureAddCell() -> AddColorCell {
        guard let cell = colorCollectionView.dequeueReusableCell(withReuseIdentifier: AddColorCell.id,
                                                                 for: IndexPath(item: favoriteColors.count,
                                                                                section: 0)) as? AddColorCell else {
            return AddColorCell()
        }
        cell.addColorButtonAction = { [weak self] in
            self?.presentColorPicker(for: nil, 
                                     actionType: .create)
        }
        return cell
    }
    
    private func showActionSheet(for indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Color Options",
                                                message: "What do you want to do with this color?",
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Update", 
                                                style: .default) { [weak self] _ in
            self?.presentColorPicker(for: indexPath, actionType: .update)
        })
        alertController.addAction(UIAlertAction(title: "Delete",
                                                style: .destructive) { [weak self] _ in
            self?.deleteColor(at: indexPath)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", 
                                                style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Color Picker Handling
extension ViewController: EFColorSelectionViewControllerDelegate, 
                            UIViewControllerTransitioningDelegate {
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController, 
                             didChangeColor color: UIColor) {
        currentColor = color
    }
    
    func presentationController(forPresented presented: UIViewController, 
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented,
                                      presenting: presenting)
    }
    
    func presentColorPicker(for indexPath: IndexPath?, actionType: ColorActionType) {
        let colorSelectionVC = EFColorSelectionViewController()
        colorSelectionVC.isColorTextFieldHidden = true
        colorSelectionVC.setMode(mode: .all)
        colorSelectionVC.view.addSubview(saveButton)
        setupSaveButtonConstraints(for: colorSelectionVC)
        colorSelectionVC.modalPresentationStyle = .custom
        colorSelectionVC.transitioningDelegate = self
        colorSelectionVC.delegate = self
        colorSelectionVC.color = currentColor ?? .white
        
        self.selectedIndexPath = indexPath
        self.colorActionType = actionType
        
        present(colorSelectionVC, animated: true, completion: nil)
    }
    
    private func setupSaveButtonConstraints(for colorSelectionVC: EFColorSelectionViewController) {
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: colorSelectionVC.view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: colorSelectionVC.view.trailingAnchor, constant: -16),
            saveButton.equalCenterYConstraint(colorSelectionVC.view),
            saveButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}
