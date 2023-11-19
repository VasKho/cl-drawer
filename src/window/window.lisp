(in-package :cl-drawer)

(define-application (:name cl-drawer
                     :id "org.cl-drawer")
    (define-main-window (window (make-application-window :application *application*))
	(setf (window-title window) "cl-drawer")
      (setq *canvas* (canvas-init))
      (let ((css-provider (make-css-provider))
	    (win (make-paned :orientation +orientation-horizontal+))
	    (menu (menu-init)))
	(css-provider-load-from-path css-provider (namestring "style.css"))
	(style-context-add-provider-for-display (gdk:display-default) css-provider +style-provider-priority-user+)
	(setf (widget-name (menu-widget menu)) "menu-bar")
	(setf (paned-start-child win) (menu-widget menu))
	(setf (paned-end-child win) (canvas-widget *canvas*))
	(setf (paned-resize-start-child-p win) nil)
	(setf (paned-shrink-start-child-p win) nil)
	(setf (window-child window) win))
      (unless (widget-visible-p window)
	(window-present window))
      ;; (canvas-add-object *canvas*
      ;; 			 (make-drawable-object
      ;; 			  :points '(1 0 300 600 1 0 100 500)
      ;; 			  :program (cdr (assoc :hyperbola (canvas-programs *canvas*)))
      ;; 			  :primitive :lines))
      ))