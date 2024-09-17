import UIKit


class FlowLayout: UICollectionViewFlowLayout {

    required init(itemSize: CGSize, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        super.init()

        self.itemSize = itemSize
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        sectionInsetReference = .fromSafeArea
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        guard scrollDirection == .vertical else { return layoutAttributes }

        // Filter attributes to compute only cell attributes
        let cellAttributes = layoutAttributes.filter({ $0.representedElementCategory == .cell })

        // Group cell attributes by row (cells with same vertical center) and loop on those groups
        for (_, attributes) in Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) * 10 }) {
            // Get the total width of the cells on the same row
            let cellsTotalWidth = attributes.reduce(CGFloat(0)) { (partialWidth, attribute) -> CGFloat in
                partialWidth + attribute.size.width
            }

            // Calculate the initial left inset
            let totalInset = collectionView!.safeAreaLayoutGuide.layoutFrame.width - cellsTotalWidth - sectionInset.left - sectionInset.right - minimumInteritemSpacing * CGFloat(attributes.count - 1)
            var leftInset = (totalInset / 2 * 10).rounded(.down) / 10 + sectionInset.left

            // Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
            for attribute in attributes {
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }

        return layoutAttributes
    }

}


//class PathaoFlowLayout: UICollectionViewFlowLayout {
//
//    enum Alignment: Int {
//        case justifiedEndingLeft
//        case left
//        case right
//        case centered
//        case justified
//        case justifiedEndingRight
//        case justifiedEndingCentered
//
//        static let `default`: Alignment = .justifiedEndingLeft
//        fileprivate static let justifiedWithEnding = [.justifiedEndingLeft, justifiedEndingRight, justifiedEndingCentered]
//    }
//
//    var alignment: Alignment = .default {
//        didSet { invalidateLayout() }
//    }
//
//    fileprivate func lineStart(startX: CGFloat, freeSpace: CGFloat, isLastLine: Bool) -> CGFloat {
//        var currentX: CGFloat = 0
//        switch alignment {
//        case .left, .justified:
//            currentX = startX
//        case .right:
//            currentX = startX + freeSpace
//        case .centered:
//            currentX = startX + freeSpace/2
//        case .justifiedEndingRight,
//             .justifiedEndingCentered:
//            currentX = startX
//            if isLastLine {
//                if alignment == .justifiedEndingRight {
//                    currentX += freeSpace
//                } else {
//                    currentX += freeSpace/2
//                }
//            }
//        default:
//            break
//        }
//        return currentX
//    }
//    
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        let attribs = super.layoutAttributesForElements(in: rect)
//        guard let attrs = attribs,
//            let collectionView = collectionView,
//            alignment != .justifiedEndingLeft // This is default flowLayout behavior
//        else { return attribs }
//
//        let totalWidth = collectionView.frame.width
//        let usableSpace = totalWidth - (
//            collectionView.contentInset.left
//            + collectionView.contentInset.right
//            + sectionInset.left
//            + sectionInset.right
//        )
//        let startX = collectionView.contentInset.left + sectionInset.left
//
//        let rows = Dictionary(grouping: attrs) { $0.frame.minY }
//        var newAttribs: [UICollectionViewLayoutAttributes] = []
//        var currentX: CGFloat = 0
//        for row in rows {
//            let itemsWidth = row.value.reduce(0) { $0 + $1.frame.width }
//            let spaceCount = CGFloat(row.value.count - 1)
//            let itemSpaces = spaceCount*minimumInteritemSpacing
//            let freeSpace = usableSpace - (itemsWidth + itemSpaces)
//
//            // Row will not be empty, so will never be in `else`
//            guard let section = row.value.first?.indexPath.section
//                else { continue }
//
//            let lastIndex = collectionView.numberOfItems(inSection: section) - 1
//            let lastIndexPath = IndexPath(item: lastIndex, section: section)
//            let isLastLine = row.value.contains(where: {$0.indexPath == lastIndexPath})
//
//            // Special Case: Justified.. with only one looong item in a row
//            if row.value.count == 1,
//                !isLastLine,
//                ![Alignment.left, .right, .centered].contains(alignment),
//                let attr = row.value.first {
//                newAttribs.append(attr)
//                continue
//            }
//
//            for item in row.value.enumerated() {
//                if item.offset == 0 {
//                    currentX = lineStart(startX: startX, freeSpace: freeSpace, isLastLine: isLastLine)
//                }
//
//                let updatedItem = item.element
//                updatedItem.frame.origin.x = currentX
//                if alignment == .justified
//                    || (!isLastLine && Alignment.justifiedWithEnding.contains(alignment)) {
//                    currentX += updatedItem.frame.width + freeSpace / spaceCount + minimumInteritemSpacing
//                } else {
//                    currentX += updatedItem.frame.width + minimumInteritemSpacing
//                }
//                newAttribs.append(updatedItem)
//            }
//        }
//        return newAttribs
//    }
//}
