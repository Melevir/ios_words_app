//
//  WordScreenBuilder.swift
//  ios_words_app
//
//  Created by Ilya Lebedev on 22/08/2019.
//  Copyright © 2019 Ilya Lebedev. All rights reserved.
//

import Foundation
import UIKit

class WordScreenBuilder {
    private enum Constants {
        static let maxLettersPerRow = 5

        static let bottomOffset = CGFloat(200)
        static let betweenStacksOffset = CGFloat(200)

        static let letterSize = CGFloat(50)
        static let letterSpacing = CGFloat(10)
        static let letterFontSize = CGFloat(30)
        static let letterCornerRadius = CGFloat(8)
        static let letterBorderWidthForActive = CGFloat(3.0)
        static let letterBorderWidthForInactive = CGFloat(1.0)
        static let letterBorderWidthForEmpty = CGFloat(0.2)
        static let letterTextColorForActive = UIColor.black

        static let possibleLettersMultiplicator = 2
        static let emptyLettersAmount = 2
    }

    public enum LetterStyle {
        case active
        case inactive
        case empty
    }

    public struct WordScreenInfo {
        public let wordStackView: UIStackView
        public let optionsStackView: UIStackView
    }

    private var view: UIView?

    init(_ baseView: UIView) {
        view = baseView
    }

    func build(word: String) -> WordScreenInfo {
        let startEmptyIndex = (0..<(word.count - Constants.emptyLettersAmount)).randomElement() ?? 0
        let emptyIndexes = startEmptyIndex..<(startEmptyIndex + Constants.emptyLettersAmount)

        var wordLabels: [UILabel] = []
        var correctLettersToAdd: [Character] = []
        for (charNum, char) in word.enumerated() {
            if emptyIndexes.contains(charNum) {
                wordLabels.append(createLabelWith(style: .empty))
                correctLettersToAdd.append(char)
            } else {
                wordLabels.append(createLabelWith(letter: char, style: .inactive))
            }
        }
        let incorrectLettersToAdd = WordScreenBuilder.getRandomLetters(
            amount: correctLettersToAdd.count * (Constants.possibleLettersMultiplicator - 1),
            blackList: correctLettersToAdd
        )

        var optionsLabels: [UILabel] = []
        for char in correctLettersToAdd + incorrectLettersToAdd {
            optionsLabels.append(createLabelWith(letter: char))
        }

        let wordStackView = createStackViewWithLabels(labels: wordLabels)
        let optionsStackView = createStackViewWithLabels(labels: optionsLabels)

        view?.addSubview(wordStackView)
        view?.addSubview(optionsStackView)

        setDefaultLetterStackViewConstraints(stackView: wordStackView)
        setDefaultLetterStackViewConstraints(stackView: optionsStackView)
        if let view = view {
            optionsStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Constants.bottomOffset
            ).isActive = true
        }
        wordStackView.bottomAnchor.constraint(
            equalTo: optionsStackView.topAnchor,
            constant: -Constants.betweenStacksOffset
        ).isActive = true

        return WordScreenInfo(wordStackView: wordStackView, optionsStackView: optionsStackView)
    }

    private func createStackViewWithLabels(labels: [UILabel]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.letterSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        var rowsAmount = Int(labels.count / Constants.maxLettersPerRow)
        if labels.count % Constants.maxLettersPerRow > 0 {
            rowsAmount += 1
        }

        let splittedLabels = labels.splitBy(subSize: Constants.maxLettersPerRow)
        for rowNumber in 0..<rowsAmount {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = Constants.letterSpacing
            for label in splittedLabels[rowNumber] {
                rowStackView.addArrangedSubview(label)
            }
            rowStackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(rowStackView)
        }
        return stackView
    }

    private func createLabelWith(letter: Character? = nil, style: LetterStyle = .active) -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = label.font.withSize(Constants.letterFontSize)
        label.layer.cornerRadius = Constants.letterCornerRadius
        if let letter = letter {
            label.text = String(letter)
        }
        WordScreenBuilder.setStyle(to: label, style: style)
        return label
    }

    private func setDefaultLetterStackViewConstraints(stackView: UIStackView) {
        if let view = view {
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        for subview in stackView.subviews {
            for label in subview.subviews {
                label.heightAnchor.constraint(equalToConstant: Constants.letterSize).isActive = true
                label.widthAnchor.constraint(equalToConstant: Constants.letterSize).isActive = true
            }
        }
    }

    public static func setStyle(to label: UILabel, style: LetterStyle) {
        switch style {
        case .active:
            label.layer.borderColor = UIColor.black.cgColor
            label.layer.borderWidth = Constants.letterBorderWidthForActive
            label.textColor = Constants.letterTextColorForActive
        case .inactive:
            label.layer.borderColor = UIColor.gray.cgColor
            label.layer.borderWidth = Constants.letterBorderWidthForInactive
            label.textColor = UIColor.gray
        case .empty:
            label.layer.borderColor = UIColor.lightGray.cgColor
            label.layer.borderWidth = Constants.letterBorderWidthForEmpty
            label.textColor = UIColor.lightGray
        }
    }

    private static func getRandomLetters(amount: Int, blackList: [Character]) -> [Character] {
        var resultCharacters: [Character] = []
        let allLetters = "abcdefghijklmnopqrstuvwxyz".filter({!blackList.contains($0)})
        let maxRetries = 100
        for _ in 0...maxRetries {
            guard let randomLetter = allLetters.randomElement() else {
                continue
            }
            if !resultCharacters.contains(randomLetter) {
                resultCharacters.append(randomLetter)
            }
            if resultCharacters.count == amount {
                break
            }
        }
        return resultCharacters
    }
}
