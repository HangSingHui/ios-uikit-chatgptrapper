//
//  ViewController.swift
//  Rapper
//
//  Created by Sing Hui Hang on 17/10/25.
//

import UIKit
import OpenAI

  final class ViewController: UIViewController {
      
      private let chatService = RapperChatService()
      
      private let promptField: UITextField = {
          let field = UITextField()
          field.placeholder = "Ask rap mentor ELMO here …"
          field.borderStyle = .roundedRect
          field.returnKeyType = .send
          return field
      }()

      private let sendButton: UIButton = {
          let button = UIButton(type: .system)
          button.setTitle("Hit it!", for: .normal)
          return button
      }()

      private let responseView: UITextView = {
          let textView = UITextView()
          textView.isEditable = false
          textView.isSelectable = true
          textView.text = "Your rhymes will land here."
          textView.font = .preferredFont(forTextStyle: .body)
          textView.backgroundColor = .secondarySystemBackground
          textView.layer.cornerRadius = 12
          textView.layer.borderWidth = 1
          textView.layer.borderColor = UIColor.separator.cgColor
          textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
          return textView
      }()

      override func viewDidLoad() {
          super.viewDidLoad()
          view.backgroundColor = .systemBackground

          let stack = UIStackView(arrangedSubviews: [promptField, sendButton, responseView])
          stack.axis = .vertical
          stack.spacing = 16
          stack.translatesAutoresizingMaskIntoConstraints = false

          view.addSubview(stack)

          NSLayoutConstraint.activate([
              stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
              stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
              stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
              responseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
          ])

          sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
      }
      

      @objc private func sendTapped() {
          // TODO: Call your chat service and update responseView.text with the returned bars.
   
          Task { [weak self] in
              guard let self = self else { return }
              let userPrompt = promptField.text ?? ""
              
              if userPrompt == ""{
                  self.responseView.text = "Give Elmo a beat!"
                  return
              }
              
              do{
                  self.responseView.text = "Lil Mo's cooking up some bars...🎙️"
                  let response = try await chatService.respond(to: userPrompt)
                  responseView.text = response
                  }
                  
              catch{
                  responseView.text = "Elmo forget his lyrics ... \(error.localizedDescription)"
              }
 
          }

      }
  }


