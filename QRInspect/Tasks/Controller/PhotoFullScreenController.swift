//
//  PhotoFullScreenController.swift
//  QRInspect
//
//

import Foundation
import UIKit
import SDWebImage

final class PhotoFullScreenController: UIViewController {
    
    @IBOutlet weak private var imageView: UIImageView!
    var image : Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImage()
    }
    
    private func loadImage() {
        if let url = URL(string: (image?.url ?? "")) {
            imageView.sd_setImage(with: url)
        }
    }
    
    private func setup() {
        imageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinchRecognized(_:))))
        
        imageView.isUserInteractionEnabled = true
    }
    
    @IBAction private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func pinchRecognized(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
          
          if gesture.state == .began || gesture.state == .changed {
                          let pinchCenter = CGPoint(x: gesture.location(in: view).x - view.bounds.midX,
                            y: gesture.location(in: view).y - view.bounds.midY)
                          
                          let transformedPinchCenter = pinchCenter.applying(view.transform.inverted())
                          
                          var transform = view.transform.translatedBy(x: transformedPinchCenter.x, y: transformedPinchCenter.y)
                          transform = transform.scaledBy(x: gesture.scale, y: gesture.scale)
                          transform = transform.translatedBy(x: -transformedPinchCenter.x, y: -transformedPinchCenter.y)
                          
                          view.transform = transform
                          
                          gesture.scale = 1.0
          } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.3) {
                  view.transform = .identity
                
            }
        }
      
    }
}
