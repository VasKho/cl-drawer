(defpackage #:cl-drawer
  (:use :gtk4 :cl)
  (:shadow #:viewport
	   #:major-version
	   #:minor-version
	   #:list-base
	   #:scale)
  (:nicknames #:drawer)
  (:export
   #:cl-drawer))

(in-package :cl-drawer)
(defvar *canvas* nil)
(defvar *key-manager* nil)
