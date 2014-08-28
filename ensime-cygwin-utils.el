;;; ensime-cygwin-utils.el
;;
;;;; License
;;
;;     Copyright (C) 2013 Andreas Kellers
;;
;;     This program is free software; you can redistribute it and/or
;;     modify it under the terms of the GNU General Public License as
;;     published by the Free Software Foundation; either version 2 of
;;     the License, or (at your option) any later version.
;;
;;     This program is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;;     GNU General Public License for more details.
;;
;;     You should have received a copy of the GNU General Public
;;     License along with this program; if not, write to the Free
;;     Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;;     MA 02111-1307, USA.

(require 'comint)

(defun ensime-cygwin-root-init ()
  "Get name of Windows root of current Cygwin installation.
Returns empty string if system is not Cygwin"
  (if (eq system-type 'cygwin)
      (let ((root (shell-command-to-string "cygpath -m /")))
	(substring root 0 (- (length root) 1)))
    ""))

(defvar ensime-cygwin-root (ensime-cygwin-root-init)
  "Name of the Windows root of the Cygwin installation
used to translate windows path to cygwin and vice versa.")

(defun ensime-cygwin-filename-to-win (s)
  "Convert Cygwin filename to Windows"
  (concat ensime-cygwin-root s))
 
(defun ensime-cygwin-filename-to-cyg (f)
  "Convert Windows filename to Cygwin"
  (substring f (length ensime-cygwin-root)))

(defun ensime-cygwin-filename-to-unix (f)
  "Convert Windows filename with backslash to Cygwin by replacing
backslashes with forward slashes and removing then Cygwin root."
  (ensime-cygwin-filename-to-cyg (mapconcat 'identity
				     (split-string f "\\\\") "/")))


(defun ensime-cygwin-convert-backslashes (s)
  "Convert double backslashes to single forward slashes."
  (replace-regexp-in-string "\\\\\\\\" "/" s))

(defun ensime-cygwin-convert-backslash (s)
  "Convert double backslashes to single forward slashes."
  (replace-regexp-in-string "\\\\" "/" s))

(defun ensime-cygwin-convert-cygwin (s)
  "Convert cygwin root value with empty string"
  (replace-regexp-in-string ensime-cygwin-root "" s))

(defun ensime-cygwin-convert (s)
  "Convert string using backslash and cygwin conversion"
  (ensime-cygwin-convert-cygwin 
   (ensime-cygwin-convert-backslash 
    (ensime-cygwin-convert-backslashes s))))

(defun ensime-cygwin-change-slashes (s)
  "Replace backward slashes with forward ones"
  (mapconcat 'identity (split-string s "\\\\") "/"))

(defun ensime-cygwin-remove-cygwin (s)
  "Replace Cygwin root in string"
  (mapconcat 'identity (split-string s ensime-cygwin-root) ""))


(provide 'ensime-cygwin-utils)
;;; ##########
