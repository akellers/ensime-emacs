;;; ensime-semantic-highlight.el
;;
;;;; License
;;
;;     Copyright (C) 2010 Aemon Cannon
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


(defun ensime-sem-high-apply-properties (info)
  "Use provided info to modify font-lock properties of identifiers
 in the program text."
  (let ((file (plist-get info :file))
	(syms (plist-get info :syms)))
    (when-let (buf (find-buffer-visiting (ensime-cygwin-to-cyg file)))
	      (with-current-buffer buf
		(dolist (sym (ensime-sem-high-internalize-syms syms))
		  (let* ((type (nth 0 sym))
			 (start (nth 1 sym))
			 (end (nth 2 sym))
			 (face (cdr (assoc type ensime-sem-high-faces))))
		    (let ((ov (make-overlay start end buf)))
		      (overlay-put ov 'face face)
		      (overlay-put ov 'ensime-sem-high-overlay t)
		      (overlay-put ov 'ensime-sym-type type))))))))

(defun ensime-sem-high-internalize-syms (syms)
  (if (eq 1 (coding-system-eol-type buffer-file-coding-system))
      (let ((sorted-syms (sort (copy-sequence syms)
                               (lambda (a b) (< (nth 1 a) (nth 1 b)))))
            (offset-lines (ensime-external-offsets-to-lines)))
        (mapcar
         (lambda (sym)
           (let* ((start-offset (nth 1 sym))
                  (end-offset (nth 2 sym))
                  (offset-lines-for-start
                   (ensime-get-line-for-external-offset offset-lines start-offset))
                  (start-line (or (cdar offset-lines-for-start) 1))
                  (start-line-end-offset (or (caar offset-lines-for-start) 1))
                  (offset-lines-for-end
                   (ensime-get-line-for-external-offset offset-lines-for-start end-offset))
                  (end-line (or (cdar offset-lines-for-end) 1))
                  (end-line-end-offset (or (caar offset-lines-for-end) 1)))
             (setf offset-lines offset-lines-for-start)
             (list* (nth 0 sym)
                    (ensime-internalize-offset-at-line start-offset start-line-end-offset start-line)
                    (ensime-internalize-offset-at-line end-offset end-line-end-offset end-line)
                    (nthcdr 3 sym))))
         sorted-syms))
    (mapcar (lambda (sym)
              (list* (nth 0 sym)
                     (+ (nth 1 sym) ensime-ch-fix)
                     (+ (nth 2 sym) ensime-ch-fix)
                     (nthcdr 3 sym)))
            syms)))

(defun ensime-sem-high-clear-buffer ()
  (ensime-sem-high-clear-region 0 (point-max)))

(defun ensime-sem-high-clear-region (beg end)
  (let ((ovs (overlays-in beg end)))
    (dolist (ov ovs)
      (when (overlay-get ov 'ensime-sem-high-overlay)
	(delete-overlay ov)))))

(defun ensime-sem-high-refresh-hook ()
  "Update semantic highlighting for the current buffer.
 For big buffers, update visible region first."
  (interactive)
  (let ((visible-size (- (window-end) (window-start)))
	(total-size (point-max)))
    (when (> total-size (* 5 visible-size))
      (ensime-sem-high-refresh-region (window-start) (window-end)))
    (ensime-sem-high-refresh-region (point-min) (point-max))))


(defun ensime-sem-high-refresh-buffer (&optional buffer)
  "Refresh semantic highlighting for the entire buffer."
  (interactive)
  (with-current-buffer (or buffer (current-buffer))
    (ensime-sem-high-refresh-region (point-min) (point-max))))

(defun ensime-sem-high-refresh-all-buffers ()
  (interactive)
  (let ((conn (ensime-current-connection)))
    (let ((bufs (ensime-connection-visiting-buffers conn)))
      (dolist (buf bufs)
	(ensime-sem-high-refresh-buffer buf)))))

(defun ensime-sem-high-refresh-region (beg end)
  "Refresh semantic highlighting for the given region."
  (when ensime-sem-high-enabled-p
    (ensime-rpc-symbol-designations
     buffer-file-name (ensime-externalize-offset beg) (ensime-externalize-offset end)
     (mapcar 'car ensime-sem-high-faces)
     `(lambda (info)
        (ensime-sem-high-clear-region ,beg ,end)
        (ensime-sem-high-apply-properties info)
        (ensime-event-sig :region-sem-highlighted nil)))))

(defun ensime-sem-high-inspect-highlight ()
  (interactive)
  (let ((ovs (overlays-at (point))))
    (message "%S" (mapcar
		   (lambda (ov)
		     (format "%S %S %S"
			     (overlay-get ov 'face)
			     (overlay-get ov 'ensime-sem-high-overlay)
			     (overlay-get ov 'ensime-sym-type)))
		   ovs))))

(defun ensime-sem-high-sym-types-at-point ()
  (interactive)
  (let ((ovs (overlays-at (point))))
    (mapcar
     (lambda (ov)
       (overlay-get ov 'ensime-sym-type))
     ovs)))


(provide 'ensime-semantic-highlight)

;; Local Variables:
;; no-byte-compile: t
;; End:

