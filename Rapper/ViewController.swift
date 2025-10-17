
//
//  ViewController.swift
//  Rapper
//
//  Created by Sing Hui Hang on 17/10/25.
//

import UIKit
import OpenAI

class ExplosionView: UIView {
    private var emitter: CAEmitterLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEmitter()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupEmitter()
    }

    private func setupEmitter() {
        emitter = CAEmitterLayer()
        emitter.emitterPosition = center
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 100, height: 100)
        layer.addSublayer(emitter)
    }

    func explode() {
        let cell = CAEmitterCell()
        cell.birthRate = 1000
        cell.lifetime = 1.5
        cell.velocity = 250
        cell.velocityRange = 80
        cell.emissionLongitude = -CGFloat.pi / 2
        cell.emissionRange = CGFloat.pi / 2
        cell.scale = 0.3
        cell.scaleRange = 0.2
        cell.contents = createParticleImage()?.cgImage

        let colors: [UIColor] = [
            UIColor(red: 232/255, green: 34/255, blue: 46/255, alpha: 1.0), // elmoRed
            UIColor(red: 0/255, green: 129/255, blue: 204/255, alpha: 1.0), // cookieBlue
            UIColor(red: 255/255, green: 210/255, blue: 0/255, alpha: 1.0), // bigBirdYellow
            UIColor(red: 0/255, green: 168/255, blue: 98/255, alpha: 1.0) // oscarGreen
        ]
        
        var cgColors: [CGColor] = []
        for color in colors {
            cgColors.append(color.cgColor)
        }
        
        cell.color = colors.randomElement()?.cgColor
        
        emitter.emitterCells = [cell]

        // Stop the emitter after a short burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.emitter.birthRate = 0
        }
    }
    
    private func createParticleImage() -> UIImage? {
        let size = CGSize(width: 10, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


  final class ViewController: UIViewController {
      
      private var discoTimer: Timer?
      private var responseTextTimer: Timer?
      private let chatService = RapperChatService()
      private var explosionView: ExplosionView!
      
      // Color Palette
      let elmoRed = UIColor(red: 232/255, green: 34/255, blue: 46/255, alpha: 1.0)
      let cookieBlue = UIColor(red: 0/255, green: 129/255, blue: 204/255, alpha: 1.0)
      let bigBirdYellow = UIColor(red: 255/255, green: 210/255, blue: 0/255, alpha: 1.0)
      let oscarGreen = UIColor(red: 0/255, green: 168/255, blue: 98/255, alpha: 1.0)
      
      private let promptField: UITextField = {
          let field = UITextField()
          field.placeholder = "Ask rap mentor ELMO here …"
          field.font = UIFont(name: "AvenirNext-Bold", size: 18)
          field.borderStyle = .none
          field.backgroundColor = .white
          field.layer.cornerRadius = 10
          field.layer.borderWidth = 3
          field.layer.borderColor = UIColor.black.cgColor
          field.returnKeyType = .send
          
          // Add some padding
          let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: field.frame.height))
          field.leftView = paddingView
          field.leftViewMode = .always
          
          return field
      }()

      private let sendButton: UIButton = {
          let button = UIButton(type: .system)
          button.setTitle("Hit it!", for: .normal)
          button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 24)
          button.backgroundColor = UIColor(red: 255/255, green: 210/255, blue: 0/255, alpha: 1.0) // bigBirdYellow
          button.setTitleColor(.black, for: .normal)
          button.layer.cornerRadius = 10
          button.layer.borderWidth = 3
          button.layer.borderColor = UIColor.black.cgColor
          return button
      }()
      
      private let resetSession: UIButton = {
          let button = UIButton(type: .system)
          button.setTitle("Reset Session", for: .normal)
          button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18)
          button.backgroundColor = UIColor(red: 232/255, green: 34/255, blue: 46/255, alpha: 1.0) // elmoRed
          button.setTitleColor(.white, for: .normal)
          button.layer.cornerRadius = 10
          button.layer.borderWidth = 3
          button.layer.borderColor = UIColor.black.cgColor
          return button
      }()

      private let responseView: UITextView = {
          let textView = UITextView()
          textView.isEditable = false
          textView.isSelectable = true
          textView.text = "Your rhymes will land here."
          textView.font = UIFont(name: "AvenirNext-Regular", size: 18)
          textView.backgroundColor = .white
          textView.layer.cornerRadius = 12
          textView.layer.borderWidth = 3
          textView.layer.borderColor = UIColor.black.cgColor
          textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
          return textView
      }()

      override func viewDidLoad() {
          super.viewDidLoad()
          
          // Gradient Background
          let gradientLayer = CAGradientLayer()
          gradientLayer.frame = view.bounds
          gradientLayer.colors = [
              UIColor(red: 0/255, green: 129/255, blue: 204/255, alpha: 1.0).cgColor, // cookieBlue
              UIColor(red: 0/255, green: 168/255, blue: 98/255, alpha: 1.0).cgColor // oscarGreen
          ]
          view.layer.insertSublayer(gradientLayer, at: 0)
          
          let stack = UIStackView(arrangedSubviews: [promptField, sendButton, responseView, resetSession])
          stack.axis = .vertical
          stack.spacing = 20
          stack.translatesAutoresizingMaskIntoConstraints = false
          
          view.addSubview(stack)
          
          explosionView = ExplosionView(frame: view.bounds)
          explosionView.isUserInteractionEnabled = false
          view.addSubview(explosionView)
          
          NSLayoutConstraint.activate([
              promptField.heightAnchor.constraint(equalToConstant: 50),
              sendButton.heightAnchor.constraint(equalToConstant: 50),
              stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
              stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
              stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
              responseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
          ])
          
          sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
          
          resetSession.addTarget(self, action: #selector(resetSessionAction) , for: .touchUpInside)
      }
      

      @objc private func sendTapped() {
          // Button bounce animation
          UIView.animate(withDuration: 0.1, animations: {
              self.sendButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
          }) { _ in
              UIView.animate(withDuration: 0.1) {
                  self.sendButton.transform = .identity
              }
          }
          
          startDiscoAnimation()
   
          Task { [weak self] in
              guard let self = self else { return }
              let userPrompt = promptField.text ?? ""
              
              if userPrompt == ""{
                  self.responseView.text = "Give Elmo a beat!"
                  self.stopDiscoAnimation()
                  return
              }
              
              do{
                  self.responseView.text = "Lil Mo's cooking up some bars...🎙️"
                  let response = try await chatService.respond(to: userPrompt)
                  self.animateResponseText(text: response)
                  self.stopDiscoAnimation()
                  }
                  
              catch{
                  responseView.text = "Elmo forget his lyrics ... \(error.localizedDescription)"
                  self.stopDiscoAnimation()
              }
 
          }

      }
      
      private func startDiscoAnimation() {
          let colors: [UIColor] = [
              elmoRed.withAlphaComponent(0.7),
              cookieBlue.withAlphaComponent(0.7),
              bigBirdYellow.withAlphaComponent(0.7),
              oscarGreen.withAlphaComponent(0.7),
          ]
          var currentIndex = 0
          
          discoTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
              guard let self = self else {
                  timer.invalidate()
                  return
              }
              
              UIView.animate(withDuration: 0.5) {
                  self.responseView.backgroundColor = colors[currentIndex]
              }
              
              currentIndex = (currentIndex + 1) % colors.count
          }
      }

      private func stopDiscoAnimation() {
          discoTimer?.invalidate()
          discoTimer = nil
          UIView.animate(withDuration: 0.5) {
              self.responseView.backgroundColor = .white
          }
      }
      
      private func animateResponseText(text: String) {
          responseTextTimer?.invalidate()
          responseView.text = ""
          let words = text.split(separator: " ")
          var wordIndex = 0
          
          responseTextTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
              guard let self = self else {
                  timer.invalidate()
                  return
              }
              
              if wordIndex < words.count {
                  self.responseView.text += String(words[wordIndex]) + " "
                  wordIndex += 1
              } else {
                  timer.invalidate()
                  self.explosionView.explode()
              }
          }
      }
      
      @objc func resetSessionAction(){
          self.responseView.text = "Give Elmo a beat!"
          promptField.text = ""
          promptField.placeholder = "Ask rap mentor ELMO here …"
      }
  }




