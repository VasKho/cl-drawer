(in-package :cl-drawer)

(define-application (:name cl-drawer
                     :id "org.cl-drawer")
    (define-main-window (window (make-application-window :application *application*))
	(setf (window-title window) "cl-drawer")
      (setq *canvas* (canvas-init))
      (setq *key-manager* (key-manager-init))
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
      (widget-add-controller window (e-controller-widget (key-manager-controller *key-manager*)))
      (add-shortcut *key-manager* 43 (canvas-move-horizontal *canvas* -4.0) (gl-area-queue-render (canvas-widget *canvas*)));;h
      (add-shortcut *key-manager* 44 (canvas-move-vertical *canvas* -4.0) (gl-area-queue-render (canvas-widget *canvas*)));;j
      (add-shortcut *key-manager* 45 (canvas-move-vertical *canvas* 4.0) (gl-area-queue-render (canvas-widget *canvas*)));;k
      (add-shortcut *key-manager* 46 (canvas-move-horizontal *canvas* 4.0) (gl-area-queue-render (canvas-widget *canvas*)));;l
      (add-shortcut *key-manager* 20 (canvas-zoom *canvas* -0.01) (gl-area-queue-render (canvas-widget *canvas*)));;-
      (add-shortcut *key-manager* 21 (canvas-zoom *canvas* 0.01) (gl-area-queue-render (canvas-widget *canvas*)));;+
      (add-shortcut *key-manager* 24 (canvas-rot-z *canvas* 0.01) (gl-area-queue-render (canvas-widget *canvas*)));;q
      (add-shortcut *key-manager* 26 (canvas-rot-z *canvas* -0.01) (gl-area-queue-render (canvas-widget *canvas*)));;e
      (add-shortcut *key-manager* 25 (canvas-rot-x *canvas* 0.01) (gl-area-queue-render (canvas-widget *canvas*)));;w
      (add-shortcut *key-manager* 39 (canvas-rot-x *canvas* -0.01) (gl-area-queue-render (canvas-widget *canvas*)));;s
      (add-shortcut *key-manager* 38 (canvas-rot-y *canvas* -0.01) (gl-area-queue-render (canvas-widget *canvas*)));;a
      (add-shortcut *key-manager* 40 (canvas-rot-y *canvas* 0.01) (gl-area-queue-render (canvas-widget *canvas*)));;d
      (unless (widget-visible-p window)
	(window-present window))))
