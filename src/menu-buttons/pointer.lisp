(in-package :cl-drawer)

(defstruct (pointer-button (:include menu-btn)))

(defun pointer-button-init ()
  (menu-button-init "button" "󰇀" "Move canvas objects" 'pointer-button-callback))

(defun pointer-button-callback (button)
  (declare (ignore button))
  (canvas-disconnect-callback *canvas* 'pressed)
  (canvas-disconnect-callback *canvas* 'motion))
