//
//  ParallaxImageView.swift
//  Twitchy
//
//  Created by Cédric Eugeni on 08/12/2017.
//  Copyright © 2017 Twitchy. All rights reserved.
//

import UIKit
import ParallaxView

open class ParallaxImageView: UIImageView, ParallaxableView {
    // MARK: Properties
    open var parallaxEffectOptions = ParallaxEffectOptions()
    open var parallaxViewActions = ParallaxViewActions<ParallaxImageView>()
    
    // MARK: Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        self.setupShadow()
        parallaxViewActions.setupUnfocusedState?(self)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
        self.setupShadow()
        parallaxViewActions.setupUnfocusedState?(self)
    }
    
    private func setupShadow() {
        self.layer.shadowColor = UIColor(red: 100/255, green: 65/255, blue: 164/255, alpha: 0.55).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 12.5
        self.clipsToBounds = false
    }
    
    internal func commonInit() {
        if parallaxEffectOptions.glowContainerView == nil {
            let view = UIView(frame: bounds)
            addSubview(view)
            parallaxEffectOptions.glowContainerView = view
        }
        
        parallaxViewActions.setupFocusedState = { [weak self] (view) in
            guard let _self = self else { return }
            
            view.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            view.layer.shadowOpacity = 1
        }
        
        parallaxViewActions.setupUnfocusedState = { [weak self] (view) in
            guard let _ = self else { return }
            
            view.transform = CGAffineTransform.identity
            view.layer.shadowOpacity = 0
        }
    }
    
    // MARK: UIView
    open override var canBecomeFocused : Bool {
        return true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let glowEffectContainerView = parallaxEffectOptions.glowContainerView else { return }
        
        if glowEffectContainerView != self, let glowSuperView = glowEffectContainerView.superview {
            glowEffectContainerView.frame = glowSuperView.bounds
        }
        
        let maxSize = max(glowEffectContainerView.frame.width, glowEffectContainerView.frame.height)*1.7
        // Make glow a litte bit bigger than the superview
        
        guard let glowImageView = getGlowImageView() else { return }
        
        glowImageView.frame = CGRect(x: 0, y: 0, width: maxSize, height: maxSize)
        // Position in the middle and under the top edge of the superview
        glowImageView.center = CGPoint(x: glowEffectContainerView.frame.width/2, y: -glowImageView.frame.height)
    }
    
    // MARK: UIResponder
    
    // Generally, all responders which do custom touch handling should override all four of these methods.
    // If you want to customize animations for press events do not forget to call super.
    open override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        parallaxViewActions.animatePressIn?(self, presses, event)
        
        super.pressesBegan(presses, with: event)
    }
    
    open override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        parallaxViewActions.animatePressOut?(self, presses, event)
        
        super.pressesCancelled(presses, with: event)
    }
    
    open override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        parallaxViewActions.animatePressOut?(self, presses, event)
        
        super.pressesEnded(presses, with: event)
    }
    
    open override func pressesChanged(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesChanged(presses, with: event)
    }
    
    // MARK: UIFocusEnvironment
    open override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if self == context.nextFocusedView {
            // Add parallax effect to focused cell
            parallaxViewActions.becomeFocused?(self, context, coordinator)
        } else if self == context.previouslyFocusedView {
            // Remove parallax effect
            parallaxViewActions.resignFocus?(self, context, coordinator)
        }
    }
}
