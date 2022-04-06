//
//  File.swift
//  
//
//  Created by Chris Eidhof on 05.04.22.
//

import Foundation

public struct LSeq<Element>: Mergable {
    public init(siteID: SiteID) {
        self.siteID = siteID
    }
    
    var siteID: SiteID
    var _elements: [LSeqNode<Element>] = []
    var clock: Int = 0
    
    mutating public func insert(_ value: Element, at idx: Int) {
        let parentID = idx > 0 ? _elements[idx-1].id : nil
        let newID = NodeID(time: clock, siteID: siteID)
        let node = LSeqNode(parentID: parentID, id: newID, value: value)
        _insert(node)
        clock += 1
    }
    
    mutating func _insert(_ node: LSeqNode<Element>) {
        let idx: Int
        if let pID = node.parentID {
            idx = _elements.firstIndex(where: { $0.id == pID })! + 1
        } else {
            idx = 0
        }
        for existingIx in _elements[idx...].indices {
            let existing = _elements[existingIx]
            if existing.id == node.id {
                // todo safety checks
                return
            }
            if existing.id < node.id {
                _elements.insert(node, at: existingIx)
                return
            }
        }
        _elements.append(node)
    }
    
    public var elements: [Element] {
        _elements.map { $0.value }
    }
    
    public mutating func merge(_ other: LSeq<Element>) {
        for node in other._elements {
            _insert(node)
        }
    }
}

struct LSeqNode<Element> {
    var parentID: NodeID?
    var id: NodeID
    var value: Element
}
