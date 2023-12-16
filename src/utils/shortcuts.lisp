(in-package :cl-drawer)

(defstruct key-manager
  (shortcuts nil :type list)
  controller)

(defun main-shortcut-callback (self keyval keycode state)
  (declare (ignore self keyval state))
  ;; (format t "~a~%" keycode)
  (let ((callback (cdr (assoc keycode (key-manager-shortcuts *key-manager*)))))
    (when (not (null callback))
      (funcall callback))))

(defun key-manager-init ()
  (let ((key-controller (key-event-controller-init)))
    (event-controller-connect-callback key-controller 'main-shortcut-callback 'key-pressed)
    (make-key-manager :controller key-controller)))

(defmacro add-shortcut (manager keycode &rest body)
  `(let ((callback (lambda () ,@body)))
     (setf (key-manager-shortcuts ,manager)
	   (acons ,keycode callback (key-manager-shortcuts ,manager)))))

(defun remove-shortcut (manager keycode)
  (setf (key-manager-shortcuts manager)
	(remove-if (lambda (el) (= (car el) keycode)) (key-manager-shortcuts manager))))
