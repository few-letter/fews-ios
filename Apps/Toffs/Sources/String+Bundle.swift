//
//  String+Bundle.swift
//  Toff
//
//  Created by 송영모 on 6/22/25.
//

import Foundation

extension String {
    static let MIXPANEL_TOKEN = Bundle.main.infoDictionary?["MIXPANEL_TOKEN"] as? String ?? ""
}
