//
//  EmotionSystem.swift
//  gettingthere
//
//  Created by Benzi on 14/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation
import SpriteKit


/// This system adds emotions to entities
class EmotionSystem : System {
    
    var emotionSim:Simulation!
    var player:PlayerComponent!
    var gameOverHandled = false
    
    var emotionMap = [
        Emotion.Happy:      "emotion_happy",
        Emotion.Elated:     "emotion_elated",
        Emotion.Surprised:  "emotion_surprised",
        Emotion.Sad:        "emotion_sad",
        Emotion.HalfBlink:  "emotion_halfblink",
        Emotion.FullBlink:  "emotion_fullblink",
        Emotion.Angry:      "emotion_angry",
        Emotion.Rage:       "emotion_rage",
        Emotion.Screaming:  "emotion_scream",
        Emotion.Contempt:   "emotion_contempt",
        Emotion.Uff:        "emotion_uff"
    ]
    
    
    override init(_ world:WorldMapper) {
        super.init(world)
        enable()
    }
    
    /// listen to all events
    func enable() {
        world.eventBus.subscribe(GameEvent.AICompleted, handler: self)
        world.eventBus.subscribe(GameEvent.GameStarted, handler: self)
        world.eventBus.subscribe(GameEvent.GameOver, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyEnraged, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyCalmed, handler: self)
        world.eventBus.subscribe(GameEvent.EnemyDeath, handler: self)
    }
    
    func disable() {
        emotionSim.stop()
        let sprite = world.sprite.get(world.mainPlayer)
        sprite.node.removeActionForKey("blinking")
        //world.eventBus.unsubscribe(self)
    }
    
    override func handleEvent(event:Int, _ data:AnyObject?) {
        switch event {
            
        case GameEvent.GameStarted:
            self.player = world.player.get(world.mainPlayer)
            startEmotionSimulation()
            
        case GameEvent.AICompleted:
            onAICompleted()
        
        case GameEvent.EnemyEnraged:
            onEntityEmotion(data as! Entity, emotion: Emotion.Rage)
            
        case GameEvent.EnemyCalmed:
            onEntityEmotion(data as! Entity, emotion: Emotion.Angry)
        
        case  GameEvent.EnemyDeath:
            onEnemyDeath(data as! Entity)
            
        case GameEvent.GameOver:
            disable() // no need to listen to further events
            let reason = (data as! GameOverReason)
            let won = reason.won
            if won {
                changePlayerEmotion(Emotion.Elated)
            } else {
                switch reason.state {
                	case .PlayerStuck: fallthrough
                    case .RanOutOfMoves: changePlayerEmotion(Emotion.Surprised)
                    default: changePlayerEmotion(Emotion.Sad)
                }
            }
            gameOverHandled = true
            
        default: break
        }
    }
    
    /// core simulation responsible for
    /// player blinks and enemy taunts
    func startEmotionSimulation() {
        // now that the game is in play
        // setup our timed events
        emotionSim = Simulation()
        emotionSim.name = "EMOTION SIM"
        emotionSim.every(5, range: 3).perform(Callback(self, EmotionSystem.doPlayerBlink)).named("player blink")
        emotionSim.every(5, range: 5).perform(Callback(self, EmotionSystem.doEnemyTaunts)).named("enemy taunts")
        emotionSim.start()
        
        simulations.append(emotionSim)
    }
    

    func onAICompleted() {
        // once the ai moves are complete
        // we need to check if we are in danger or not
        // if we are in danger, change to being
        // surprised
        // we are in danger only if an enemy can get
        // to us in 1 move
        // if player is close to an enemy show surprise
        var inDanger = false
        for l in [
            world.playerLocation.neighbourBottom,
            world.playerLocation.neighbourTop,
            world.playerLocation.neighbourLeft,
            world.playerLocation.neighbourRight
        ]{
            if let cell = world.level.cells.get(l) {
                if cell.occupiedByEnemy {
                    if world.freeze.belongsTo(cell.occupiedBy!) {
                        continue
                    }
                    
                    let move = getPossibleMove(l, end: world.playerLocation)
                    inDanger =  world.level.movePossible(l, direction: move)
                    
                    if inDanger {
                        break
                    }
                }
            }
        }
        
        if inDanger {
            changePlayerEmotion(Emotion.Surprised)
        } else {
            changePlayerEmotion(Emotion.Happy)
        }
    }
    
    func onEntityEmotion(entity:Entity, emotion:Emotion) {
        let sprite = world.sprite.get(entity)
        updateEmotionNode(sprite, texture: SpriteManager.Shared.entities.texture(emotionMap[emotion]!))
    }
    
    func onEnemyDeath(enemyEntity:Entity){
        let enemy = world.enemy.get(enemyEntity)
        var surprised:SKTexture!
        switch(enemy.enemyType) {

        case .SliderLeftRight: fallthrough
        case .SliderUpDown:
            surprised = SpriteManager.Shared.entities.texture("emotion_slider_surprised")
            
        case .Robot:
            return
            
        default:
            surprised = SpriteManager.Shared.entities.texture(emotionMap[Emotion.Surprised]!)
        }
        let sprite = world.sprite.get(enemyEntity)
        updateEmotionNode(sprite, texture: surprised)
    }


