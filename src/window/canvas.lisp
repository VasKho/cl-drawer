(in-package :cl-drawer)

(defstruct canvas
  widget
  event-controllers
  objects
  (programs nil :type list)
  vao
  (reading-buffer nil :type list)
  (projection-matrix #() :type vector)
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
	     (canvas-set-ortho-matrix *canvas* 0 width 0 height 0 1)
	     (gl:viewport 0 0 width height)))
	 (render
	   (lambda (area context)
	     (declare (ignore area context))
	     (gl:clear-color 1 1 1 1)
	     (gl:clear :color-buffer-bit)
	     (when (canvas-objects *canvas*)
	       (canvas-draw-objects *canvas*))
	     (gl:flush)))
	 (can (make-gl-area))
	 (click-controller (click-event-controller-init))
	 (move-controller (move-event-controller-init)))
    (connect can "realize" init)
    (connect can "resize" resize)
    (connect can "render" render)
    (widget-add-controller can (e-controller-widget click-controller))
    (widget-add-controller can (e-controller-widget move-controller))
    (make-canvas :widget can :event-controllers `(,click-controller ,move-controller))))

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

(defun canvas-add-point (canvas point)
  (push (truncate (first point)) (canvas-reading-buffer canvas))
  (push (- (widget-height (canvas-widget canvas)) (truncate (second point))) (canvas-reading-buffer canvas))
  (push (third point) (canvas-reading-buffer canvas))
  (push (fourth point) (canvas-reading-buffer canvas)))

(defun canvas-remove-last-point (canvas)
  (setf (canvas-reading-buffer canvas) (nthcdr 2 (canvas-reading-buffer canvas))))

(defun canvas-clear-points (canvas)
  (setf (canvas-reading-buffer canvas) nil))

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
