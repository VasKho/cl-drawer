(in-package :cl-drawer)

(defstruct menu
  widget)

(defun menu-init ()
  (let ((mn (make-box :orientation +orientation-vertical+ :spacing 0)))
    (box-append mn (menu-btn-widget (pointer-button-init)))
    (box-append mn (menu-btn-widget (line-menu-button-init)))
    (box-append mn (menu-btn-widget (line2-menu-button-init)))
    (make-menu :widget mn)))
