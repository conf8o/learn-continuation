#! /usr/local/bin/racket
#lang racket/base
(require racket/control)

; --- lib ---

; ```
; Initial -> Available
; Available -> Reserved
; Reserved -> Running
; Running -> Available
; Reserved -> Available
; Available -> Running
; ```
(define (valid-state-transition state new-state)
  (or (and (string=? state "Initial") (string=? new-state "Available"))
      (and (string=? state "Available") (string=? new-state "Reserved"))
      (and (string=? state "Reserved") (string=? new-state "Running"))
      (and (string=? state "Running") (string=? new-state "Available"))
      (and (string=? state "Reserved") (string=? new-state "Available"))
      (and (string=? state "Available") (string=? new-state "Running"))))

(define (update-state state new-state)
  (if (valid-state-transition state new-state)
      new-state
      "InvalidTransition"))

(define (is-error s) (string=? s "InvalidTransition"))

; --- main ---

(define state "Initial")

(define (handle-result result)
  (if (is-error result)
      (displayln (string-append "Error: " result))
      (begin
        (display (string-append "Trans from `" state "`"))
        (set! state result)
        (displayln (string-append " to `" state "`")))))

(define trans #f)

(define (initialize)
  (displayln "initialized.")
  (let [(result (let/cc continue
                  (set! trans continue)
                  (continue (update-state state "Available"))))]
    (handle-result result)
    (displayln "done")))

(initialize)
(trans "Reserved")
(trans "Running")
(trans "Available")
(trans "Available")
