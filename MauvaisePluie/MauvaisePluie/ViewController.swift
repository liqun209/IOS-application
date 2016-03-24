//
//  ViewController.swift
//  MauvaisePluie
//
//  Created by m2sar on 26/10/2015.
//  Copyright (c) 2015 m2sar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	private var scoreView : ScoreView!
    private var prefView : PrefView!
	private var gameView : GameView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        let screenSize = UIScreen.mainScreen().bounds

		scoreView = ScoreView(frame: screenSize, viewC: self)
		prefView = PrefView(frame: screenSize)
        gameView = GameView(frame: screenSize, viewC: self)
		
        self.view.addSubview(scoreView)
        self.view.addSubview(prefView)
        self.view.addSubview(gameView)
        
        openGameView()
    }

    
    func openGameView()
    {
		scoreView.hidden = true
		gameView.hidden = false
        prefView.hidden = true
    }
	
	func openScoreView()
	{
		scoreView.hidden = false
		gameView.hidden = true
        prefView.hidden = true
	}
	
	func openPrefView()
	{
		scoreView.hidden = true
		gameView.hidden = true
        prefView.hidden = false
	}
	
    func setLevel()
    {
        gameView.setLevel(prefView.getLevel())
        openGameView()
    }
    
	func setScore()
	{
		scoreView.setScore(gameView.getScore())
	}
    
    func cleanScore()
    {
        scoreView.setScore(0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.All.rawValue)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        prefView.dessine(size)
        scoreView.dessine(size)
        gameView.dessine(size)
    }
}

