(in-package :cl-drawer)

(defmacro polygon-button-callback (algo)
  `(lambda (button)
     (declare (ignore button))
     (let* ((read-points 0)
	    (points nil)
	    (tmp nil)
	    (read-point-tmp
	      (lambda (self x y)
		(declare (ignore self))
		(canvas-remove-last-object *canvas* t)
		(setq tmp `(1 0 ,(- (widget-height (canvas-widget *canvas*)) (truncate y)) ,(truncate x)))
		(setq points `(,@tmp ,@(canvas-reading-buffer *canvas*)))
		(canvas-add-object *canvas*
				   (make-drawable-object
				    :max-points (/ (length points) 4)
				    :points points
				    :program (cdr (assoc ,algo (canvas-programs *canvas*)))
				    :primitive :line-strip)
				   t)
		(gl-area-queue-render (canvas-widget *canvas*))))
	    (read-point
	      (lambda (self n-press x y)
		(declare (ignore self n-press))
		(incf read-points)
		(canvas-remove-last-object *canvas* t)
		(canvas-add-point *canvas* (list x y 0 1))
		(cond
		  ((= read-points 1)
		   (canvas-connect-callback *canvas* 'motion read-point-tmp))))))
       (canvas-connect-callback *canvas* 'pressed read-point)
       (add-shortcut
	*key-manager* 27
	(canvas-set-points
	 *canvas*
	 `(,@(nthcdr (- (length (canvas-reading-buffer *canvas*)) 4) (canvas-reading-buffer *canvas*))
	   ,@(canvas-reading-buffer *canvas*)))
	(canvas-remove-last-object *canvas* t)
	(canvas-add-object *canvas*
			   (make-drawable-object
			    :max-points (/ (length (canvas-reading-buffer *canvas*)) 4)
			    :points (canvas-reading-buffer *canvas*)
			    :program (cdr (assoc ,algo (canvas-programs *canvas*)))
			    :primitive :line-strip))
	(canvas-clear-points *canvas*)
	(canvas-disconnect-callback *canvas* 'pressed)
	(canvas-disconnect-callback *canvas* 'motion)
	(gl-area-queue-render (canvas-widget *canvas*))
	(remove-shortcut *key-manager* 27))
       (add-shortcut
	*key-manager* 41
	(canvas-remove-last-object *canvas* t)
	(canvas-add-object *canvas*
			   (make-drawable-object
			    :max-points (/ (length (canvas-reading-buffer *canvas*)) 4)
			    :points (canvas-reading-buffer *canvas*)
			    :program (cdr (assoc :filled-polygon (canvas-programs *canvas*)))
			    :primitive :triangle-fan))
	(canvas-clear-points *canvas*)
	(canvas-disconnect-callback *canvas* 'pressed)
	(canvas-disconnect-callback *canvas* 'motion)
	(gl-area-queue-render (canvas-widget *canvas*))
	(remove-shortcut *key-manager* 41)))))

(defun polygon-menu-button-init ()
  (menu-button-init
   "button" "󰕠" "Draw polygon"
   (polygon-button-callback :polygon)))
