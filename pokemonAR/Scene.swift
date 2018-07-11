//
//  Scene.swift
//  pokemonAR
//
//  Created by Sergio Abarca Flores on 05-07-18.
//  Copyright © 2018 sergioeabarcaf. All rights reserved.
//

import SpriteKit
import ARKit
import GameplayKit

class Scene: SKScene {
    
    let startTime = Date()
    var bonusTime = Date()
    
    let remainingLabel = SKLabelNode()
    var timer : Timer?
    var goals = 0
    var bonus = 0.0
    var score = 0.0
    var targetsCreated = 0
    var targetsDelete = 0
    var targetsCount = 0 {
        didSet{
            self.remainingLabel.text = "Faltan: \(targetsCount)"
        }
    }
    
    //Sonidos
    let bonita = SKAction.playSoundFileNamed("bonita", waitForCompletion: false)
    let dimeloBonito = SKAction.playSoundFileNamed("dimelobonito", waitForCompletion: false)
    let matando = SKAction.playSoundFileNamed("matando", waitForCompletion: false)
    let sanchez = SKAction.playSoundFileNamed("sanchez", waitForCompletion: false)
    let teQuiero = SKAction.playSoundFileNamed("tequiero", waitForCompletion: false)
    let tufo = SKAction.playSoundFileNamed("tufo", waitForCompletion: false)
    
    
    
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
        //Localizar el toque
        guard let touch = touches.first else {return}
        let location = touch.location(in: self)
        
        //Buscar los nodos tocados por el usuario
        let hit = nodes(at: location)
        
        if(targetsCreated >= 25){
            gameOver()
        }
        
        //Si hay un sprite, animarlo hasta que desaparesca
        if let sprite = hit.first {
            goals += 1
            let scaleOut = SKAction.scale(to: 2, duration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.4)
            let groupAction = SKAction.group([scaleOut, fadeOut])
            let removeAction = SKAction.removeFromParent()
            
            let bonusDiferentTime = Date().timeIntervalSince(bonusTime)
            print(bonusDiferentTime)
            
            if Int(bonusDiferentTime) <= 5 {
                bonusTime = Date()
                bonus += 1.2
                print("LLeva bonus, T: \(Int(bonusDiferentTime)) B: \(bonus)")
            }
            else{
                bonusTime = Date()
                bonus = 0
                print("NO lleva bonus, T: \(Int(bonusDiferentTime)) B: \(bonus)")
            }
            
            switch goals {
            case 20:
                let sequenceAction = SKAction.sequence([groupAction, removeAction, teQuiero])
                sprite.run(sequenceAction)
            case 15:
                let sequenceAction = SKAction.sequence([groupAction, removeAction, dimeloBonito])
                sprite.run(sequenceAction)
            case 10:
                let sequenceAction = SKAction.sequence([groupAction, removeAction, bonita])
                sprite.run(sequenceAction)
            case 5:
                let sequenceAction = SKAction.sequence([groupAction, removeAction, tufo])
                sprite.run(sequenceAction)
            default:
                let sequenceAction = SKAction.sequence([groupAction, removeAction, matando])
                sprite.run(sequenceAction)
            }

            //Actualizar los target que se elimino el pokemon
            score += (5 + ( 5 * bonus ))
            print(score)
            self.targetsCount -= 1
        }
        else{
            bonus = 0.0
        }
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
        
        guard let sceneView = self.view as? ARSKView else {return}
        
        
        //Fuente para generar numeros aleatorios
        let rand = GKRandomSource.sharedRandom()

        //Creacion de dos matrices 4x4 con giro en x e y
        let rotateX = float4x4.init(SCNMatrix4MakeRotation(2.0 * Float.pi * rand.nextUniform(), 1, 0, 0))
        let rotateY = float4x4.init(SCNMatrix4MakeRotation(2.0 * Float.pi * rand.nextUniform(), 0, 1, 0))
        
        //Producto de matrices anteriores
        let prodMatrix = simd_mul(rotateX, rotateY)
        
        //Creacion de matriz con movimiento en el eje Z a una distancia random entre 0.5 y 2.0
        var translation = matrix_identity_float4x4
        let distRange = GKRandomDistribution(lowestValue: -20, highestValue: -5)
        let distZ = Float(distRange.nextInt()) / 10
        translation.columns.3.z = distZ

        
        //Producto del movimiento de matrices y la distancia en Z
        let position = simd_mul(prodMatrix, translation)
        
        //Crear ancla para posicionar en AR
        let ancla = ARAnchor(transform: position)
         
        //Añadir ancla a la escena
        sceneView.session.add(anchor: ancla)
        
        //Eliminar ancla despues de 12 segundos
        self.timer = Timer.scheduledTimer(withTimeInterval: 12, repeats: false, block: { (timer) in
            sceneView.session.remove(anchor: ancla)
            self.targetsDelete += 1
        })
 
    }
    
    func gameOver(){
        remainingLabel.removeFromParent()
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        addChild(gameOver)
        
        let gameTime = Date().timeIntervalSince(startTime)
        
        let gameTimeLabel = SKLabelNode(text: "Te ha llevado: \(Int(gameTime)) Segundos.")
        gameTimeLabel.fontSize = 40
        gameTimeLabel.fontColor = UIColor.red
        gameTimeLabel.fontName = "Avenir Next"
        addChild(gameTimeLabel)
        
    }
}
