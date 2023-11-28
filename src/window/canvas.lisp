(in-package :cl-drawer)

(defstruct canvas
  widget
  event-controllers
  objects
  (programs nil :type list)
  vao
  (reading-buffer nil :type list)
  (projection-matrix #() :type vector)
  (trans-scale-matrix #() :type vector)
  (x-rot-matrix #() :type vector)
  (y-rot-matrix #() :type vector)
  (z-rot-matrix #() :type vector)
  size)

(defun canvas-draw-object (canvas object)
  (let* ((param-l (gl:get-uniform-location (drawable-object-program object) "param"))
	 (u-resol-location (gl:get-uniform-location (drawable-object-program object) "u_resolution"))
	 (color-uniform-location (gl:get-uniform-location (drawable-object-program object) "vertexColor"))
	 (points (reverse (drawable-object-points object)))
	 (arr (gl:alloc-gl-array :int (length points))))
    (gl:use-program (drawable-object-program object))
    (gl:uniformf color-uniform-location 0 0 0 1)
    (gl:uniformf u-resol-location (first (canvas-size canvas)) (second (canvas-size canvas)))
    (gl:uniformf param-l (nth 0 points) (nth 1 points) (nth 4 points) (nth 5 points))
    (canvas-apply-projection-matrix canvas (drawable-object-program object))
    (canvas-apply-trans-scale-matrix canvas (drawable-object-program object))
    (canvas-apply-x-rot-matrix canvas (drawable-object-program object))
    (canvas-apply-y-rot-matrix canvas (drawable-object-program object))
    (canvas-apply-z-rot-matrix canvas (drawable-object-program object))
    (gl:bind-buffer :array-buffer (canvas-vao canvas))
    (dotimes (i (length points))
      (setf (gl:glaref arr i) (nth i points)))
    (gl:buffer-data :array-buffer :static-draw arr)
    (gl:free-gl-array arr)
    (gl:enable-vertex-attrib-array 0)
    (gl:vertex-attrib-pointer 0 4 :int nil 0 0)
    (gl:draw-arrays (drawable-object-primitive object) 0 (/ (length points) 4))
    (gl:disable-vertex-attrib-array 0)
    (gl:bind-buffer :array-buffer 0)
    (gl:use-program 0)))

(defun canvas-draw-objects (canvas)
  (loop for obj in (canvas-objects canvas) do
    (canvas-draw-object canvas (car obj))))

(defun canvas-init-buffer (canvas)
  (let ((vao (first (gl:gen-vertex-arrays 1)))
	(buff (first (gl:gen-buffers 1)))
	(arr (gl:make-null-gl-array :float)))
    (gl:bind-vertex-array vao)
    (gl:bind-buffer :array-buffer buff)
    (gl:buffer-data :array-buffer :static-draw arr)
    (gl:free-gl-array arr)
    (gl:bind-buffer :array-buffer 0)
    (setf (canvas-vao canvas) vao)))

(defun canvas-init-shaders (canvas)
  (loop with default-vertex-path = (directory "./src/shaders/*.vert")
	with default-fragment-path = (directory "./src/shaders/*.frag")
	with vertex = nil
	with fragment = nil
	with geom = nil
	with program = nil
	with name = nil
	for dir in (directory "./src/shaders/*") do
	  (setq program (gl:create-program))
	  (setq vertex (load-shader-from-file (car default-vertex-path) :vertex-shader))
	  (if (directory (merge-pathnames dir "*.frag"))
	      (setq fragment (load-shader-from-file (car (directory (merge-pathnames dir "*.frag"))) :fragment-shader))
	      (setq fragment (load-shader-from-file (car default-fragment-path) :fragment-shader)))
	  (setq geom (load-shader-from-file (car (directory (merge-pathnames dir "*.geom"))) :geometry-shader))
	  (setq name (car (last (pathname-directory dir))))
	  (gl:attach-shader program vertex)
	  (gl:attach-shader program fragment)
	  (gl:attach-shader program geom)
	  (gl:link-program program)
	  (gl:detach-shader program vertex)
	  (gl:delete-shader vertex)
	  (gl:detach-shader program fragment)
	  (gl:delete-shader fragment)
	  (gl:detach-shader program geom)
	  (gl:delete-shader geom)
	  (setf (canvas-programs canvas)
		(acons (intern (string-upcase name) "KEYWORD") program
		       (canvas-programs canvas)))))

(defun canvas-init ()
  (let* ((init
	   (lambda (area)
	     (gl-area-make-current area)
	     (canvas-init-buffer *canvas*)
	     (canvas-init-shaders *canvas*)))
	 (resize
	   (lambda (area width height)
	     (declare (ignore area))
	     (setf (canvas-size *canvas*) (list width height))
	     (canvas-set-ortho-matrix *canvas* 0 width 0 height 0 1000)
	     (gl:viewport 0 0 width height)))
	 (render
	   (lambda (area context)
	     (declare (ignore area context))
	     (gl:enable :blend)
	     (gl:blend-func :src-alpha :one-minus-src-alpha)
	     (gl:clear-color 1 1 1 1)
	     (gl:clear :color-buffer-bit :depth-buffer-bit)
	     (when (canvas-objects *canvas*)
	       (canvas-draw-objects *canvas*))
	     (gl:flush)
	     (gl:disable :blend)))
	 (can (make-gl-area))
	 (click-controller (click-event-controller-init))
	 (move-controller (move-event-controller-init)))
    (connect can "realize" init)
    (connect can "resize" resize)
    (connect can "render" render)
    (widget-add-controller can (e-controller-widget click-controller))
    (widget-add-controller can (e-controller-widget move-controller))
    (make-canvas :widget can
		 :event-controllers `(,click-controller ,move-controller)
		 :trans-scale-matrix (canvas-init-trans-scale-matrix)
		 :x-rot-matrix (canvas-init-x-rot-matrix)
		 :y-rot-matrix (canvas-init-y-rot-matrix)
		 :z-rot-matrix (canvas-init-z-rot-matrix))))

(defun canvas-connect-callback (canvas type callback)
  (cond
    ((eql type 'pressed)
     (event-controller-connect-callback (first (canvas-event-controllers canvas)) callback type))
    ((eql type 'motion)
     (event-controller-connect-callback (second (canvas-event-controllers canvas)) callback type))))

(defun canvas-disconnect-callback (canvas type)
  (cond
    ((eql type 'pressed)
     (event-controller-disconnect-callback (first (canvas-event-controllers canvas))))
    ((eql type 'motion)
     (event-controller-disconnect-callback (second (canvas-event-controllers canvas))))))

(defun canvas-add-object (canvas object &optional temp)
  (push `(,object ,temp) (canvas-objects canvas)))

(defun canvas-remove-last-object (canvas &optional temp)
  (when (or (not temp) (second (car (canvas-objects canvas))))
    (setf (canvas-objects canvas) (cdr (canvas-objects canvas)))))

(defun canvas-remove-all-objects (canvas)
  (setf (canvas-objects canvas) nil))

(defun canvas-add-point (canvas point)
  (push (truncate (first point)) (canvas-reading-buffer canvas))
  (push (- (widget-height (canvas-widget canvas)) (truncate (second point))) (canvas-reading-buffer canvas))
  (push (third point) (canvas-reading-buffer canvas))
  (push (fourth point) (canvas-reading-buffer canvas)))

(defun canvas-remove-last-point (canvas)
  (setf (canvas-reading-buffer canvas) (nthcdr 4 (canvas-reading-buffer canvas))))

(defun canvas-clear-points (canvas)
  (setf (canvas-reading-buffer canvas) nil))

(defun canvas-set-points (canvas points)
  (setf (canvas-reading-buffer canvas) points))

(defun canvas-set-ortho-matrix (canvas left right bottom top near far)
  (let* ((a11 (/ 2.0 (- right left)))
	 (a14 (- (/ (+ right left) (float (- right left)))))
	 (a22 (/ 2.0 (- top bottom)))
	 (a24 (- (/ (+ top bottom) (float (- top bottom)))))
	 (a33 (- (/ 2.0 (- far near))))
	 (a34 (- (/ (+ far near) (float (- far near)))))
	 (mat (vector (make-array 16 :adjustable nil
				     :initial-contents
				     `(,a11 0.0 0.0 ,a14
				       0.0 ,a22 0.0 ,a24
				       0.0 0.0 ,a33 ,a34
				       0.0 0.0 0.0 1.0)))))
    (setf (canvas-projection-matrix canvas) mat)))

(defun canvas-apply-projection-matrix (canvas program)
  (let ((location (gl:get-uniform-location program "projection")))
    (gl:uniform-matrix location 4 (canvas-projection-matrix canvas))))

(defun canvas-init-trans-scale-matrix ()
  (let ((mat (vector (make-array 16 :adjustable nil
				    :initial-contents
				    '(1.0 0.0 0.0 0.0
				      0.0 1.0 0.0 0.0
				      0.0 0.0 1.0 0.0
				      0.0 0.0 0.0 1.0)))))
    mat))

(defun canvas-apply-trans-scale-matrix (canvas program)
  (let ((location (gl:get-uniform-location program "trans_scale")))
    (gl:uniform-matrix location 4 (canvas-trans-scale-matrix canvas))))

(defun canvas-move-horizontal (canvas value)
  (let* ((mat (aref (canvas-trans-scale-matrix canvas) 0))
	 (el (aref mat 3)))
    (setf (aref mat 3) (+ el value))))

(defun canvas-move-vertical (canvas value)
  (let* ((mat (aref (canvas-trans-scale-matrix canvas) 0))
	 (el (aref mat 7)))
    (setf (aref mat 7) (+ el value))))

(defun canvas-zoom (canvas value)
  (let* ((mat (aref (canvas-trans-scale-matrix canvas) 0))
	 (el-x (aref mat 0))
	 (el-y (aref mat 5))
	 (el-z (aref mat 10)))
    (setf (aref mat 0) (max (+ el-x value) 0))
    (setf (aref mat 5) (max (+ el-y value) 0))
    (setf (aref mat 10) (max (+ el-z value) 0))))

(defun canvas-init-x-rot-matrix ()
  (let ((mat (vector (make-array 16 :adjustable nil
				    :initial-contents
				    '(1.0 0.0 0.0 0.0
				      0.0 1.0 0.0 0.0
				      0.0 0.0 1.0 0.0
				      0.0 0.0 0.0 1.0)))))
    mat))

(defun canvas-apply-x-rot-matrix (canvas program)
  (let ((location (gl:get-uniform-location program "x_rot")))
    (gl:uniform-matrix location 4 (canvas-x-rot-matrix canvas))))

(defun canvas-rot-x (canvas angle)
  (let* ((mat (aref (canvas-x-rot-matrix canvas) 0))
	 (s (sin angle))
	 (c (cos angle))
	 (old-s (aref mat 9))
	 (old-c (aref mat 5))
	 (new-s (+ (* old-s c) (* old-c s)))
	 (new-c (- (* old-c c) (* old-s s))))
    (setf (aref mat 5) new-c)
    (setf (aref mat 6) (- new-s))
    (setf (aref mat 9) new-s)
    (setf (aref mat 10) new-c)))

(defun canvas-init-y-rot-matrix ()
  (let ((mat (vector (make-array 16 :adjustable nil
				    :initial-contents
				    '(1.0 0.0 0.0 0.0
				      0.0 1.0 0.0 0.0
				      0.0 0.0 1.0 0.0
				      0.0 0.0 0.0 1.0)))))
    mat))

(defun canvas-apply-y-rot-matrix (canvas program)
  (let ((location (gl:get-uniform-location program "y_rot")))
    (gl:uniform-matrix location 4 (canvas-y-rot-matrix canvas))))

(defun canvas-rot-y (canvas angle)
  (let* ((mat (aref (canvas-y-rot-matrix canvas) 0))
	 (s (sin angle))
	 (c (cos angle))
	 (old-s (aref mat 2))
	 (old-c (aref mat 0))
	 (new-s (+ (* old-s c) (* old-c s)))
	 (new-c (- (* old-c c) (* old-s s))))
    (setf (aref mat 0) new-c)
    (setf (aref mat 2) new-s)
    (setf (aref mat 8) (- new-s))
    (setf (aref mat 10) new-c)))

(defun canvas-init-z-rot-matrix ()
  (let ((mat (vector (make-array 16 :adjustable nil
				    :initial-contents
				    '(1.0 0.0 0.0 0.0
				      0.0 1.0 0.0 0.0
				      0.0 0.0 1.0 0.0
				      0.0 0.0 0.0 1.0)))))
    mat))

(defun canvas-apply-z-rot-matrix (canvas program)
  (let ((location (gl:get-uniform-location program "z_rot")))
    (gl:uniform-matrix location 4 (canvas-z-rot-matrix canvas))))

(defun canvas-rot-z (canvas angle)
  (let* ((mat (aref (canvas-z-rot-matrix canvas) 0))
	 (s (sin angle))
	 (c (cos angle))
	 (old-s (aref mat 4))
	 (old-c (aref mat 0))
	 (new-s (+ (* old-s c) (* old-c s)))
	 (new-c (- (* old-c c) (* old-s s))))
    (setf (aref mat 0) new-c)
    (setf (aref mat 1) (- new-s))
    (setf (aref mat 4) new-s)
    (setf (aref mat 5) new-c)))
