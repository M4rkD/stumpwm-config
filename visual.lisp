;;; visual.lisp --- Visual appearance: colors, fonts, mode line, ...

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

;;; Code:

(in-package :stumpwm)


;;; Colors

;; Yellow and magenta are swapped to show keys in yellow.
(setf *colors*
      '("black"                 ; 0
        "red"                   ; 1
        "green"                 ; 2
        "magenta"               ; 3
        "#44d0ff"               ; 4
        "yellow"                ; 5
        "cyan"                  ; 6
        "white"                 ; 7
        "AntiqueWhite3"
        "khaki3")
      *bar-hi-color* "^B^5*")
(update-color-map (current-screen))

(defmacro al/set-color (val color)
  "Similar to `set-any-color', but without updating colors."
  `(dolist (s *screen-list*)
     (setf (,val s) (alloc-color s ,color))))

(al/set-color screen-fg-color (hex-to-xlib-color "#e5e8ef"))
(al/set-color screen-bg-color "gray15")
(al/set-color screen-focus-color "DeepSkyBlue")
(al/set-color screen-border-color "ForestGreen")
(al/set-color screen-float-focus-color "DeepSkyBlue")
(al/set-color screen-float-unfocus-color "gray15")
(update-colors-all-screens)


;;; Grabbed pointer

(setq
 *grab-pointer-character* 40
 *grab-pointer-character-mask* 41
 *grab-pointer-foreground* (hex-to-xlib-color "#3db270")
 *grab-pointer-background* (hex-to-xlib-color "#2c53ca"))


;;; Wallpaper

(defvar *background-image-path* "/home/mark/Pictures/wallpapers/")

(defun select-random-background-image ()
  "Select a random image"
  (let ((file-list (directory (concatenate 'string *background-image-path* "*.png")))
        (*random-state* (make-random-state t)))
    (namestring (nth (random (length file-list)) file-list))))

(run-shell-command (concatenate 'string "display -window root " (select-random-background-image)))


;;; Mouse

;; set the mouse to be a left pointer (rather than an x)
(run-shell-command "xsetroot -cursor_name left_ptr")


;;; Load mode-line modules

(load-module "battery-portable")
(load-module "cpu")
(load-module "net")
(load-module "wifi")


;;; Visual appearance and mode-line settings

(defvar ml-separator " | ")

(setf
 *window-info-format*
 (format nil "^>^B^5*%c ^b^6*%w^7*x^6*%h^7*~%%t")

 *time-format-string-default*
 (format nil "^5*%H:%M:%S~%^2*%A~%^7*%d %B")

 *time-modeline-string* "%a %d %b |%k:%M"

 *mode-line-timeout* 3

 *mode-line-position* :bottom

 *screen-mode-line-format*
 '(
   ;; " ^[^2*%n^]"                 ; group name
   "%B" ;; Show state of batteries
   ml-separator
   "%C"
   ml-separator
   "%l"
   ml-separator
   "%I"
   ml-separator
   "^>"
   "^[^5*%d^]"
))

(mode-line)

;;; visual.lisp ends here
