;;; init.lisp --- Vital settings and loading other files

;; Copyright © 2013–2016, 2018–2019 Alex Kost <alezost@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file should be symlinked by "~/.stumpwmrc".

;;; Code:

(in-package :stumpwm)


;;; Start swank server
(require :swank)
(swank-loader:init
 :delete nil         ; delete any existing SWANK packages
 :reload nil         ; reload SWANK, even if the SWANK package already exists
 :load-contribs nil) ; load all contribs

(swank:create-server :port 4004
                       :style swank:*communication-style*
                       :dont-close t)


;;; Current display number

(defvar al/display-number
  (multiple-value-bind (_ array)
      (cl-ppcre:scan-to-strings ":([0-9]+)" (getenv "DISPLAY"))
    (declare (ignore _))
    (if (vectorp array)
        (parse-integer (aref array 0))
        0))
  "The number of the current DISPLAY.")


;;; Loading additional rc files

(defvar al/init-directory
  (directory-namestring
   (truename (merge-pathnames (user-homedir-pathname)
                              ".stumpwmrc")))
  "A directory with initially loaded files.")

(defun al/load (filename)
  "Load a file FILENAME (without extension) from `al/init-directory'."
  (let ((file (merge-pathnames (concat filename ".lisp")
                               al/init-directory)))
    (if (probe-file file)
        (load file)
        (format *error-output* "File '~a' doesn't exist." file))))

(defun al/load-module (name)
  "Load contributed stumpwm module NAME.
Return nil, if the module does not exist.
This function is similar to `load-module' command, except it returns nil
instead of any error."
  (let ((module (find-module (string-downcase name))))
    (and module
         (progn (asdf:operate 'asdf:load-op module)
                t))))

(redirect-all-output (merge-pathnames "log" al/init-directory))

(set-module-dir
 (pathname-as-directory (concat (getenv "HOME")
                                "/.stumpwm-config/stumpwm-contrib")))

(al/load "keys")
(al/load "utils")
(al/load "sound")
(al/load "settings")
(al/load "visual")

;;; init.lisp ends here


;; toggle the mode line with  (stumpwm:mode-line) or command mode-line
