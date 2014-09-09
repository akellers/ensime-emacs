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
Returns empty string if `system-type' does  not equal 'cygwin"
  (if (eq system-type 'cygwin)
      (substring (shell-command-to-string "cygpath --mixed /")
		 0 -1)
    ""))

(defvar ensime-cygwin-root (ensime-cygwin-root-init)
  "Name of the Windows root of the Cygwin installation
used to translate windows path to cygwin and vice versa.")

(defun ensime-cygwin-replace-backslashes (s)
  "Replace double backslash or single backslashes to single
forward slashes in string s."
  (replace-regexp-in-string 
   "\\\\" "/" (replace-regexp-in-string "\\\\\\\\" "/" s)))

(defun ensime-cygwin-replace-cygwin-root (s)
  "Replace `ensime-cygwin-root' with empty string in s."
  (replace-regexp-in-string ensime-cygwin-root "" s))

(defun ensime-cygwin-to-win (f)
  "Convert Cygwin filename to Windows by prepending
`ensime-cygwin-root' to the true filename."
  (concat ensime-cygwin-root (file-truename f)))
 
(defun ensime-cygwin-to-cyg (s)
  "Convert string using backslash and Cygwin conversion. Windows
filenames will be converted to Cygwin ones (if under the same
root)."
  (ensime-cygwin-replace-cygwin-root
   (ensime-cygwin-replace-backslashes s)))

(provide 'ensime-cygwin-utils)
;;; ##########
