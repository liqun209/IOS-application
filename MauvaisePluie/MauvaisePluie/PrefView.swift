//
//  PrefView.swift
//  MauvaisePluie
//
//  Created by m2sar on 26/10/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

import Foundation
import UIKit

class PrefView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    private let doneBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    private let titleLab = UILabel()
    private let levelPik = UIPickerView()
    private let levelArr = ["Niveau de difficulté 1", "Niveau de difficulté 2","Niveau de difficulté 3","Niveau de difficulté 4","Niveau de difficulté 5"];
    private var level = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        doneBtn.setTitle("Done", forState: UIControlState.Normal)
        doneBtn.addTarget(superview, action: "setLevel", forControlEvents: UIControlEvents.TouchUpInside)
        titleLab.text = "Sélectionnez le niveau de difficulté"
        titleLab.textAlignment = NSTextAlignment.Center
        levelPik.dataSource = self
        levelPik.delegate = self
       
        self.addSubview(doneBtn)
        self.addSubview(titleLab)
        self.addSubview(levelPik)
        self.backgroundColor = UIColor.whiteColor()
        let size = UIScreen.mainScreen().bounds.size
        self.frame = CGRectMake(0, 0, size.width, size.height)
        dessine(size)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return levelArr.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return levelArr[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        level = row + 1
    }
    
    func getLevel() -> Int
    {
        return level
    }
       
    func dessine(size: CGSize)
    {
        self.frame = CGRectMake(0, 0, size.width, size.height)
        let w = size.width
        let h = size.height
        
        var y: CGFloat = 20
        doneBtn.frame = CGRectMake(w-50, y, 40, 20)
        y += 30
        titleLab.frame = CGRectMake(10, y, w-20, 20)
        y += 10
        levelPik.frame = CGRectMake(10, y, w-20, 100)
        
    }
 
}
