//
//  MainScene.swift
//  FlappySwift
//
//  Created by Brian Wang on 9/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class MainScene: GamePlayScene {
    
    let firstObstaclePosition: CGFloat = 200
    let distanceBetweenObstacles: CGFloat = 160
    var score: Int = 0
    
    weak var _obstaclesLayer: CCNode!
    weak var _restartButton: CCButton!
    weak var _scoreLabel: CCLabelTTF!
    
    override func didLoadFromCCB() {
        super.didLoadFromCCB()
        
        userInteractionEnabled = true
        _gamePhysicsNode.collisionDelegate = self
        
        hero = CCBReader.load("Character") as? Character
        _gamePhysicsNode.addChild(hero)
    
        // spawn the first obstacles
        for i in 1...3 {
            spawnNewObstacle() //have them look this up on how to do a for loop
        }
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if (!isGameOver) {
            hero?.flap()
            sinceTouch = 0
        }
    }
    
    func spawnNewObstacle() {
        var prevObstaclePos = firstObstaclePosition
        if (obstacles.count > 0) {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // create and add a new obstacle
        let obstacle = CCBReader.load("Obstacle") as! Obstacle
        obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
        obstacle.setupRandomPosition()
        obstacles.append(obstacle)
        
        _obstaclesLayer.addChild(obstacle)
        
    }
    
    override func update(delta: CCTime) {
        super.update(delta)
        
        //checking for removeable obstacles
        for obstacle in obstacles.reverse() {
            let obstacleWorldPosition = _gamePhysicsNode.convertToWorldSpace(obstacle.position)
            let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
            
            // obstacle moved past left side of screen?
            if obstacleScreenPosition.x < (-obstacle.contentSize.width) {
                obstacle.removeFromParent()
                obstacles.removeAtIndex(obstacles.indexOf(obstacle)!)
                
                // for each removed obstacle, add a new one
                spawnNewObstacle()
            }
        }
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, level: CCNode!) -> Bool {
        gameOver()
        return true
    }
    
    func gameOver() {
        _restartButton.visible = true
        isGameOver = true
        scrollSpeed = 0
        
        hero?.rotation = 90
        hero?.physicsBody.allowsRotation = false
        hero?.stopAllActions()
        
        let move = CCActionEaseBounceOut(action: CCActionMoveBy(duration: 0.1, position: ccp(0, 4)))
        let moveBack = CCActionEaseBounceOut(action: move.reverse())
        let shakeSequence = CCActionSequence(array: [move, moveBack])
        runAction(shakeSequence)
        
    }
    
    func restart() {
        var scene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().replaceScene(scene)
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, hero: CCNode!, goal: CCNode!) -> Bool {
        hero.color = CCColor.redColor()
        goal.removeFromParent()
        score++
        _scoreLabel.string = "\(score)"
        return true
    }
}
