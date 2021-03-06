//
//  AddCourseViewController.swift
//  Course
//
//  Created by Cedric on 2016/12/8.
//  Copyright © 2016年 Cedric. All rights reserved.
//

import UIKit
import CourseModel

class AddCourseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var editingItem = ""
    
    var courseHeight: CGFloat!
    var teacherHeight: CGFloat!
    var locationHeight: CGFloat!
    var deltaY: CGFloat!
    
    @IBOutlet weak var courseTimePicker: UIPickerView!
    @IBOutlet weak var courseName: UITextField!
    @IBOutlet weak var teacherName: UITextField!
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var toTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        courseTimePicker.delegate = self
        courseName.delegate = self
        location.delegate = self
        teacherName.delegate = self
        
        courseTimePicker.selectRow(0, inComponent: 0, animated: true)
        courseTimePicker.selectRow(weekNum - 1, inComponent: 1, animated:true)
        courseTimePicker.selectRow(0, inComponent: 2, animated: true)
        
        courseTimePicker.selectRow(0, inComponent: 3, animated: true)
        courseTimePicker.selectRow(0, inComponent: 4, animated: true)
        courseTimePicker.selectRow(1, inComponent: 5, animated: true)
        
        courseHeight = courseName.frame.maxY
        teacherHeight = teacherName.frame.maxY
        locationHeight = location.frame.maxY
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 注册键盘出现和键盘消失的通知
        let NC = NotificationCenter.default
        NC.addObserver(self,
                       selector: #selector(AddCourseViewController.keyboardWillChangeFrame(notification:)),
                       name:NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NC.addObserver(self,
                       selector: #selector(AddCourseViewController.keyboardWillHide(notification:)),
                       name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 注销键盘出现和键盘消失的通知
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            // 计算可能需要上移的距离
            let keyboardHeight = keyboardFrame.origin.y
            switch(editingItem) {
            case "course":
                deltaY = keyboardHeight - courseHeight - 10
            case "teacher":
                deltaY = keyboardHeight - teacherHeight - 10
            case "location":
                deltaY = keyboardHeight - locationHeight - 10
            default: break
            }
            // 需要上移时，变化视图位置
            if deltaY < 0 {
                toTop.constant = deltaY + 16
                UIView.animate(withDuration: 0.5, animations: {() -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }

    }
    
    func keyboardWillHide(notification: NSNotification) {
        toTop.constant = 16
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func editCourse(_ sender: UITextField) {
        editingItem = "course"
    }
    
    @IBAction func editTeacher(_ sender: UITextField) {
        editingItem = "teacher"
    }
    
    @IBAction func editLocation(_ sender: UITextField) {
        editingItem = "location"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 6
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0, 1: return weekNum
        case 2: return 3
        case 3: return weekdayNum
        case 4, 5: return courseNum
        default: return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let title = UILabel()
        title.textColor = UIColor.black
        title.textAlignment = NSTextAlignment.center
//        title.font = UIFont.systemFont(ofSize: 13)
        switch component {
        case 0, 1: title.text = String(row + 1)
        case 2:
            switch row {
            case 0: title.text = "全"
            case 1: title.text = "单"
            case 2: title.text = "双"
            default: break
            }
        case 3: title.text = weekdayStrings[row]
        case 4, 5: title.text = String(row + 1)
        default: break
        }
        return title
    }
    
    func CheckContentIsLegal() -> Bool{
        
        let beginWeek = courseTimePicker.selectedRow(inComponent: 0)
        let endWeek = courseTimePicker.selectedRow(inComponent: 1)
        let beginLesson = courseTimePicker.selectedRow(inComponent: 4)
        let endLesson = courseTimePicker.selectedRow(inComponent: 5)
        
        var hint: String!
        
        if beginWeek > endWeek {
            hint = "课程开始周不能晚于结束周!"
        } else if beginLesson > endLesson {
            hint = "课程开始时间不能晚于结束时间!"
        } else if courseName.text == "" {
            hint = "未输入课程名!"
        } else if teacherName.text == "" {
            hint = "未输入老师姓名！"
        } else if location.text == "" {
            hint = "未输入地点名！"
        } else {
            return true
        }
        
        let alertController = UIAlertController(title: "提示", message: hint, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "确定", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
        
        return false
        
    }
    
    @IBAction func AddCourse(_ sender: UIBarButtonItem) {
        
        if !CheckContentIsLegal() { return }
        
        var alternate = courseTimePicker.selectedRow(inComponent: 2)
        if alternate == 0 { alternate = 3 }
        let newLesson = Lesson(
            course: courseName.text!,
            inRoom: location.text!,
            fromWeek: courseTimePicker.selectedRow(inComponent: 0) + 1,
            toWeek: courseTimePicker.selectedRow(inComponent: 1) + 1,
            alternate: alternate,
            on: courseTimePicker.selectedRow(inComponent: 3),
            fromClass: courseTimePicker.selectedRow(inComponent: 4) + 1,
            toClass: courseTimePicker.selectedRow(inComponent: 5) + 1)
        let newCourse = Course(course: courseName.text!, teacher: teacherName.text!)
        
        add(course: newCourse)
        if add(lesson: newLesson) {
            lessonList[newLesson.weekday].sort() { $0.firstClass < $1.firstClass }
            let filePath = courseDataFilePath()
            NSKeyedArchiver.archiveRootObject(courseList, toFile: filePath)
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "时间冲突", message: "该课程在相同时间存在其他安排", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
            alertController.addAction(confirmAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
}
