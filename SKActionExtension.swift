//
//  SKActionExtension.swift
//  Quaver
//
//  Created by Eduardo Stefanel Paludo on 16/04/23.
//

import SpriteKit

func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat
{
    return (b-a) * fraction + a
}

struct ColorComponents {
    var red = CGFloat(0)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var alpha = CGFloat(0)
}

extension UIColor {
    func toComponents() -> ColorComponents {
        var components = ColorComponents()
        getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
        return components
    }
}

// Function to transition color of a SKShapeNode
extension SKAction {
    static func colorTransitionAction(fromColor : UIColor, toColor : UIColor, duration : Double = 0.4) -> SKAction
    {
        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let startColorComponents = fromColor.toComponents()
            let endColorComponents = toColor.toComponents()
            let transColor = UIColor(red: lerp(a: startColorComponents.red, b: endColorComponents.red, fraction: fraction),
                                     green: lerp(a: startColorComponents.green, b: endColorComponents.green, fraction: fraction),
                                     blue: lerp(a: startColorComponents.blue, b: endColorComponents.blue, fraction: fraction),
                                     alpha: lerp(a: startColorComponents.alpha, b: endColorComponents.alpha, fraction: fraction))
            (node as? SKShapeNode)?.fillColor = transColor
        }
        )
    }
}