    /// blinks the player
    func doPlayerBlink() {
        if world.state.status == GameplayState.PlayerTurnInProgress || player.emotion != Emotion.Happy {
            return
        }
        switch arc4random_uniform(2) {
        	case 0: blinkTwice()
            default: blinkOnce()
        }
    }
    
    func filterActiveEnemies(e:Entity) -> Bool {
        let enemy = world.enemy.get(e)
        return enemy.enabled
    }
    
    func filterByWarpZone(e:Entity) -> Bool {
        let enemyLocation = world.location.get(e)
        let enemyZone = world.level.cells.get(enemyLocation)!.zone
        let playerZone = world.level.cells.get(world.playerLocation)!.zone
        return enemyZone == playerZone
    }
    
    /// animates the enemy
    func doEnemyTaunts() {
        var enemies = world.enemy.entities()
        if enemies.count == 0 { return }
        
        // filter enemies only in the current zone in standalone mode
        if world.level.zoneBehaviour == ZoneBehaviour.Standalone {
            enemies = enemies.filter(filterByWarpZone)
        }
        enemies = enemies.filter(filterActiveEnemies)
        if enemies.count == 0 { return }

        let enemy1 = any(enemies)
        animateEnemy(enemy1)
        
        if enemies.count > 1 {
            let enemy2 = any(enemies)
            if enemy1 != enemy2 {
                animateEnemy(enemy2)
            }
        }
    }
    
    
    // animation mappings based on enemy type
    let defaultEnemyAnimations = [shakeAndScream, jumpOnce, jumpTwice]
    let twoStepAnimations = [twoStepAngry, jumpOnce, shakeAndScream]
    let monsterAnimations = [monsterGlow, monsterJump, monsterBlink, monsterTalk]
    
    func animateEnemy(entity:Entity) {
        let enemy = world.enemy.get(entity)
        let sprite = world.sprite.get(entity)
        
        switch(enemy.enemyType){
            
        case .Destroyer: fallthrough
        case .OneStep:
            let animation = any(defaultEnemyAnimations)
            animation(self)(sprite)
            
        case .SliderLeftRight: fallthrough
        case .SliderUpDown:
            sliderAngry(sprite)
            
        case .TwoStep:
            let animation = any(twoStepAnimations)
            animation(self)(sprite)
            
        case .Monster:
            let animation = any(monsterAnimations)
            animation(self)(sprite)
            
        default: break
        }
    }
    

    
    func blinkTwice() {
        let sprite = world.sprite.get(world.mainPlayer)
        let emotion = sprite.node.childNodeWithName("emotion")!
        let blink = blinkAction()
        let blinkSequence =
            blink
            .followedBy(SKAction.waitForDuration(0.2))
            .followedBy(blink)
        emotion.runAction(blinkSequence, withKey: "blinking")
    }
    
    func blinkOnce() {
        let sprite = world.sprite.get(world.mainPlayer)
        let emotion = sprite.node.childNodeWithName("emotion")!
        emotion.runAction(blinkAction(), withKey: "blinking")
    }
    
    func blinkAction() -> SKAction {
        let textures = [
            SpriteManager.Shared.entities.texture("emotion_halfblink"),
            SpriteManager.Shared.entities.texture("emotion_fullblink")
        ]
        return SKAction.animateWithTextures(textures, timePerFrame: 0.1, resize: false, restore: true)
    }
}

/// MARK: emotion node updates
extension EmotionSystem {
    func changeEnemyEmotion(sprite:SpriteComponent, emotion:Emotion, time:CGFloat) {
        let textures:[SKTexture] = [
            SpriteManager.Shared.entities.texture(emotionMap[emotion]!),
            SpriteManager.Shared.entities.texture("emotion_angry")
        ]
        let animation = SKAction.animateWithTextures(textures, timePerFrame: NSTimeInterval(time), resize: false, restore: false)
        let emotionNode = sprite.node.childNodeWithName("emotion")! as! SKSpriteNode
        emotionNode.runAction(animation)
    }
    
    func changePlayerEmotion(emotion:Emotion) {
        if gameOverHandled { return }
        if player.emotion == emotion { return }
        player.emotion = emotion
        let sprite = world.sprite.get(world.mainPlayer)
        updateEmotionNode(sprite, texture: SpriteManager.Shared.entities.texture(emotionMap[emotion]!))
        //println("changed player emotion: \(emotionMap[emotion]!)")
    }
    
    func updateEmotionNode(sprite:SpriteComponent, texture:SKTexture) {
        let emotionNode = sprite.node.childNodeWithName("emotion")! as! SKSpriteNode
        emotionNode.texture = texture
    }
}

