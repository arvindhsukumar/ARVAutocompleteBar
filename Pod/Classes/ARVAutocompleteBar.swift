//
//  ARVAutocompleteBar.swift
//  Pods
//
//  Created by Arvindh Sukumar on 05/07/15.
//
//

import UIKit

@objc protocol ARVAutocompleteDelegate {
    
    func promptForAutocompleteType(type:String)->String?
    optional func noResultsErrorMessageForAutocompleteType(type:String)->String?
    func resultsForAutocompleteType(type:String,query:String)->[String]
    func autocompleteBarDidSelectResult(result:String)
}

class ARVAutocompleteBar: UIToolbar, UICollectionViewDataSource, UICollectionViewDelegate {

    weak var autocompleteDelegate: ARVAutocompleteDelegate?
    private var promptLabel: UILabel!
    private var noResultsLabel: UILabel!
    private var collectionView:UICollectionView!
    private var results:[String] = []
    private let defaultErrorMessage = "No Results found"
    
    var isActive: Bool = false {
        didSet {

        }
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    private func commonSetup(){
        promptLabel = UILabel(frame: self.bounds)
        promptLabel.backgroundColor = self.barTintColor
        promptLabel.textColor = self.tintColor
        promptLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        noResultsLabel = UILabel(frame: self.bounds)
        noResultsLabel.backgroundColor = self.barTintColor
        noResultsLabel.textColor = self.tintColor
        noResultsLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        noResultsLabel.text = defaultErrorMessage
        
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        cvLayout.minimumLineSpacing = 2
        
        var cvFrame = self.bounds
        cvFrame.origin.x = self.bounds.size.width
        
        collectionView = UICollectionView(frame: cvFrame, collectionViewLayout: cvLayout)
        collectionView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        collectionView.registerNib(UINib(nibName: "AutocompleteCell", bundle: NSBundle(forClass: ARVAutocompleteBar.self)), forCellWithReuseIdentifier: "ResultCell")
    }
    
    func activateForAutoCompleteType(type: String) {

        promptLabel.text = self.autocompleteDelegate?.promptForAutocompleteType(type) ?? ""
        self.addSubview(promptLabel)

    }
    
    func deactivate(){
        
        collectionView.removeFromSuperview()
        var cvFrame = self.bounds
        cvFrame.origin.x = self.bounds.size.width
        collectionView.frame = cvFrame
        
        promptLabel.removeFromSuperview()
        noResultsLabel.removeFromSuperview()
        
        
    }
    
    func showResultsForAutocompleteType(type:String, query:String) {
    
       
        results = self.autocompleteDelegate?.resultsForAutocompleteType(type, query: query) ?? []
        collectionView.reloadData()
        
        if results.count == 0 {
            collectionView?.removeFromSuperview()
            noResultsLabel.text = self.autocompleteDelegate?.noResultsErrorMessageForAutocompleteType?(type) ?? defaultErrorMessage
            self.addSubview(noResultsLabel)
            
        }
        else {
            noResultsLabel.removeFromSuperview()
            self.addSubview(collectionView)
            animateCollectionView()

            let frame = collectionView.frame
            if frame.origin.x != 0 {
            }
            
        }
        
    }
    
    private func animateCollectionView(){
    
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.collectionView.frame.origin.x = 0
            
            }) { (finished:Bool) -> Void in
            
        }
    }
    
    //MARK: CollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ResultCell", forIndexPath: indexPath) as! AutocompleteCell
        
        let result = results[indexPath.row]
        cell.resultLabel.text = result
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let result = results[indexPath.row]
        self.autocompleteDelegate?.autocompleteBarDidSelectResult(result)
    }
}
