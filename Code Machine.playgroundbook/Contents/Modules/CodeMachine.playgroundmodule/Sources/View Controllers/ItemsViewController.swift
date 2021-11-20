//
//  ItemsViewController.swift
//  
//  Copyright © 2016-2019 Apple Inc. All rights reserved.
//

import UIKit

protocol ItemsViewControllerDelegate {
    
    func didSelectItem(itemsViewController: ItemsViewController, thingView: ThingView, item: Thing)
}

@objc(ItemsViewController)
class ItemsViewController: UIViewController {
    
    private static let cellReuseIdentifier = "itemCell"
    
    private var collectionView: UICollectionView!
    
    var items = [[Thing]]() {
        didSet {
            guard collectionView != nil else { return }
            collectionView.reloadData()
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // Direction in which each section of cells is laid out.
    var orientation = NSLayoutConstraint.Axis.vertical
    
    var delegate: ItemsViewControllerDelegate?
    
    private var itemCellSize = ThingView().intrinsicContentSize
    private var itemCellInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
          
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = (orientation == .vertical) ? .horizontal : .vertical
        layout.itemSize = itemCellSize
        layout.sectionInset = itemCellInsets
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = (orientation == .vertical) ? 8 : 8
      
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .hocIngredientsPanelSkyBlue
        collectionView.layer.cornerRadius = 14
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        collectionView.register(ThingCollectionViewCell.self,
                                          forCellWithReuseIdentifier: ItemsViewController.cellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        collectionView.frame = CGRect(origin: CGPoint.zero, size: collectionViewSize)
        collectionView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    private var collectionViewSize: CGSize {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
        
        let n = items.map{ $0.count }.max() ?? 1
        
        let contentInsets = collectionView.contentInset
        
        // Vertical layout.
        var height = (itemCellSize.height * CGFloat(n)) + (CGFloat(n - 1) * layout.minimumInteritemSpacing) + itemCellInsets.top + itemCellInsets.bottom + contentInsets.top + contentInsets.bottom
        var width = (itemCellSize.width * CGFloat(items.count)) + (CGFloat(items.count - 1) * layout.minimumLineSpacing) + itemCellInsets.left + itemCellInsets.right + contentInsets.left + contentInsets.right
        
        // Horizontal layout.
        if orientation == NSLayoutConstraint.Axis.horizontal {
            width = (itemCellSize.width * CGFloat(n)) + (CGFloat(n - 1) * layout.minimumInteritemSpacing) + itemCellInsets.left + itemCellInsets.right + contentInsets.left + contentInsets.right
            height = (itemCellSize.width * CGFloat(items.count)) + (CGFloat(items.count - 1) * layout.minimumLineSpacing) + itemCellInsets.top + itemCellInsets.bottom + contentInsets.top + contentInsets.bottom
        }
        
        return CGSize(width: width, height: height)
    }
    
    override var preferredContentSize: CGSize {
        get {
            var size = collectionViewSize
            size.width += view.layoutMargins.left + view.layoutMargins.right
            size.height += view.layoutMargins.top + view.layoutMargins.bottom
            return size
        }
        set { super.preferredContentSize = newValue }
    }
    
    // MARK: Custom methods
    
    func updateItemStatus() {
        for (sectionIndex, section) in items.enumerated() {
            for (itemIndex, _) in section.enumerated() {
                let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                if let cell = collectionView.cellForItem(at: indexPath) as? ThingCollectionViewCell {
                    cell.thingView.update()
                }
            }
        }
    }
    
    func cellFor(item: Thing) -> ThingCollectionViewCell? {
        for (sectionIndex, section) in items.enumerated() {
            for (itemIndex, collectionItem) in section.enumerated() {
                if item == collectionItem {
                    let indexPath = IndexPath(item: itemIndex, section: sectionIndex)
                    if let cell = collectionView.cellForItem(at: indexPath) as? ThingCollectionViewCell {
                        return cell
                    }
                }
            }
        }
        return nil
    }
    
    func getPosition(of cell: ThingCollectionViewCell, relativeTo view: UIView?) -> CGPoint? {
        return collectionView.convert(cell.center, to: view)
    }
}

extension ItemsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        var insets = itemCellInsets
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return insets }
        
        let n = items[section].count

        // Center items within column or row.
        if orientation == NSLayoutConstraint.Axis.vertical {
            let cellsTotalHeight = (itemCellSize.height * CGFloat(n)) + (CGFloat(n - 1) * layout.minimumInteritemSpacing)
            let inset = (collectionView.bounds.size.height - collectionView.contentInset.top - collectionView.contentInset.bottom - cellsTotalHeight) / 2
            insets.top += inset
            insets.bottom += inset
            if section > 0 {
                insets.left += layout.minimumInteritemSpacing
            }
        } else if orientation == NSLayoutConstraint.Axis.horizontal {
            let cellsTotalWidth = (itemCellSize.width * CGFloat(n)) + (CGFloat(n - 1) * layout.minimumInteritemSpacing)
            let leftInset = (collectionView.bounds.size.width - collectionView.contentInset.left - collectionView.contentInset.right - cellsTotalWidth) / 2
            insets.left += leftInset
            if section > 0 {
                insets.top += layout.minimumInteritemSpacing
            }
        }
        return insets
    }
}

// MARK: UICollectionViewDelegate
extension ItemsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section < items.count, indexPath.item < items[indexPath.section].count else { return }
        guard let cell = collectionView.cellForItem(at: indexPath) as? ThingCollectionViewCell else { return }

        delegate?.didSelectItem(itemsViewController: self, thingView: cell.thingView, item: cell.thingView.item)
    }
}

// MARK: UICollectionViewDataSource
extension ItemsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < items.count else { return 0 }
        return items[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemsViewController.cellReuseIdentifier, for: indexPath as IndexPath) as! ThingCollectionViewCell
        
        cell.thing = items[indexPath.section][indexPath.item]
        cell.thingView.isTransparent = false

        return cell
    }
}