/// MARK: pre baked animations
extension EmotionSystem {
    func jumpTwice(sprite:SpriteComponent) {
        changeEnemyEmotion(sprite, emotion: Emotion.Uff, time: 2.8)
        let jumpTwice = SKAction.repeatAction(ActionFactory.sharedInstance.forceJump, count: 2)
        sprite.node.runAction(
            ActionFactory.sharedInstance.delay
            .followedBy(jumpTwice)
        )
    }
    
    func jumpOnce(sprite:SpriteComponent) {
        changeEnemyEmotion(sprite, emotion: Emotion.Uff, time: 1.4)
        sprite.node.runAction(
            ActionFactory.sharedInstance.delay
            .followedBy(ActionFactory.sharedInstance.forceJump)
        )
    }
    
    func shakeAndScream(sprite:SpriteComponent) {
        let duration:CGFloat = 2.0
        sprite.node.runAction(
            ActionFactory.sharedInstance.delay
            .followedBy(SKAction.shake(duration))
        )
        changeEnemyEmotion(sprite, emotion: Emotion.Screaming, time: duration)
    }
    
    func twoStepAngry(sprite:SpriteComponent) {
        let duration:CGFloat = 3.0
        let textures:[SKTexture] = [
            SpriteManager.Shared.entities.texture("enemy_twostep_down"),
            SpriteManager.Shared.entities.texture("enemy_twostep")
        ]
        let a = SKAction.animateWithTextures(textures, timePerFrame: 0.3, resize: false, restore: true)
        let r = SKAction.repeatAction(a, count: 5)
        sprite.node.runAction(
            ActionFactory.sharedInstance.delay
            .followedBy(r)
        )
        changeEnemyEmotion(sprite, emotion: Emotion.Screaming, time: duration)
    }
    
    func monsterBlink(sprite:SpriteComponent) {
        let textures:[SKTexture] = [
            SpriteManager.Shared.entities.texture("emotion_monster_half_closed"),
            SpriteManager.Shared.entities.texture("emotion_monster_full_closed"),
            SpriteManager.Shared.entities.texture("emotion_monster_half_closed")
        ]
        let blink = SKAction.animateWithTextures(textures, timePerFrame: 0.2, resize:false, restore: true)
        let node = sprite.node.childNodeWithName("emotion")! as! SKSpriteNode
        node.runAction(blink)
    }
    
    func monsterTalk(sprite:SpriteComponent) {
        let textures:[SKTexture] = [
            SpriteManager.Shared.entities.texture("emotion_monster_talk_1"),
            SpriteManager.Shared.entities.texture("emotion_monster_talk_2")
        ]
        let talk = SKAction.animateWithTextures(textures, timePerFrame: 0.2, resize:false, restore: true)
        let node = sprite.node.childNodeWithName("emotion")! as! SKSpriteNode
        node.runAction(SKAction.repeatAction(talk, count: 3))
    }
    
    func monsterGlow(sprite:SpriteComponent) {
        // add a glowy eye effect
        let emotion = sprite.node.childNodeWithName("emotion") as! SKSpriteNode
        
        let eyeSmoke1 = SKEmitterNode.emitterNodeWithName("EyeSmoke")
        eyeSmoke1.position = CGPointMake(-0.18*emotion.size.width, -0.33*emotion.size.width)
        eyeSmoke1.particleZPosition = 20.0
        eyeSmoke1.particleBlendMode = SKBlendMode.Screen
        
        
        let eyeSmoke2 = SKEmitterNode.emitterNodeWithName("EyeSmoke")
        eyeSmoke2.position = CGPointMake(+0.18*emotion.size.width, -0.33*emotion.size.width)
        eyeSmoke2.particleZPosition = 20.0
        eyeSmoke2.particleBlendMode = SKBlendMode.Screen
        
        
        emotion.addChild(eyeSmoke1)
        emotion.addChild(eyeSmoke2)
        
        eyeSmoke1.runOneShot(10.0)
        eyeSmoke2.runOneShot(10.0)
    }
    
    func monsterJump(sprite:SpriteComponent) {
        sprite.node.runAction(
            ActionFactory.sharedInstance.delay
            .followedBy(ActionFactory.sharedInstance.forceJump)
            )
//            {
//                [weak self] in
//                self!.bounceEveryone()
//        }
    }
    
    func bounceEveryone() {
        // bounce player
        let sprite = world.sprite.get(world.mainPlayer)
        sprite.node.runAction( ActionFactory.sharedInstance.bounce )
        
        // bounce enemies
        for e in world.enemy.entities() {
            let enemy = world.enemy.get(e)
            if enemy.enabled && enemy.enemyType != .Monster {
                let sprite = world.sprite.get(e)
                sprite.node.runAction( ActionFactory.sharedInstance.bounce )
            }
        }
    }
    
    func sliderAngry(sprite:SpriteComponent) {
        let angry = SpriteManager.Shared.entities.texture("emotion_slider_angry")
        let emotion = sprite.node.childNodeWithName("emotion")!
        emotion.runAction(
            ActionFactory.sharedInstance.delay
            .followedBy(SKAction.animateWithTextures([angry], timePerFrame: 2.0, resize: false, restore: true))
        )
    }
}