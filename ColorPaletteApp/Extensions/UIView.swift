import UIKit

public extension UIView {
    class func fromNibFile<T: UIView>() -> T {
        let bundle = Bundle(for: T.self)
        return bundle.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
    class func instantiateFromNib() -> Self {
        let view = UINib(nibName: String(describing:Self.self), bundle: Bundle(for: Self.self))
                    .instantiate(withOwner: self, options: nil).first as! Self
        return view
    }
}

public extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

extension UIView {
    @IBInspectable open var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

// MARK: - IBInspectable
public extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    var screenshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func fadeIn(duration: TimeInterval = 1,
                completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 1,
                 completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: completion)
    }
    
    func round(corners: UIRectCorner, with radius: CGFloat) {
        let mask = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        clipsToBounds = true
        let shape = CAShapeLayer()
        shape.path = mask.cgPath
        layer.mask = shape
    }
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                installShadow()
            }
        }
    }
    
    func installShadow() {
        layer.shadowRadius = 1
        layer.shadowColor = UIColor(red: 0.549, green: 0.608, blue: 0.647, alpha: 0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.masksToBounds = false
//        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
//                                                     y: bounds.maxY - layer.shadowRadius,
//                                                     width: bounds.width,
//                                                     height: layer.shadowRadius)).cgPath
        /*
        layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowOpacity = 0.45
        layer.masksToBounds = false
        layer.shadowRadius = 2
         */
    }

}

//
//public extension UIView {
//        func roundCorners(corners: UIRectCorner, radius: CGFloat) {
//            let path = UIBezierPath(roundedRect: bounds,
//                                    byRoundingCorners: corners,
//                                    cornerRadii: CGSize(width: radius, height: radius))
//            let mask = CAShapeLayer()
//            mask.path = path.cgPath
//            layer.mask = mask
//        }
//}

public extension UIWindow {
    func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        return top
    }
}

// MARK: - Contraints

public extension UIView {
    
