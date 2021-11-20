//
//  ConveyorBeltViewController.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

protocol ConveyorBeltViewControllerDelegate {
    func didSelectItem(conveyorBeltViewController: ConveyorBeltViewController, forgedItem: ForgedItem, cell: ConveyorCollectionViewCell)
}

@objc(ConveyorBeltViewController)
class ConveyorBeltViewController: UIViewController {
    
    private static let cellReuseIdentifier = "conveyorItemCell"
    
    private var collectionView: UICollectionView!
    private var conveyorBackgroundImageView: UIImageView!
    
    private var newEmptyItem: ForgedItem {
        return ForgedItem(item: .undefined, recipe: Recipe(itemA: .undefined, itemB: .undefined))
    }
    
    // Returns enough empty items to comfortably fill the conveyor at its widest.
    private lazy var emptyForgedItems: [ForgedItem] = {
        var emptyItems = [ForgedItem]()
        for _ in 0..<32 {
            emptyItems.append(newEmptyItem)
        }
        return emptyItems
    }()
    
    private var forgedItemCellSize = ConveyorCollectionViewCell().intrinsicContentSize
    private var forgedItemCellInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    // The index offset from the center for the cell on which an item is dropped onto the conveyor.
    private var dropItemIndexOffset = 1

    var forgedItems = [ForgedItem]()

    var isEmpty: Bool {
        return forgedItems.filter( { $0.item != .undefined } ).count == 0
    }
    
    var axElements = [UIAccessibilityElement]()
    
    override var accessibilityElements: [Any]? {
        get {
            guard axElements.isEmpty, let view = view else { return axElements }

            let accessibilityElement = UIAccessibilityElement(accessibilityContainer: view)
            accessibilityElement.accessibilityLabel = "conveyor"
            let conveyorFrame = CGRect(x: 0, y: view.bounds.height / 2, width: view.bounds.width, height: view.bounds.height)
            accessibilityElement.accessibilityFrame = view.convert(conveyorFrame, to: nil)
            axElements.append(accessibilityElement)
            return axElements
        }
        set { }
    }
    
    var delegate: ConveyorBeltViewControllerDelegate?
    
    // MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = forgedItemCellSize
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.sectionInset = forgedItemCellInsets
        
        conveyorBackgroundImageView = UIImageView()
        if let image = UIImage(named: "ConveyorBeltBackground") {
            conveyorBackgroundImageView.image = image.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        view.addSubview(conveyorBackgroundImageView)

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ConveyorCollectionViewCell.self,
                                          forCellWithReuseIdentifier: ConveyorBeltViewController.cellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        isAccessibilityElement = false
        
        clear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        collectionView.frame = view.bounds
        conveyorBackgroundImageView.frame = CGRect(x: collectionView.frame.origin.x,
                                                   y: collectionView.frame.origin.y + collectionView.bounds.height / 2,
                                                   width: collectionView.bounds.width, height: collectionView.bounds.height / 2)
        axElements.removeAll()
        
        DispatchQueue.main.async {
            self.scrollToLeftMostAvailableEmptyCell(animated: false)
        }
    }

    // MARK: Custom methods
    
    // Advances the conveyor to the right by inserting a new empty cell in the leftmost position.
    func advanceForNextItem(completion: (() -> Void)? = nil) {
        forgedItems.insert(newEmptyItem, at: 0)
        UIView.animate(withDuration: 0.25, animations: {
            self.collectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            self.scrollToLeftMostAvailableEmptyCell(animated: false)
        }, completion: { _ in
            completion?()
        })
    }
    
    // Adds a forged item to the conveyor.
    func addItem(forgedItem: ForgedItem) -> ThingView? {
        guard let indexPath = indexPathOfLeftMostAvailableEmptyCell(),
            let cell = collectionView.cellForItem(at: indexPath) as? ConveyorCollectionViewCell else { return nil }
        self.forgedItems[indexPath.item] = forgedItem
        cell.forgedItem = forgedItem
        return cell.thingView
    }
    
