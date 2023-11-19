(in-package :cl-drawer)

(defstruct menu-btn
  widget)

(defun menu-button-init (name label tooltip callback)
  (let ((b (make-button)))
    (setf (widget-name b) name
	  (widget-tooltip-text b) tooltip
	  (button-label b) label)
    (connect b "clicked" callback)
    (make-menu-btn :widget b)))

(defun menu-expander-init (label tooltip children)
  (let ((mb (make-menu-button))
	(popover (make-popover))
	(box (make-box :orientation +orientation-vertical+ :spacing 0)))
    (loop for child in children do
      (box-append box (menu-btn-widget child)))
    (setf (popover-child popover) box
	  (widget-tooltip-text mb) tooltip
	  (menu-button-label mb) label
	  (menu-button-direction mb) 3
	  (menu-button-popover mb) popover)
    (make-menu-btn :widget mb)))
