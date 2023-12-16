(in-package :cl-drawer)

(defun pointer-button-init ()
  (menu-button-init "button" "󰇀" "Move canvas objects" 'pointer-button-callback))

(defun pointer-button-callback (button)
  (declare (ignore button))
  (canvas-clear-points *canvas*)
  (canvas-remove-last-object *canvas* t)
  (canvas-disconnect-callback *canvas* 'pressed)
  (canvas-disconnect-callback *canvas* 'motion)
  (gl-area-queue-render (canvas-widget *canvas*)))
