//
//  GameView.swift
//  MauvaisePluie
//
//  Created by m2sar on 26/10/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

import Foundation
import UIKit
import Darwin

class GameView: UIView {
    private let scoresBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    private let jouerBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    private let preferencesBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
	
	private let niveauLabel = UILabel()
	private let scoreLabel = UILabel()
	private let gaucheBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
    private let droiteBtn = UIButton.buttonWithType(UIButtonType.System) as! UIButton
	
    private var screenW : CGFloat!
	private var screenH : CGFloat!
    private let personSpeed : CGFloat = 30
	private let personView = UIImageView(image: UIImage(named: "player"))
    private var level = 1
	private var score = 0
	
	private var asterNbMax = 0
	private var asterSpeedMax = 0
	private var prob = 0
	private var cpt = 0
	private var asterArr = [(UIImageView, CGFloat)]()
	private var timer : NSTimer!
    private var vc : ViewController!
    
    init(frame: CGRect, viewC: ViewController) {
        super.init(frame: frame)
        
        screenW = frame.size.width
		screenH = frame.size.height
		vc = viewC
        
        scoresBtn.setTitle("Scores", forState: UIControlState.Normal)
        scoresBtn.addTarget(superview, action: "openScoreView", forControlEvents: UIControlEvents.TouchUpInside) //superview
        scoresBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        jouerBtn.setTitle("Jouer", forState: UIControlState.Normal)
        jouerBtn.addTarget(self, action: "openGameMode", forControlEvents: UIControlEvents.TouchUpInside)
        jouerBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        preferencesBtn.setTitle("Preferences", forState: UIControlState.Normal)
        preferencesBtn.addTarget(superview, action: "openPrefView", forControlEvents: UIControlEvents.TouchUpInside)
        preferencesBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        niveauLabel.text = String(format: "Niveau: %d", level)
        niveauLabel.textAlignment = NSTextAlignment.Left
        niveauLabel.textColor = UIColor.whiteColor()
        
        mAJourScore()
        scoreLabel.textAlignment = NSTextAlignment.Right
        scoreLabel.textColor = UIColor.whiteColor()
        
        gaucheBtn.setTitle("<<<", forState: UIControlState.Normal)
        gaucheBtn.addTarget(self, action: "gauche", forControlEvents: UIControlEvents.TouchUpInside)
        gaucheBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        droiteBtn.setTitle(">>>", forState: UIControlState.Normal)
        droiteBtn.addTarget(self, action: "droite", forControlEvents: UIControlEvents.TouchUpInside)
        droiteBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        gaucheBtn.backgroundColor = UIColor.grayColor()
        droiteBtn.backgroundColor = UIColor.grayColor()
        
        niveauLabel.hidden = true
        scoreLabel.hidden = true
        gaucheBtn.hidden = true
        droiteBtn.hidden = true
        
        self.addSubview(scoresBtn)
        self.addSubview(jouerBtn)
        self.addSubview(preferencesBtn)
        self.addSubview(niveauLabel)
        self.addSubview(scoreLabel)
        self.addSubview(gaucheBtn)
        self.addSubview(droiteBtn)
        self.addSubview(personView)
        dessine(frame.size)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	
	func openGameMode()
	{
        
		asterSpeedMax = 3 + 2 * level
		setAsterNbMax()
		cpt = 0
		score = 0
		
		scoresBtn.hidden = true
		jouerBtn.hidden = true
        preferencesBtn.hidden = true
		
		niveauLabel.hidden = false
		scoreLabel.hidden = false
        gaucheBtn.hidden = false
		droiteBtn.hidden = false
		personView.hidden = false
        
        var periode = 0.1 / Double(level)
        timer = NSTimer.scheduledTimerWithTimeInterval(periode, target: self, selector: "updateGame", userInfo: nil, repeats: true)
	}
	
	func updateGame()
	{
		//update prob
		if(cpt == 0)
		{
			initProb()
		}
        
        if(asterArr.count < asterNbMax)
        {
            cpt++
            prob += cpt
        }
		
		//add aster ; clean cpt
		if(prob >= 100 && asterArr.count < asterNbMax)
		{
			var num = arc4random() % 4 + 1
			var name = String(format: "%@%d", "asteroide-100-0", num)			
			var asterView = UIImageView(image: UIImage(named: name))
			var posH = random() % Int(screenW-20)
            if(screenW < screenH){
                asterView.frame = CGRectMake(CGFloat(posH), -screenW/15, screenW/12, screenW/12)
            }else{
                asterView.frame = CGRectMake(CGFloat(posH), -screenH/15, screenH/12, screenH/12)
            }
            asterView.addMotionEffect(UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.TiltAlongHorizontalAxis))
            asterView.addMotionEffect(UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.TiltAlongVerticalAxis))
			var speedAster = CGFloat(random() % asterSpeedMax + 1)
			asterArr.append((asterView, speedAster))
			self.addSubview(asterView)
            
			cpt = 0
		}
		
