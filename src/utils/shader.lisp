(in-package :cl-drawer)

(defun create-shader (shader-source shader-type)
  (let ((shader (gl:create-shader shader-type)))
    (when (eq shader-type :vertex-shader)
      (gl:shader-source shader shader-source))
    (when (eq shader-type :fragment-shader)
      (gl:shader-source shader shader-source))
    (when (eq shader-type :geometry-shader)
      (gl:shader-source shader shader-source))
    (gl:compile-shader shader)
    (return-from create-shader shader)))

(defun load-shader-from-file (path shader-type)
  (with-open-file (instream path :direction :input :if-does-not-exist nil)
    (when instream 
      (let ((string (make-string (file-length instream))))
        (read-sequence string instream)
        (create-shader string shader-type)))))
