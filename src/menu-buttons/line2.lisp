(in-package :cl-drawer)

(defmacro line2-button-callback (algo)
  `(lambda (button)
     (declare (ignore button))
     (flet ((read-first-point (self n-press x y)
	      (declare (ignore self n-press))
	      (canvas-add-point *canvas* (list x y 0 1))
	      (canvas-disconnect-callback *canvas* 'pressed)
	      (flet ((redraw-line-on-move (self x y)
		       (declare (ignore self))
		       (canvas-remove-last-object *canvas* t)
		       (canvas-add-object *canvas*
					  (make-drawable-object
					   :points `(1
						     0
						     ,(- (widget-height (canvas-widget *canvas*)) (truncate y))
						     ,(truncate x)
						     ,@(canvas-reading-buffer *canvas*))
					   :program (cdr (assoc ,algo (canvas-programs *canvas*)))
					   :primitive :lines)
					  t)
		       (gl-area-queue-render (canvas-widget *canvas*)))
		     (read-second-point (self n-press x y)
		       (declare (ignore self n-press))
		       (canvas-add-point *canvas* (list x y 0 1))
		       (canvas-remove-last-object *canvas* t)
		       (canvas-add-object *canvas*
					  (make-drawable-object
					   :points (canvas-reading-buffer *canvas*)
					   :program (cdr (assoc ,algo (canvas-programs *canvas*)))
					   :primitive :lines))
		       (canvas-clear-points *canvas*)
		       (canvas-disconnect-callback *canvas* 'pressed)
		       (canvas-disconnect-callback *canvas* 'motion)
		       (gl-area-queue-render (canvas-widget *canvas*))))
		(canvas-connect-callback *canvas* 'motion #'redraw-line-on-move)
		(canvas-connect-callback *canvas* 'pressed #'read-second-point))))
       (canvas-connect-callback *canvas* 'pressed #'read-first-point))))

(defun line2-menu-button-init ()
  (menu-expander-init
   "󰺡" "Open second-order curves drawing menu"
   `(,(menu-button-init
       "expander-button"
       "Circle"
       "Draw circle"
       (line2-button-callback :circle))
     ,(menu-button-init
       "expander-button"
       "Ellipse"
       "Draw ellipse"
       (line2-button-callback :ellipse))
     ,(menu-button-init
       "expander-button"
       "Parabola"
       "Draw parabola"
       (line2-button-callback :parabola))
     ,(menu-button-init
       "expander-button"
       "Hyperbola"
       "Draw hyperbola"
       (line2-button-callback :hyperbola)))))
