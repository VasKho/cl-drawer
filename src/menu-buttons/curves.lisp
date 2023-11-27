(in-package :cl-drawer)

(defmacro bezier-button-callback (algo)
  `(lambda (button)
     (declare (ignore button))
     (let* ((read-points 0)
	    (points nil)
	    (tmp nil)
	    (read-point-tmp
	      (lambda (self x y)
		(declare (ignore self))
		(canvas-remove-last-object *canvas* t)
		(cond
		  ((= read-points 1)
		   (setq tmp `(1 0 ,(- (widget-height (canvas-widget *canvas*)) (truncate y)) ,(truncate x)))
		   (setq points `(,@tmp ,@(canvas-reading-buffer *canvas*) ,@tmp ,@(canvas-reading-buffer *canvas*))))
		  ((= read-points 2)
		   (setq tmp `(1 0 ,(- (widget-height (canvas-widget *canvas*)) (truncate y)) ,(truncate x)))
		   (setq points `(,@(reverse (nthcdr 4 (reverse (canvas-reading-buffer *canvas*)))) ,@tmp ,@(canvas-reading-buffer *canvas*))))
		  ((= read-points 3)
		   (setq tmp `(1 0 ,(- (widget-height (canvas-widget *canvas*)) (truncate y)) ,(truncate x)))
		   (setq points `(,@tmp ,@(canvas-reading-buffer *canvas*)))))
		(canvas-add-object *canvas*
				   (make-drawable-object
				    :points points
				    :program (cdr (assoc ,algo (canvas-programs *canvas*)))
				    :primitive :lines-adjacency)
				   t)
		(gl-area-queue-render (canvas-widget *canvas*))))
	    (read-point
	      (lambda (self n-press x y)
		(declare (ignore self n-press))
		(canvas-add-point *canvas* (list x y 0 1))
		(incf read-points)
		(cond
		  ((= read-points 1)
		   (canvas-connect-callback *canvas* 'motion read-point-tmp))
		  ((= read-points 4)
		   (canvas-remove-last-object *canvas* t)
		   (canvas-add-object *canvas*
				      (make-drawable-object
				       :points (canvas-reading-buffer *canvas*)
				       :program (cdr (assoc ,algo (canvas-programs *canvas*)))
				       :primitive :lines-adjacency))
		   (canvas-clear-points *canvas*)
		   (canvas-disconnect-callback *canvas* 'pressed)
		   (canvas-disconnect-callback *canvas* 'motion)
		   (gl-area-queue-render (canvas-widget *canvas*)))))))
       (canvas-connect-callback *canvas* 'pressed read-point))))

(defmacro b-spline-button-callback (algo)
  `(lambda (button)
     (declare (ignore button))
     (let* ((read-points 0)
	    (points nil)
	    (tmp nil)
	    (read-point-tmp
	      (lambda (self x y)
		(declare (ignore self))
		(canvas-remove-last-object *canvas* t)
		(cond
		  ((= read-points 1)
		   (setq tmp `(1 0 ,(- (widget-height (canvas-widget *canvas*)) (truncate y)) ,(truncate x)))
		   (setq points `(,@tmp ,@(canvas-reading-buffer *canvas*) ,@tmp ,@(canvas-reading-buffer *canvas*))))
		  ((= read-points 2)
		   (setq tmp `(1 0 ,(- (widget-height (canvas-widget *canvas*)) (truncate y)) ,(truncate x)))
		   (setq points `(,@(reverse (nthcdr 4 (reverse (canvas-reading-buffer *canvas*)))) ,@tmp ,@(canvas-reading-buffer *canvas*))))
		  ((= read-points 3)
		   (setq tmp `(1 0 ,(- (widget-height (canvas-widget *canvas*)) (truncate y)) ,(truncate x)))
		   (setq points `(,@tmp ,@(canvas-reading-buffer *canvas*)))))
		(canvas-add-object *canvas*
				   (make-drawable-object
				    :points points
				    :program (cdr (assoc ,algo (canvas-programs *canvas*)))
				    :primitive :lines-adjacency)
				   t)
		(gl-area-queue-render (canvas-widget *canvas*))))
	    (read-point
	      (lambda (self n-press x y)
		(declare (ignore self n-press))
		(canvas-add-point *canvas* (list x y 0 1))
		(incf read-points)
		(cond
		  ((= read-points 1)
		   (canvas-connect-callback *canvas* 'motion read-point-tmp))
		  ((= read-points 4)
		   (canvas-remove-last-object *canvas* t)
		   (canvas-add-object *canvas*
				      (make-drawable-object
				       :points (canvas-reading-buffer *canvas*)
				       :program (cdr (assoc ,algo (canvas-programs *canvas*)))
				       :primitive :lines-adjacency))
		   (canvas-clear-points *canvas*)
		   (canvas-disconnect-callback *canvas* 'pressed)
		   (canvas-disconnect-callback *canvas* 'motion)
		   (gl-area-queue-render (canvas-widget *canvas*)))))))
       (canvas-connect-callback *canvas* 'pressed read-point))))

(defun curves-menu-button-init ()
  (menu-expander-init
   "󰕙" "Open curves drawing menu"
   `(,(menu-button-init
       "expander-button"
       "Bezier curve"
       "Draw Bezier curve"
       (bezier-button-callback :bezier))
     ,(menu-button-init
       "expander-button"
       "B-spline"
       "Draw B-spline curve"
       (b-spline-button-callback :b-spline))
     ,(menu-button-init
       "expander-button"
       "Closed B-spline"
       "Draw closed B-spline curve"
       (b-spline-button-callback :parabola)))))
