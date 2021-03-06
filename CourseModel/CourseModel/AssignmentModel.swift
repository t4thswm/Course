//
//  AssignmentModel.swift
//  CourseModel
//
//  Created by Archie Yu on 2017/1/10.
//  Copyright © 2017年 Archie Yu. All rights reserved.
//

import Foundation

public class Assignment: NSObject, NSCoding {
    
    public var course: String
    public var content: String
    public var note: String
    public var beginTime: Date
    public var endTime: Date
    
    public init(in course: String, todo content: String, note: String, from beginTime: Date, to endTime: Date) {
        self.course = course
        self.content = content
        self.note = note
        self.beginTime = beginTime
        self.endTime = endTime
    }
    
    public func encode(with: NSCoder){
        with.encode(course, forKey: "course")
        with.encode(content, forKey: "content")
        with.encode(note, forKey: "note")
        with.encode(beginTime, forKey: "begin")
        with.encode(endTime, forKey: "end")
    }
    
    required public init?(coder: NSCoder) {
        course = coder.decodeObject(forKey: "course") as! String
        content = coder.decodeObject(forKey: "content") as! String
        note = coder.decodeObject(forKey: "note") as! String
        beginTime = coder.decodeObject(forKey: "begin") as! Date
        endTime = coder.decodeObject(forKey: "end") as! Date
    }
    
}

public func assignmentDataFilePath() -> String {
    let manager = FileManager()
    let containerURL = manager.containerURL(forSecurityApplicationGroupIdentifier: "group.studio.sloth.Course")
    return (containerURL?.appendingPathComponent("assignment.dat").path)!
}
