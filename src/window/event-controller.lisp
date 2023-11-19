(in-package :cl-drawer)

(defstruct e-controller
  widget
  callback-id)

(defun click-event-controller-init ()
  (let ((controller (make-gesture-click)))
    (make-e-controller :widget controller)))

(defun move-event-controller-init ()
  (let ((controller (make-event-controller-motion)))
    (make-e-controller :widget controller)))

(defun event-controller-connect-callback (controller callback action)
  (event-controller-disconnect-callback controller)
  (setf (e-controller-callback-id controller)
	(connect (e-controller-widget controller) action callback)))

(defun event-controller-disconnect-callback (controller)
  (when (not (null (e-controller-callback-id controller)))
    (gir:disconnect (e-controller-widget controller) (e-controller-callback-id controller))
    (setf (e-controller-callback-id controller) nil)))
