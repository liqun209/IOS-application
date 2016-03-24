//
//  ScoreView.swift
//  MauvaisePluie
//
//  Created by m2sar on 26/10/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

import Foundation
import UIKit

class ScoreView: UIView, UITextFieldDelegate{
    private let doneBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    private let goodScoresTitle = UILabel()
    private let scoresTextView = UITextView()
    private let state = UILabel()
    private let scoreLabel = UILabel()
    private let nomField = UITextField()
    private var goodScoresArr = [("???", 0), ("???", 0), ("???", 0), ("???", 0), ("???", 0)]
    private var score = 0
    private var name = "???"
    private var vc : ViewController!

    init(frame: CGRect, viewC: ViewController) {
        super.init(frame: frame)
        
        vc = viewC
        doneBtn.setTitle("Done", forState: UIControlState.Normal)
        doneBtn.addTarget(superview, action: "openGameView", forControlEvents: UIControlEvents.TouchUpInside)
        goodScoresTitle.text = "Meilleurs Scores"
        goodScoresTitle.textAlignment = NSTextAlignment.Center
        
        mAJourTextView()
        scoresTextView.textAlignment = NSTextAlignment.Center
        state.text = "Votre score"
        state.textAlignment = NSTextAlignment.Center
        scoreLabel.text = "0"
        scoreLabel.textAlignment = NSTextAlignment.Center
        
        nomField.keyboardType = UIKeyboardType.ASCIICapable
        nomField.borderStyle = UITextBorderStyle.Bezel
        nomField.returnKeyType = UIReturnKeyType.Done
        nomField.enabled = true
        nomField.delegate = self
        
        self.addSubview(doneBtn)
        self.addSubview(goodScoresTitle)
        self.addSubview(scoresTextView)
        self.addSubview(state)
        self.addSubview(scoreLabel)
        self.addSubview(nomField)
        let size = frame.size
        dessine(size)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mAJourTextView()
    {
        var content = ""
        for item in goodScoresArr
        {
            var temp = String(format: "%@\t%d\n", item.0, item.1)
            content += temp
        }
        scoresTextView.text = content
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.frame.origin.y -= 120
        scoreLabel.hidden = true
        state.text = "Saisir votre nom: "
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        name = textField.text
        scoreLabel.hidden = false
        state.text = "Votre score"
        mAJourGoodScoresArr()
        self.frame.origin.y = 0
        self.resignFirstResponder()
        self.endEditing(true)
        scoreLabel.text = String(format: "%d", score)
        score = 0
        name = "???"
        nomField.text = ""
        vc.cleanScore()
        return true
    }
    
    
    func dessine(size: CGSize)
    {
        self.frame = CGRectMake(0, 0, size.width, size.height)
        let w = size.width
        let h = size.height
        var y:CGFloat = 20
        
        doneBtn.frame = CGRectMake(w-50, y, 40, 20)
        goodScoresTitle.frame = CGRectMake(w/2-75, y, 150, 20)
        y += 20
        scoresTextView.frame = CGRectMake(10, y, w-20, 100)
        y += 100
        state.frame = CGRectMake(10, y, w-20, 20)
        y += 20
        scoreLabel.frame = CGRectMake(10, y, w-20, 20)
        y += 50
        nomField.frame = CGRectMake(w/2-100, y, 200, 30)
    }
	
	func setScore(s : Int)
	{
		score = s
        scoreLabel.text = String(format: "%d", score)
	}
    
	func mAJourGoodScoresArr()
	{
        for(var i=0; i<5; i++)
        {
            if(score > goodScoresArr[i].1)
            {
                for(var j=3; j>=i; j--)
                {
                    goodScoresArr[j+1] = goodScoresArr[j]
                }
                goodScoresArr[i].0 = name
                goodScoresArr[i].1 = score
                break
            }
        }
        
        mAJourTextView()
	}
}

