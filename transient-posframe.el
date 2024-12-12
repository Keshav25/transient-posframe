;;; transient-posframe.el --- Using posframe to show transient  -*- lexical-binding: t -*-

;; Copyright (C) 2020 Yanghao Xie

;; Author: Yanghao Xie
;; Maintainer: Yanghao Xie <yhaoxie@gmail.com>
;; URL: https://github.com/yanghaoxie/transient-posframe
;; Version: 0.1.0
;; Keywords: convenience, bindings, tooltip
;; Package-Requires: ((emacs "26.0")(posframe "1.4.4")(transient "0.7.9"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Display transient popups using a posframe.
;; Check out the README for more information.

;;; Code:
(require 'posframe)
(require 'transient)

(defgroup transient-posframe nil
  "Using posframe to show transient popups"
  :group 'transient
  :prefix "transient-posframe")

(defcustom transient-posframe-font nil
  "The font used by transient-posframe.
When nil, use current frame's font as fallback."
  :group 'transient-posframe
  :type '(choice string (const :tag "Use font of current frame")))

(defcustom transient-posframe-poshandler #'posframe-poshandler-frame-center
  "The poshandler of transient-posframe."
  :group 'transient-posframe
  :type 'function)

(defcustom transient-posframe-min-width 83
  "The minimal width of transient-posframe."
  :group 'transient-posframe
  :type '(choice number (const :tag "No minimum" nil)))

(defcustom transient-posframe-min-height nil
  "The minimal height of transient-posframe."
  :group 'transient-posframe
  :type '(choice number (const :tag "No minimum" nil)))

(defcustom transient-posframe-border-width 1
  "The border width used by transient-posframe.
When 0, no border is showed."
  :group 'transient-posframe
  :type 'number)

(defcustom transient-posframe-parameters nil
  "The frame parameters used by transient-posframe."
  :group 'transient-posframe
  :type '(alist :key-type symbol :value-type sexp))

(defface transient-posframe
  '((t (:inherit default)))
  "Face used by the transient-posframe."
  :group 'transient-posframe)

(defface transient-posframe-border
  '((t (:inherit default :background "gray50")))
  "Face used by the transient-posframe's border."
  :group 'transient-posframe)

(defvar transient-posframe-display-buffer-action--previous nil
  "The previous value of `transient-display-buffer-action'.")

(defun transient-posframe--show-buffer (buffer _alist)
  "Show BUFFER in posframe and we do not use _ALIST at this period."
  (when (posframe-workable-p)
    (posframe-show
     buffer
     :font transient-posframe-font
     :position (point)
     :poshandler transient-posframe-poshandler
     :background-color (face-attribute 'transient-posframe :background nil t)
     :foreground-color (face-attribute 'transient-posframe :foreground nil t)
     :initialize #'transient-posframe--initialize
     :min-width transient-posframe-min-width
     :min-height transient-posframe-min-height
     :internal-border-width transient-posframe-border-width
     :internal-border-color (face-attribute 'transient-posframe-border
					    :background nil t)
     :override-parameters transient-posframe-parameters)))

(defun transient-posframe--initialize ()
  "Initialize transient posframe."
  (setq window-resize-pixelwise t)
  (setq window-size-fixed nil))

(defun transient-posframe--resize (window)
  "Resize transient posframe."
  (fit-frame-to-buffer-1 (window-frame window)
                         nil transient-posframe-min-height
                         nil transient-posframe-min-width))

(defun transient-posframe--delete ()
  "Delete transient posframe."
  (posframe-delete-frame transient--buffer-name)
  (posframe--kill-buffer transient--buffer-name))

;;;###autoload
(define-minor-mode transient-posframe-mode
  "Toggle transient posframe mode on of off."
  :group 'transient-posframe
  :global t
  :lighter nil
  (cond
   (transient-posframe-mode
    (setq transient-posframe-display-buffer-action--previous
	  transient-display-buffer-action)
    (setq transient-display-buffer-action
	  '(transient-posframe--show-buffer))
    (advice-add 'transient--delete-window :override
		#'transient-posframe--delete)
    (advice-add 'transient--fit-window-to-buffer :override
		#'transient-posframe--resize))
   (t
    (setq transient-display-buffer-action
	  transient-posframe-display-buffer-action--previous)
    (advice-remove 'transient--delete-window
		   #'transient-posframe--delete)
    (advice-remove 'transient--fit-window-to-buffer
		   #'transient-posframe--resize))))

(provide 'transient-posframe)

;; Local Variables:
;; coding: utf-8-unix
;; indent-tabs-mode: t
;; End:

;;; transient-posframe.el ends here