        var arrTemp = [Int]()
        if(asterArr.count > 0)
        {
            for i in 0...(asterArr.count-1)
            {
                var x = asterArr[i].0.frame.origin.x
                var y = asterArr[i].0.frame.origin.y
                var w = asterArr[i].0.frame.size.width
                var h = asterArr[i].0.frame.size.height
                var v = asterArr[i].1
                
                //confit
                var personX = personView.frame.origin.x
                var personY = personView.frame.origin.y
                var personW = personView.frame.size.width
                var personH = personView.frame.size.height
                
                if((y+h >= personY && y <= personY+personH)
                    && (x+w >= personX && x <= personX+personW))
                {
                    gameover()
                    break
                }
                
                
                //remove
                if(y > screenH)
                {
                    score++
                    mAJourScore()
                    arrTemp.append(i)
                }
                else
                {
                    //move aster
                    asterArr[i].0.frame.origin.y += v
                }
            }
            
            if(arrTemp.count > 0)
            {
                for index in arrTemp
                {
                    asterArr[index].0.removeFromSuperview()
                    asterArr.removeAtIndex(index)
                }
                arrTemp.removeAll(keepCapacity: false)
            }
        }
	}
	
	func gauche()
	{
		personView.frame.origin.x -= personSpeed
		
		if(personView.frame.origin.x < 0)
		{
			personView.frame.origin.x = 0
		}
	}
	
	func droite()
	{
		personView.frame.origin.x += personSpeed
		
		if(personView.frame.origin.x > (screenW - personView.frame.size.width))
		{
			personView.frame.origin.x = screenW - personView.frame.size.width
		}
	}
	
	
	func gameover()
	{
        if(asterArr.count > 1)
        {
            for aster in asterArr
            {
                aster.0.removeFromSuperview()
            }
            asterArr.removeAll(keepCapacity: false)
        }
        
		timer.invalidate()
		timer = nil
		niveauLabel.hidden = true
        scoreLabel.hidden = true
        gaucheBtn.hidden = true
        droiteBtn.hidden = true
		scoresBtn.hidden = false
		jouerBtn.hidden = false
        personView.hidden = true
        preferencesBtn.hidden = false
        dessine(CGSizeMake(screenW, screenH))
            
		vc.setScore()
		vc.openScoreView()
	}
    
    func setLevel(l : Int)
    {
        level = l
        niveauLabel.text = String(format: "Niveau: %d", level)
    }
	
	func setAsterNbMax()
	{
		if(UIDevice.currentDevice().userInterfaceIdiom == .Pad)
		{
			asterNbMax = 50 + 10 * level
		}
		else
		{
			asterNbMax = 20 + 10 * level
		}
	}
	
	func initProb()
	{
		do
		{
			prob = random() % 101 + cpt
		}
		while(prob >= 30)
	}
	
	func getScore() -> Int
	{
		return score
	}
    
    func mAJourScore()
    {
        scoreLabel.text = String(format: "Score: %d", score)
    }
    
    func dessine(size: CGSize)
    {
        screenW = size.width
        screenH = size.height
        self.frame = CGRectMake(0, 0, screenW, screenH)
        self.backgroundColor = UIColor(patternImage: UIImage(named: "fond-mauvaise-pluie")!)

        if(screenW < screenH)
        {
            personView.frame = CGRectMake(screenW/2, screenH-screenW/8, screenW/8, screenW/8)
            personView.hidden = true
            //3 button
            scoresBtn.frame = CGRectMake(10, 10, screenW/6, screenW/15)
            jouerBtn.frame = CGRectMake(screenW/2-screenW/8, 10, screenW/8, screenW/15)
            preferencesBtn.frame = CGRectMake(screenW-screenW/4-10, 10, screenW/4, screenW/15)
            //4 button
            niveauLabel.frame = CGRectMake(10, 10, screenW/4, screenW/15)
            scoreLabel.frame = CGRectMake(screenW-screenW/4-10, 10, screenW/4, screenW/15)
            gaucheBtn.frame = CGRectMake(0, screenH-screenW/15, screenW/8, screenW/15)
            droiteBtn.frame = CGRectMake(screenW-screenW/8, screenH-screenW/15, screenW/8, screenW/15)
        }
        else
        {
            personView.frame = CGRectMake(screenW/2, screenH-screenH/8, screenH/8, screenH/8)
            personView.hidden = true
            //3 button
            scoresBtn.frame = CGRectMake(10, 10, screenH/6, screenH/15)
            jouerBtn.frame = CGRectMake(screenW/2-screenH/8, 10, screenH/8, screenH/15)
            preferencesBtn.frame = CGRectMake(screenW-screenH/4-10, 10, screenH/4, screenH/15)
            //4 button
            niveauLabel.frame = CGRectMake(10, 10, screenH/4, screenH/15)
            scoreLabel.frame = CGRectMake(screenW-screenH/4-10, 10, screenH/4, screenH/15)
            gaucheBtn.frame = CGRectMake(0, screenH-screenH/15, screenH/8, screenH/15)
            droiteBtn.frame = CGRectMake(screenW-screenH/8, screenH-screenH/15, screenH/8, screenH/15)
        }
       
    }
}