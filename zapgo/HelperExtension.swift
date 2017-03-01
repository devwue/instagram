//
//  HelperExtension.swift
//  zapgo
//
//  Created by 김대종 on 2/25/17.
//  Copyright © 2017 devwue. All rights reserved.
//

import Foundation
import UIKit

// Returns a dict of a decoded query string, if present in the URL fragment.

extension URL {
    var queryItems: [String: String]? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .flatMap { $0.dictionaryRepresentation }
            .reduce([:], +)
    }
    func getImages() -> UIImage? {
        if let data = NSData(contentsOf: self) {
            let image = UIImage(data: data as Data);
            return image!;
        }
        return nil;
    }

}

extension URLQueryItem {
    var dictionaryRepresentation: [String: String]? {
        if let value = value {
            return [name: value]
        }
        return nil
    }
}

func +<Key, Value> (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    var result = lhs
    rhs.forEach{ result[$0] = $1 }
    return result
}

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}

