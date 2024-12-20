//
//  List.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

// Protocol for Reusable Views
protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}