    @discardableResult
    func fitToSuperView(insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        guard let parent = superview else {
            print(#function, ": Not added to sueprview!")
            return []
        }
        translatesAutoresizingMaskIntoConstraints = false
        var ins = insets
        if isRTL {
            ins.left = insets.right
            ins.right = insets.left
        }
        let constrs = [
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: ins.left),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: ins.right),
            topAnchor.constraint(equalTo: parent.topAnchor, constant: ins.top),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: ins.bottom)
        ]
        NSLayoutConstraint.activate(constrs)
        return constrs
    }
    
    @discardableResult
    func fillInto(_ parent: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)
        var ins = insets
        if isRTL {
            ins.left = insets.right
            ins.right = insets.left
        }
        let constrs = [
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: ins.left),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -ins.right),
            topAnchor.constraint(equalTo: parent.topAnchor, constant: ins.top),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -ins.bottom)
        ]
        NSLayoutConstraint.activate(constrs)
        return constrs
    }
    
    var isRTL:  Bool {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
    }
    
    @discardableResult
    func sizeConstraints(size: CGSize) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [widthAnchor.constraint(equalToConstant: size.width),heightAnchor.constraint(equalToConstant: size.height)]
        NSLayoutConstraint.activate(constraints)
        
        return constraints
    }
    
    @discardableResult
    func widthConstraint(width: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalToConstant: width)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func heightConstraint(height: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalToConstant: height)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func equalEdgesConstraints(_ view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        var ins = insets
        if isRTL {
            ins.left = insets.right
            ins.right = insets.left
        }
        let constraints = [
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ins.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ins.right),
            topAnchor.constraint(equalTo: view.topAnchor, constant: ins.top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: ins.bottom)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
    @discardableResult
    func equalLeadingTrailingConstraints(_ view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        var ins = insets
        if isRTL {
            ins.left = insets.right
            ins.right = insets.left
        }
        let constraints = [
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ins.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ins.right)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
    @discardableResult
    func equalTopBottomConstraints(_ view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
    @discardableResult
    func equalLeadingConstraints(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func equalTrailingConstraints(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func equalTopConstraints(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: view.topAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func equalBottomConstraints(_ view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func equalSizeConstraints(_ view: UIView) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            widthAnchor.constraint(equalTo: view.widthAnchor),
            heightAnchor.constraint(equalTo: view.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
    @discardableResult
    func equalWidthConstraint(_ view: UIView) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = widthAnchor.constraint(equalTo: view.widthAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func equalHeightConstraint(_ view: UIView) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = heightAnchor.constraint(equalTo: view.heightAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func equalCenterConstraints(_ view: UIView) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
    @discardableResult
    func equalCenterXConstraint(_ view: UIView) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerXAnchor.constraint(equalTo: view.centerXAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func equalCenterYConstraint(_ view: UIView) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = centerYAnchor.constraint(equalTo: view.centerYAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func placeAtLeftConstraint(of view: UIView) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = rightAnchor.constraint(equalTo: view.leftAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func placeAtRightConstraint(of view: UIView) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = leftAnchor.constraint(equalTo: view.rightAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func placeAtTopConstraint(of view: UIView) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = bottomAnchor.constraint(equalTo: view.topAnchor)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func placeAtBottomConstraint(of view: UIView, constant: CGFloat = 0) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = topAnchor.constraint(equalTo: view.bottomAnchor, constant: constant)
        constraint.isActive = true
        return constraint
    }
    
    func removeParentConstraints(parent: UIView) {
        for constraint in parent.constraints {
            if let first = constraint.firstItem as? UIView, first == self {
                parent.removeConstraint(constraint)
            }
            if let second = constraint.secondItem as? UIView, second == self {
                parent.removeConstraint(constraint)
            }
        }
    }
    
    func removeAllConstraints() {
        var _superview = self.superview
        
        while let superview = _superview {
            for constraint in superview.constraints {
                if let first = constraint.firstItem as? UIView, first == self {
                    superview.removeConstraint(constraint)
                }
                if let second = constraint.secondItem as? UIView, second == self {
                    superview.removeConstraint(constraint)
                }
            }
            _superview = superview.superview
        }
        
        self.removeConstraints(self.constraints)
        self.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func removeConstraintsFromAllEdges(){
        if let superview = superview {
            for constraint in superview.constraints{
                if let firstItem = constraint.firstItem, firstItem === self {
                    superview.removeConstraint(constraint)
                }
                
                if let secondItem = constraint.secondItem, secondItem === self {
                    superview.removeConstraint(constraint)
                }
            }
        }
    }
}

public extension UIView {
    func snapshotImage(bgColor: UIColor? = nil, insets: UIEdgeInsets = .zero) -> UIImage? {
        var viewRect = CGRect(origin: .zero, size: bounds.size)
        var imageRect = viewRect.inset(by: insets)
        
        viewRect.origin.x -= imageRect.origin.x
        viewRect.origin.y -= imageRect.origin.y
        imageRect.origin = .zero
        
        UIGraphicsBeginImageContextWithOptions(imageRect.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        if let context = UIGraphicsGetCurrentContext() {
            if let bg = bgColor {
                bg.setFill()
                context.fill(imageRect)
            }
            context.translateBy(x: viewRect.origin.x, y: viewRect.origin.y)
            layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        
        return nil
    }
    
    func addNibView(inBundle bundle: Bundle? = nil) -> UIView {
      let name = String(describing: type(of: self))
      let selfNib = UINib(nibName: name, bundle: bundle)
      guard let view = selfNib.instantiate(withOwner: self, options: nil).first
        as? UIView else { return UIView() }
      
      view.frame = bounds
      view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
      addSubview(view)
      return view
    }
}



//public extension UIView {
//    func superVC <T>() -> T? {
//        return traverseResponderChain()
//    }
//    
//    func traverseResponderChain<T>() -> T? {
//        let responder = next
//        if let type = responder as? T {
//            return type
//        } else if let vc = responder as? UIViewController {
//            return vc.traverseResponderChain()
//        } else if let view = responder as? UIView {
//            return view.traverseResponderChain()
//        } else {
//            return nil
//        }
//    }
//    
//    /// Search all superviews until a view with the condition is found.
//    ///
//    /// - Parameter predicate: predicate to evaluate on superviews.
//    func ancestorView(where predicate: (UIView?) -> Bool) -> UIView? {
//        if predicate(superview) {
//            return superview
//        }
//        return superview?.ancestorView(where: predicate)
//    }
//    
//    /// Search all superviews until a view with this class is found.
//    ///
//    /// - Parameter name: class of the view to search.
//    func ancestorView<T: UIView>(withClass _: T.Type) -> T? {
//        return ancestorView(where: { $0 is T }) as? T
//    }
//}

//public extension UIView {
//    func addDashedBorder() {
//        //Create a CAShapeLayer
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = UIColor.init(hex: "CCCCCC").cgColor
//        shapeLayer.lineWidth = 2
//        // passing an array with the values [2,3] sets a dash pattern that alternates between a 2-user-space-unit-long painted segment and a 3-user-space-unit-long unpainted segment
//        shapeLayer.lineDashPattern = [2,3]
//        
//        let path = CGMutablePath()
//        path.addLines(between: [CGPoint(x: 0, y: 0),
//                                CGPoint(x: self.frame.width, y: 0)])
//        shapeLayer.path = path
//        layer.addSublayer(shapeLayer)
//    }
//}

public extension UIView {
    func addShadow(ofColor color: UIColor,
                   radius: CGFloat,
                   offset: CGSize,
                   opacity: Float) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.masksToBounds = false
    }
    //
    //    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
    //        layer.masksToBounds = false
    //        layer.shadowOffset = offset
    //        layer.shadowColor = color.cgColor
    //        layer.shadowRadius = radius
    //        layer.shadowOpacity = opacity
    //
    //        let backgroundCGColor = backgroundColor?.cgColor
    //        backgroundColor = nil
    //        layer.backgroundColor =  backgroundCGColor
    //    }
    
    func removeShadow() {
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
    }
}

extension UIView {
    /// Shake directions of a view.
    ///
    /// - horizontal: Shake left and right.
    /// - vertical: Shake up and down.
    enum ShakeDirection {
        /// SwifterSwift: Shake left and right.
        case horizontal
        /// SwifterSwift: Shake up and down.
        case vertical
    }
    
    /// Angle units.
    ///
    /// - degrees: degrees.
    /// - radians: radians.
    enum AngleUnit {
        /// SwifterSwift: degrees.
        case degrees
        /// SwifterSwift: radians.
        case radians
    }
    
    /// Shake animations types.
    ///
    /// - linear: linear animation.
    /// - easeIn: easeIn animation.
    /// - easeOut: easeOut animation.
    /// - easeInOut: easeInOut animation.
    enum ShakeAnimationType {
        /// SwifterSwift: linear animation.
        case linear
        /// SwifterSwift: easeIn animation.
        case easeIn
        /// SwifterSwift: easeOut animation.
        case easeOut
        /// SwifterSwift: easeInOut animation.
        case easeInOut
    }
    /// Rotate view by angle on relative axis.
    ///
    /// - Parameters:
    ///   - angle: angle to rotate view by.
    ///   - type: type of the rotation angle.
    ///   - animated: set true to animate rotation (default is true).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func rotate(
        byAngle angle: CGFloat,
        ofType type: AngleUnit,
        animated: Bool = false,
        duration: TimeInterval = 1,
        completion: ((Bool) -> Void)? = nil) {
            let angleWithType = (type == .degrees) ? .pi * angle / 180.0 : angle
            let aDuration = animated ? duration : 0
            UIView.animate(withDuration: aDuration, delay: 0, options: .curveLinear,
                           animations: { () -> Void in
                self.transform = self.transform.rotated(by: angleWithType)
            }, completion: completion)
        }
    
    /// Rotate view to angle on fixed axis.
    ///
    /// - Parameters:
    ///   - angle: angle to rotate view to.
    ///   - type: type of the rotation angle.
    ///   - animated: set true to animate rotation (default is false).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func rotate(
        toAngle angle: CGFloat,
        ofType type: AngleUnit,
        animated: Bool = false,
        duration: TimeInterval = 1,
        completion: ((Bool) -> Void)? = nil) {
            let angleWithType = (type == .degrees) ? .pi * angle / 180.0 : angle
            let aDuration = animated ? duration : 0
            UIView.animate(withDuration: aDuration, animations: {
                self.transform = self.transform.concatenating(CGAffineTransform(rotationAngle: angleWithType))
            }, completion: completion)
        }
    
    /// Scale view by offset.
    ///
    /// - Parameters:
    ///   - offset: scale offset
    ///   - animated: set true to animate scaling (default is false).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func scale(
        by offset: CGPoint,
        animated: Bool = false,
        duration: TimeInterval = 1,
        completion: ((Bool) -> Void)? = nil) {
            if animated {
                UIView.animate(withDuration: duration, delay: 0,
                               options: .curveLinear, animations: { () -> Void in
                    self.transform = self.transform.scaledBy(x: offset.x, y: offset.y)
                }, completion: completion)
            } else {
                transform = transform.scaledBy(x: offset.x, y: offset.y)
                completion?(true)
            }
        }
    
    /// Shake view.
    ///
    /// - Parameters:
    ///   - direction: shake direction (horizontal or vertical), (default is .horizontal).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - animationType: shake animation type (default is .easeOut).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func shake(
        direction: ShakeDirection = .horizontal,
        duration: TimeInterval = 1,
        animationType: ShakeAnimationType = .easeOut,
        completion: (() -> Void)? = nil) {
            CATransaction.begin()
            let animation: CAKeyframeAnimation
            switch direction {
            case .horizontal:
                animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
            case .vertical:
                animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            }
            switch animationType {
            case .linear:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
            case .easeIn:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            case .easeOut:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            case .easeInOut:
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            }
            CATransaction.setCompletionBlock(completion)
            animation.duration = duration
            animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
            layer.add(animation, forKey: "shake")
            CATransaction.commit()
        }
}

public extension UIView {
    func changeAllBtn(enable: Bool) {
        for views in subviews {
            if let button = views as? UIButton {
                button.isEnabled = enable
                button.alpha = enable ? 1 : 0.5
            }
        }
    }
}

public extension UIView {
    func showActivity() {
        let backgroundView = UIView()
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width,
                                           height: self.bounds.height)
        backgroundView.backgroundColor = .clear
        backgroundView.tag = 475647
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.startAnimating()
        isUserInteractionEnabled = false
        
        backgroundView.addSubview(activityIndicator)
        addSubview(backgroundView)
        bringSubviewToFront(backgroundView)
    }

    func hideActivity() {
        if let background = viewWithTag(475647){
            background.removeFromSuperview()
        }
        isUserInteractionEnabled = true
    }
}


public extension UIView {
    var showTopShadowView: Bool {
        get{
            return layer.shadowOpacity > 0.0
        } set{
            if newValue == true{
                self.showTopShadow()
            }
        }
    }
    
    func showTopShadow() {
        layer.shadowRadius = 4
        layer.shadowColor = UIColor(red: 0.549,
                                    green: 0.608,
                                    blue: 0.647,
                                    alpha: 0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowOpacity = 1
        layer.masksToBounds = false
    }
}
