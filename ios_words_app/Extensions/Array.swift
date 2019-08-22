//
//  Array.swift
//  ios_words_app
//
//  Created by Ilya Lebedev on 22/08/2019.
//  Copyright © 2019 Ilya Lebedev. All rights reserved.
//

import Foundation

extension Array {
    func splitBy(subSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: subSize).map { startIndex in
            let endIndex = startIndex + subSize > count ? count : startIndex + subSize
            return Array(self[startIndex ..< endIndex])
        }
    }

    func flat() -> [Element] {
        return self.compactMap { $0 }
    }
}
