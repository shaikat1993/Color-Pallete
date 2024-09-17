import UIKit

extension UIColor {
    
    func asString() -> String {
        let components = cgColor.components
        return "[\(components![0]), \(components![1]), \(components![2]), \(components![3])]"
    }
    
    static func fromString(string: String) -> UIColor {
        let component =  string.replacingOccurrences(of: "[", with: "")
        let componentsString = component.replacingOccurrences(of: "]", with: "")
        let components = componentsString.components(separatedBy: ", ")
        return UIColor(red: CGFloat((components[0] as NSString).floatValue),
                       green: CGFloat((components[1] as NSString).floatValue),
                       blue: CGFloat((components[2] as NSString).floatValue),
                       alpha: CGFloat((components[3] as NSString).floatValue))
}
    
}

extension UIColor {
    convenience init?(rgba: [CGFloat]) {
        guard rgba.count == 4 else { return nil }
        self.init(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: rgba[3])
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0...1),
                       green: CGFloat.random(in: 0...1),
                       blue: CGFloat.random(in: 0...1),
                       alpha: 1.0)
    }
}
