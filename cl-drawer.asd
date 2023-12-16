(defsystem cl-drawer
  :description "A simple drawing app."
  :version "0.1.0"
  :author "vaslch0"
  :license "GPLv3"
  :depends-on (#:cl-gdk4 #:cl-gtk4 #:cl-opengl)
  :components
  ((:module "src"
    :serial t
    :components
    ((:file "package")
     (:file "utils/shader")
     (:file "window/drawable-object")
     (:file "window/event-controller")
     (:file "utils/shortcuts")
     (:file "window/canvas")
     (:file "window/button")
     (:file "menu-buttons/pointer")
     (:file "menu-buttons/line")
     (:file "menu-buttons/line2")
     (:file "menu-buttons/curves")
     (:file "menu-buttons/polygon")
     (:file "menu-buttons/clear")
     (:file "window/menu")
     (:file "window/window")))))
