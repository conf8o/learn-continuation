#! /usr/local/bin/racket
#lang racket/base

; --- lib ---

; ```
; Available -> Reserved
; Reserved -> Running
; Running -> Available
; Reserved -> Available
; Available -> Running
; ```
(define (valid-state-transition state new-state)
  (or (and (string=? state "Available") (string=? new-state "Reserved"))
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

(define state #f)

(define (app)
  (update-state state "Availdable"))


; --- middleware 的な ---

(define (handle-result result)
  (if (is-error result)
      (displayln (string-append "Error: " result))
      (begin
        (set! state result)
        (displayln state))))

(define (initialize)
  (set! state "Running"))

(handle-result
  (call/cc
    (lambda (k)
      (displayln "前処理")
      (initialize)
      (k (app))
      (displayln "(k (app)) でcall/ccの場所に戻るので、呼び出されないはず"))))
