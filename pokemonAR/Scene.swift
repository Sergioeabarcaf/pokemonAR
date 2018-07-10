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
        
        guard let sceneView = self.view as? ARSKView else {return}
        
        
        //Fuente para generar numeros aleatorios
        let rand = GKRandomSource.sharedRandom()

        //Creacion de dos matrices 4x4 con giro en x e y
        let rotateX = float4x4.init(SCNMatrix4MakeRotation(2.0 * Float.pi * rand.nextUniform(), 1, 0, 0))
        let rotateY = float4x4.init(SCNMatrix4MakeRotation(2.0 * Float.pi * rand.nextUniform(), 0, 1, 0))
        
        //Producto de matrices anteriores
        let prodMatrix = simd_mul(rotateX, rotateY)
        
        //Creacion de matriz con movimiento en el eje Z a 1.5 metros de distancia
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.5
        
        //Producto del movimiento de matrices y la distancia en Z
        let position = simd_mul(prodMatrix, translation)
        
        //Crear ancla para posicionar en AR
        let ancla = ARAnchor(transform: position)
         
        //Añadir ancla a la escena
        sceneView.session.add(anchor: ancla)
 
    }
}
