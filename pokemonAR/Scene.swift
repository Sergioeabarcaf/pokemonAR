//
//  Scene.swift
//  pokemonAR
//
//  Created by Sergio Abarca Flores on 05-07-18.
//  Copyright © 2018 sergioeabarcaf. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    let remainingLabel = SKLabelNode()
    var timer : Timer?
    var targetsCreated = 0
    var targetsCount = 0 {
        didSet{
            self.remainingLabel.text = "Faltan: \(targetsCount)"
        }
    }
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        remainingLabel.fontSize = 30
        remainingLabel.fontName = "Avenir Next"
        remainingLabel.color = .white
        remainingLabel.position = CGPoint(x: 0, y: view.frame.midY-50)
        addChild(remainingLabel)
        targetsCount = 0
        
        //Crear enemigos cada 3 segundos
        self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
            self.createTarget()
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func createTarget(){
        if(self.targetsCreated == 25){
            self.timer?.invalidate()
            self.timer = nil
            return
        }
        else{
            self.targetsCreated += 1
            self.targetsCount += 1
        }
    }
}
