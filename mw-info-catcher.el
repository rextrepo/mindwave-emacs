
;;; mindwave-emacs.org[*Org Src mindwave-emacs.org[ emacs-lisp ]*] --- Act when the EEG Power spectrum hits some kind of signature

;;; Commentary:
;; 

;;; Code:

(defcustom mw-info-catcher/standard-values
  '((highGamma   50000   1000  500)
    (lowGamma    50000   1000  500)
    (highBeta   100000   2000  1000)
    (lowBeta    100000   2000  1000)
    (highAlpha  100000   2000  1000)
    (lowAlpha   150000   2000  1000)
    (theta      300000   2000  1000)
    (delta     1000000   4000  2000))
  "A list of values to determine whether an important EEG event has happened.

The list is in the format of:
 ((highGamma highest median lowest)
  (lowGamma highest median lowest)
  (highBeta ....)
  ...)")

(defcustom mw-info-catcher/sensitivity 0.25
  "A float representing how sensitive the catcher is.  1 would mean every event matters."
  :type 'float)

(defcustom mw-info-catcher/ignore-signatures '((0 0 0 0 0 0 0 0))
  "A list of signatures that the info-catcher will ignore."
  :type 'list)

(defvar mw-info-catcher/current-signature '()
  "The current EEG signature")

(defun mw-info-catcher/mw-hook (brain)
  "Hook that handles the catching of information.
Argument BRAIN is a standard mindwave brain list."
  (let ((sig (mw-info-catcher/get-eegPower-signaure (cdr (assoc 'eegPower brain)))))
    (setq mw-info-catcher/current-signature sig)
    (when (not (member sig mw-info-catcher/ignore-signatures))
      (mw-info-catcher/prompt-for-catch sig))))

(defun mw-info-catcher/prompt-for-catch (sig)
  "Prompt the user for some information on what just happened.
Argument SIG is a simple list representing the signature."
  (message "Just got this: %s" sig))

(add-hook 'mindwave-hook 'mw-info-catcher/mw-hook)

(defun mw-info-catcher/get-eegPower-signaure (eeg-power)
  "Given a set of eeg inputs, return the signature for that set.
This uses the `mw-info-catcher/standard-values' and
`mw-info-catcher/sensitivity' variables to determine the signature.

It's probably easier to look at the math involved (check
`mw-info-catcher/gen-signature') then it would be to try to
describe this function.
Argument EEG-POWER is the incoming eegPower portion of the mindwave brain info."
  (mapcar #'mw-info-catcher/gen-signature eeg-power))

(defun mw-info-catcher/gen-signature (v)
  (let* ((band (car v))
         (value (+ 0.0 (cdr v)))
         (highest (second (assoc band mw-info-catcher/standard-values)))
         (median (third (assoc band mw-info-catcher/standard-values)))
         (lowest (fourth (assoc band mw-info-catcher/standard-values))))
    (cond ((>= value median)
           (min (floor (+ (/ (- value median)
                             (- highest median))
                          mw-info-catcher/sensitivity))
                2))
          ((< value median)
           (max (ceiling (* -1 (+ (/ (- value median)
                                     (- lowest median))
                                  mw-info-catcher/sensitivity)))
                -2)))))

(ert-deftest mw-info-catcher/check-eegPower-zero-values ()
  (let ((mw-info-catcher/standard-values '((test 11 6 1))))
    (should (= (mw-info-catcher/gen-signature '(test . 5))
               0))
    (should (= (mw-info-catcher/gen-signature '(test . 4))
               0))))

(ert-deftest mw-info-catcher/check-eegPower-negative-values ()
  (let ((mw-info-catcher/standard-values '((test 11 6 1)))
        (mw-info-catcher/sensitivity .75))
    (should (= (mw-info-catcher/gen-signature '(test . 3))
               -1))
    (should (= (mw-info-catcher/gen-signature '(test . 2))
               -1))
    (should (= (mw-info-catcher/gen-signature '(test . 1))
               -1))
    (should (= (mw-info-catcher/gen-signature '(test . -1))
               -2))))

(ert-deftest mw-info-catcher/check-eegPower-zero-values ()
  (let ((mw-info-catcher/standard-values '((test 11 6 1))))
    (should (= (mw-info-catcher/gen-signature '(test . 8))
               0))
    (should (= (mw-info-catcher/gen-signature '(test . 7))
               0))
    (should (= (mw-info-catcher/gen-signature '(test . 6))
               0))))

(ert-deftest mw-info-catcher/check-eegPower-positive-values ()
  (let ((mw-info-catcher/standard-values '((test 11 6 1)))
        (mw-info-catcher/sensitivity .5))
    (should (= (mw-info-catcher/gen-signature '(test . 9))
               1))
    (should (= (mw-info-catcher/gen-signature '(test . 10))
               1))
    (should (= (mw-info-catcher/gen-signature '(test . 11))
               1))
    (should (= (mw-info-catcher/gen-signature '(test . 15))
               2))
    (should (= (mw-info-catcher/gen-signature '(test . 35))
               2))))

(ert-deftest mw-info-catcher/larger-resolution-tests ()
  (let ((mw-info-catcher/standard-values '((test 100 50 0)))
        (mw-info-catcher/sensitivity .75))
    (should (= (mw-info-catcher/gen-signature '(test . 75))
               1))
    (should (= (mw-info-catcher/gen-signature '(test . 76))
               1))
    (should (= (mw-info-catcher/gen-signature '(test . 50))
               0))
    (should (= (mw-info-catcher/gen-signature '(test . 62))
               0))
    (should (= (mw-info-catcher/gen-signature '(test . 63))
               0))
    (should (= (mw-info-catcher/gen-signature '(test . 66))
               0))
    (should (= (mw-info-catcher/gen-signature '(test . 64))
               0))
    (should (= (mw-info-catcher/gen-signature '(test . 68))
               0))
    (should (= (mw-info-catcher/gen-signature '(test . 74))
               0))))

(provide 'mw-info-catcher)

;;; mw-info-catcher ends here
