;;; ivy-pos.el --- Record position marker with ivy

;;
;; Author: fe11x <andyrat@qq.com>
;; URL: https://github.com/fe11x/ivy-pos
;; Package-Requires: ((emacs "24") (ivy "0.10.0"))
;; Version: 0.0.1
;; Keywords: convenience

;; Copyright (C) 2018 Michał Krzywkowski

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This package allows you to select position markers using ivy completion.
;;
;;

(defvar point-pos-stack (list))
(setq point-pos-stack '())
(defvar ivy-pos--buffer nil)

(defun ivy-pos--save ()
  "Save current point position in history."
  (interactive)
  (let* ((cur-pos (point-marker))
		 (pos-num (marker-position cur-pos))
		 (line-num (line-number-at-pos))
		 (line-content (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
		 (key (concat buffer-file-truename ":" (number-to-string line-num) ":" line-content)))
	(push (cons key cur-pos) point-pos-stack)
	(message "Current point position has been saved.")))

(defun ivy-pos--delete-pos (candidate)
  (let ((key1 (car candidate))
		(key2 (ivy-state-current ivy-last)))
	(setq point-pos-stack (delq (assoc key2 point-pos-stack) point-pos-stack))))

(defun ivy-pos--killall (candidate)
  (setq point-pos-stack (list)))

(defun ivy-pos--update-fn ()
  (let* ((candidate (ivy-state-current ivy-last))
		 (pos (nth 1 (assoc candidate point-pos-stack)))
		 (buffer (marker-buffer pos)))
	(when pos
	  (with-current-buffer ivy-pos--buffer
		(switch-to-buffer buffer)
		(goto-char (marker-position pos))))))

(defun ivy-pos ()
  (interactive)
  (setq ivy-pos--buffer (current-buffer))
  (let ((selection nil))
	(ivy-read "Choose a pos: " point-pos-stack
										;:update-fn #'ivy-pos--update-fn
			  :action '(1
						("g" (lambda (candidate) (setq selection candidate)) "goto")
						("d" ivy-pos--delete-pos "delete")
						("k" ivy-pos--killall "kill all pos"))
						 
			  )
	(when selection
	  (let* ((pos (nth 1 selection))
			 (buffer (marker-buffer pos)))
		(switch-to-buffer buffer)
		(goto-char (marker-position pos))))))

;;; ivy-pos.el ends here


(defun ivy-pos--search ()
  "Save current point position in history."
  (interactive)
  (let* ((cur-pos (point-marker))
		 (pos-num (marker-position cur-pos))
		 (line-num (line-number-at-pos))
		 (line-content (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
		 (key (concat buffer-file-truename ":" (number-to-string line-num) ":" line-content)))
	(swiper-isearch (thing-at-point 'symbol))
	(push (cons key cur-pos) point-pos-stack)
	(message "Current point position has been saved.")))

(global-set-key (kbd "C-s") 'ivy-pos--search)
; C-c C-s very strong
