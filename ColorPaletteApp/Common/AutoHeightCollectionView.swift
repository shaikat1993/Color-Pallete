import UIKit


public class AutoHeightCollectionView: UICollectionView, AutoHeightScrollProtocol {
    public var maxSize: CGSize = .zero
    
    override public var contentSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    public override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    override public var intrinsicContentSize: CGSize {
        return calculateIntrinsicContentSize()
    }
}
