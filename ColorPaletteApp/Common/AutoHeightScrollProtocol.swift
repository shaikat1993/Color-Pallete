import UIKit

public protocol AutoHeightScrollProtocol {
    var maxSize: CGSize {get set}
}

extension AutoHeightScrollProtocol where Self:UIScrollView {
    func calculateIntrinsicContentSize() -> CGSize {
        var size = contentSize
       
        if maxSize.width > 0 && size.width > maxSize.width {
            size.width = maxSize.width
        }
        if maxSize.height > 0 && size.height > maxSize.height {
            size.height = maxSize.height
        }
        return size
    }
}
