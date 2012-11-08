
;;; mindwave-attendor.el --- Hassle the user when the mindwave attention level reaches a lower threshold

;; Copyright (C) 2012 Jonathan Arkell

;; Author: Jonathan Arkell <jonnay@jonnay.net>
;; Created: 16 June 2012
;; Keywords: mindwave
;; Version 0.1 

;; This file is not part of GNU Emacs.
;; Released under the GPL     

;;; Commentary: 
;; Please see the org-file that this was generated from. 
(defgroup mw-attendor '()
  "Mindwave Attendor.")

(defcustom mw-attendor/alert-user-hooks '()
  "Hooks to run when the users attention level crosses a certain threshold."
  :type hook)

(defcustom mw-attendor/attention-threshold 40
  "Threshold value for attention.
When the users attention level falls below this level, run the hooks ")

(defun mw-attendor/brain-ring-full-hook (avg)
  "hook to run the attentive hooks when the threshold values are received."
  (when (< mw-attendor/attention-threshold
           (cdr (assoc 'attention (cdr (assoc 'eSense average)))))
    (run-hooks mw-attendor/wait-til-ready-hook)))

(provide 'mindwave-attendor)
