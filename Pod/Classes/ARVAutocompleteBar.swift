//
//  ARVAutocompleteBar.swift
//  Pods
//
//  Created by Arvindh Sukumar on 05/07/15.
//
//

import UIKit

@objc protocol ARVAutocompleteDelegate {
    
    func autocompleteBarPromptForType(type:String)->String?
    optional func autocompleteBarNoResultsErrorMessageForType(type:String)->String?
    func autocompleteBarResultsForType(type:String, query:String)->[String]
    func autocompleteBarDidSelectResult(result:String)
}

class ARVAutocompleteBar: UIToolbar, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    weak var autocompleteDelegate: ARVAutocompleteDelegate?
    private var promptLabel: UILabel!
    private var noResultsLabel: UILabel!
    private var collectionView:UICollectionView!
    private var results:[String] = []
    private let defaultErrorMessage = "No Results found"
    private var currentAutocompleteType: String?
    private var isActive: Bool = false
    
    var textColor: UIColor = UIColor(white: 0.4, alpha: 1)
    var font: UIFont = UIFont.systemFontOfSize(15)
    private var bgColor: UIColor {
        return self.barTintColor ?? UIColor(white: 0.95, alpha: 1)
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
        promptLabel.backgroundColor = self.bgColor
        promptLabel.textColor = self.textColor
        promptLabel.font = self.font
        promptLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        noResultsLabel = UILabel(frame: self.bounds)
        noResultsLabel.backgroundColor = self.bgColor
        noResultsLabel.font = self.font
        noResultsLabel.textColor = self.textColor
        noResultsLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        noResultsLabel.text = defaultErrorMessage
        
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        cvLayout.minimumLineSpacing = 2
        
        var cvFrame = self.bounds
        cvFrame.origin.x = self.bounds.size.width
        
        collectionView = UICollectionView(frame: cvFrame, collectionViewLayout: cvLayout)
        collectionView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        collectionView.backgroundColor = self.bgColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: "AutocompleteCell", bundle: NSBundle(forClass: ARVAutocompleteBar.self)), forCellWithReuseIdentifier: "ResultCell")
    }
    
    func activateForAutoCompleteType(type: String) {
        currentAutocompleteType = type
        promptLabel.text = self.autocompleteDelegate?.autocompleteBarPromptForType(type) ?? ""
        self.addSubview(promptLabel)
        noResultsLabel.removeFromSuperview()
        isActive = true
    }
    
    func deactivate(){
        if isActive {
            collectionView.removeFromSuperview()
            var cvFrame = self.bounds
            cvFrame.origin.x = self.bounds.size.width
            collectionView.frame = cvFrame
            
            promptLabel.removeFromSuperview()
            noResultsLabel.removeFromSuperview()
            
            isActive = false
        }
        
        
    }
    
    func showResultsForAutocomplete(var query:String) {
    
        if let currentAutocompleteType = currentAutocompleteType {
            if query == currentAutocompleteType {
                return
            }
            if query.hasPrefix(currentAutocompleteType){
                query.removeAtIndex(query.startIndex)
            }
            results = self.autocompleteDelegate?.autocompleteBarResultsForType(currentAutocompleteType, query: query) ?? []
            collectionView.reloadData()
            
            if results.count == 0 {
                collectionView?.removeFromSuperview()
                noResultsLabel.text = self.autocompleteDelegate?.autocompleteBarNoResultsErrorMessageForType?(currentAutocompleteType) ?? defaultErrorMessage
                self.addSubview(noResultsLabel)
                
            }
            else {
                noResultsLabel.removeFromSuperview()
                promptLabel.removeFromSuperview()
                
                self.addSubview(collectionView)
                animateCollectionView()

                let frame = collectionView.frame
                if frame.origin.x != 0 {
                }
                
            }
        }
    }
    
    private func animateCollectionView(){
    
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
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
        cell.resultLabel.font = self.font
        cell.resultLabel.text = result
        cell.resultLabel.textColor = self.textColor
        
        cell.backgroundColor = self.bgColor
        cell.contentView.backgroundColor = self.bgColor
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let result = results[indexPath.row]
        self.autocompleteDelegate?.autocompleteBarDidSelectResult(result)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let label = UILabel()
        let result = self.results[indexPath.row]
        
        label.text = result
        label.sizeToFit()
        
        return CGSizeMake(label.frame.size.width + 6, 44)
        
    }
}
