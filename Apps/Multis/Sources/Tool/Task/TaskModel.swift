//
//  TaskModel.swift
//  Multis
//
//  Created by 송영모 on 8/3/25.
//

import Foundation

public protocol TaskModel {
  var task: MultisTask { get }
}

public class BaseTaskModel {
  public let task: MultisTask

  public init(task: MultisTask) {
    self.task = task
  }
}
