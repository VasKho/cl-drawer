(in-package :cl-drawer)

(defmacro line-button-callback (algo)
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

(defun line-menu-button-init ()
  (menu-expander-init
   "" "Open line drawing menu"
   `(,(menu-button-init
       "expander-button"
       "DDA"
       "Draw line with DDA algorithm"
       (line-button-callback :line))
     ,(menu-button-init
       "expander-button"
       "Bresenham"
       "Draw line with Bresenham algorithm"
       (line-button-callback :line))
     ,(menu-button-init
       "expander-button"
       "Wu"
       "Draw line with Wu algorithm"
       (line-button-callback :line)))))