    func clear() {
        // Prime the conveyor with emough empty items to fill it horizontally.
        forgedItems = emptyForgedItems
        collectionView.reloadData()
        let lastIndexPath = IndexPath(item: forgedItems.count - 1, section: 0)
        collectionView.scrollToItem(at: lastIndexPath, at: .right, animated: false)
    }
    
    // Returns the center point (relative to the conveyor) of the next available empty cell into which a forged item can be placed.
    func centerOfLeftMostAvailableEmptyCell() -> CGPoint {
        var center = CGPoint(x: forgedItemCellSize.width / 2, y: collectionView.bounds.height / 2) // Default in center of first visible cell.
        guard let indexPath = indexPathOfLeftMostAvailableEmptyCell() else { return center }
        guard let attributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else { return center }
        center = attributes.center
        center.x -= collectionView.contentOffset.x
        return center
    }
    
    // Returns the index path of the next available empty cell into which a forged item can be placed.
    // This is the index path of the empty cell to the left of the last forged cell or,
    // if the collection view is empty, the center cell of the pre-populated empty cells.
    func indexPathOfLeftMostAvailableEmptyCell() -> IndexPath? {
        if isEmpty {
            return IndexPath(item: (emptyForgedItems.count / 2) - 1, section: 0)
        } else {
            for (index, forgedItem) in forgedItems.enumerated() {
                if !forgedItem.item.isEmpty {
                    if index > 0 {
                        return IndexPath(item: index - 1, section: 0)
                    }
                    break
                }
            }
        }
        return nil
    }
    
    func indexPathOfRightMostOccupiedCell() -> IndexPath? {
        var index = forgedItems.count - 1
        if !isEmpty {
            for forgedItem in forgedItems.reversed() {
                if !forgedItem.item.isEmpty { break }
                index -= 1
            }
        }
        return IndexPath(item: index, section: 0)
    }
    
    func scrollToLeftMostAvailableEmptyCell(animated: Bool) {
        guard var indexPath = indexPathOfLeftMostAvailableEmptyCell() else { return }
        indexPath.row -= dropItemIndexOffset
        collectionView.scrollToItem(at: indexPath, at: .left, animated: animated)
    }
}

// MARK: UICollectionViewDelegate
extension ConveyorBeltViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < forgedItems.count else { return }
        let forgedItem = forgedItems[indexPath.item]
        let cell = collectionView.cellForItem(at: indexPath) as! ConveyorCollectionViewCell
        delegate?.didSelectItem(conveyorBeltViewController: self, forgedItem: forgedItem, cell: cell)
    }
}

// MARK: UICollectionViewDataSource
extension ConveyorBeltViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forgedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConveyorBeltViewController.cellReuseIdentifier, for: indexPath as IndexPath) as! ConveyorCollectionViewCell
        
        if cell.forgedItem?.item != forgedItems[indexPath.item].item {
            cell.forgedItem = forgedItems[indexPath.item]
        }
        return cell
    }
    
    func collectionView(collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectinView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: UIScrollViewDelegate
extension ConveyorBeltViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if let indexPathLeftMost = indexPathOfLeftMostAvailableEmptyCell(),
            let indexPathRightMost = indexPathOfRightMostOccupiedCell()
        {
            // Limit scrollable region to keep one forged item in view at either extreme.
            var newContentOffset = scrollView.contentOffset
            let insetItems = 0
            let leftOffsetX = CGFloat(indexPathLeftMost.item + 2 - insetItems) * forgedItemCellSize.width
            let rightOffsetX = CGFloat(indexPathRightMost.item + insetItems) * forgedItemCellSize.width
            let minOffsetX = leftOffsetX - scrollView.bounds.width
            let maxOffsetX = rightOffsetX
            newContentOffset.x = max(min(scrollView.contentOffset.x, maxOffsetX), minOffsetX)
            scrollView.contentOffset = newContentOffset
        }
    }
}
