(in-package :cl-drawer)


(defun clear-button-init ()
  (menu-button-init "button" "" "Clear screen" 'clear-button-callback))

(defun clear-button-callback (button)
  (declare (ignore button))
  (canvas-remove-all-objects *canvas*)
  (canvas-disconnect-callback *canvas* 'pressed)
  (canvas-disconnect-callback *canvas* 'motion)
  (gl-area-queue-render (canvas-widget *canvas*)))
