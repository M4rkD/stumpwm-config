;;; xkb.lisp --- Wrapper for clx-xkeyboard library

;; Copyright © 2013–2016, 2019 Alex Kost <alezost@gmail.com>

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

;; This file uses xkeyboard extension
;; <https://github.com/filonenko-mikhail/clx-xkeyboard> (I installed it
;; with quicklisp to make it available in my config).  A big part of the
;; following code came from the stumpwm example of that extension.

;; This file provides some functions and commands for working with
;; layouts.  I use it for:
;;
;; - different key bindings for different layouts,
;; - different layouts for different windows,
;; - setting internal input method in emacs if it is the current window
;;   (by sending a specified key sequence to it) instead of the global
;;   layout switching.

;; Also I use clx-xkeyboard to control CapsLock, NumLock (to get their
;; values for the mode line and to change these values).

;;; Code:

(in-package :stumpwm)


;;; Mod locks (CapsLock, NumLock, etc.)

;; These constants were found experimentally (I didn't bother to find
;; the meaning of the higher bits).  I didn't find any mention of the
;; possible values of "ModLocks" in the XKeyboard Protocol Specification
;; <https://www.x.org/releases/current/doc/kbproto/xkbproto.html>.
;; So what is the source of these values (where are they hard-coded)?
(defconstant +shift-lock+ #b1)
(defconstant +caps-lock+  #b10)
(defconstant +ctrl-lock+  #b100)
(defconstant +alt-lock+   #b1000)
(defconstant +num-lock+   #b10000)
(defconstant +mod3-lock+  #b100000)     ; Hyper
(defconstant +mod4-lock+  #b1000000)    ; Super

(defun al/mod-lock-state (mod mods)
  "Return t if MOD lock is enabled in MODS bits.
Return nil otherwise."
  (not (zerop (logand mod mods))))

(defun al/set-mod-locks (mod-locks &optional affect-mod-locks)
  "Set key mod locks according to MOD-LOCKS bits.
If AFFECT-MOD-LOCKS is nil, use the value of MOD-LOCKS."
  (xlib:latch-lock-state
   *display*
   :mod-locks mod-locks
   :affect-mod-locks (or affect-mod-locks mod-locks)
   :lock-group nil
   :group-lock 0
   :mod-latches 0
   :affect-mod-latches 0
   :latch-group nil
   :group-latch 0)
  (xlib:display-finish-output *display*))

(defun al/toggle-mod-lock (mod-lock)
  "Toggle MOD-LOCK key."
  (if (al/mod-lock-state mod-lock
                         (xlib:device-state-locked-mods
                          (xlib:get-state *display*)))
      (al/set-mod-locks 0 mod-lock)
      (al/set-mod-locks mod-lock)))

(defcommand al/toggle-caps-lock () ()
  "Toggle CapsLock key."
  (al/toggle-mod-lock +caps-lock+))

;;; xkb.lisp ends here
