(asdf:load-asd (merge-pathnames "cl-drawer.asd" (uiop:getcwd)))
(asdf:load-system :cl-drawer)

(cl-drawer:cl-drawer)
