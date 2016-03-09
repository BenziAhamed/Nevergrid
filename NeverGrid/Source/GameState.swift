//
//  GameState.swift
//  OnGettingThere
//
//  Created by Benzi on 21/07/14.
//  Copyright (c) 2014 Benzi Ahamed. All rights reserved.
//

import Foundation

class GameState {

    var targetMoves = 0
    var targetCoins = 0
    var movesMade = 0
    var coinsCollected = 0
    var status = GameplayState.Waiting
    
    init() {}
    
}

enum GameplayState {
    case Waiting
    case PlayerTurnInProgress
    case AIInProgress
    case GameOver
}