//
//  ViewController.swift
//  ios_words_app
//
//  Created by Ilya Lebedev on 19/08/2019.
//  Copyright © 2019 Ilya Lebedev. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    private var wordStackView: UIStackView?
    private var optionsStackView: UIStackView?
    private var correctWord: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        correctWord = words.randomElement()
        guard let correctWord = correctWord else {
            return
        }
        let screenInfo = WordScreenBuilder(view).build(word: correctWord)
        wordStackView = screenInfo.wordStackView
        optionsStackView = screenInfo.optionsStackView
        guard let wordStackView = wordStackView, let optionsStackView = optionsStackView else {
            return
        }

        for subview in optionsStackView.subviews {
            for label in subview.subviews {
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapAtOptionLetter(_:)))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(tap)
            }
        }
        for subview in wordStackView.subviews {
            guard let labels = subview.subviews as? [UILabel] else {
                return
            }
            for label in labels.filter({$0.text == nil}) {
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapAtWordLetter(_:)))
                label.isUserInteractionEnabled = true
                label.addGestureRecognizer(tap)
            }
        }

    }

    @objc private func handleTapAtOptionLetter(_ sender: UITapGestureRecognizer? = nil) {
        guard
            let labels = wordStackView?.subviews.flatMap({$0.subviews}) as? [UILabel],
            let tappedLabel = sender?.view as? UILabel
        else {
            return
        }
        let emptyLabel = labels.first(where: {$0.text == nil})
        if let emptyLabel = emptyLabel {
            emptyLabel.text = tappedLabel.text
            WordScreenBuilder.setStyle(to: emptyLabel, style: .active)
            tappedLabel.isHidden = true

            let currentWord = labels.map({$0.text ?? ""}).reduce("", +)
            if correctWord != nil && currentWord == correctWord {
                view.backgroundColor = UIColor.green
                wordStackView?.isHidden = true
                optionsStackView?.isHidden = true
            }
        }
    }

    @objc private func handleTapAtWordLetter(_ sender: UITapGestureRecognizer? = nil) {
        guard
            let labels = optionsStackView?.subviews.flatMap({$0.subviews}) as? [UILabel],
            let tappedLabel = sender?.view as? UILabel
        else {
            return
        }
        if let hiddenLabel = labels.first(where: {$0.isHidden == true && $0.text == tappedLabel.text}) {
            hiddenLabel.isHidden = false
            tappedLabel.text = nil
            WordScreenBuilder.setStyle(to: tappedLabel, style: .empty)
        }
    }
}
