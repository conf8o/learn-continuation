#! /usr/local/bin/racket
#lang racket/base
(require racket/control racket/match racket/string)

; --- lib ---

; ```
; Preparing -> Available
; Preparing -> Reserved
; Available -> Preparing
; Available -> Reserved
; Available -> Running
; Reserved -> Preparing
; Reserved -> Available
; Reserved -> Running
; Running -> Preparing
; ```
(define (valid-state-transition state new-state)
  (match (list state new-state)
    [(list "Preparing" "Available") #t]
    [(list "Preparing" "Reserved") #t]
    [(list "Available" "Preparing") #t]
    [(list "Available" "Reserved") #t]
    [(list "Available" "Running") #t]
    [(list "Reserved" "Preparing") #t]
    [(list "Reserved" "Available") #t]
    [(list "Reserved" "Running") #t]
    [(list "Running" "Preparing") #t]
    [_ #f]))

(define (update-state state new-state)
  (if (valid-state-transition state new-state)
      new-state
      "InvalidTransition"))

(define (is-error s) (string=? s "InvalidTransition"))

; --- main ---

(define state "Preparing")
(define error-state #f)

(define (handle-state! result)
  (if (is-error result)
      (set! error-state result)
      (set! state result)))

(define (log . messages)
  (displayln (string-join (cons "[log]" messages))))

; 保存するやつ
(define update-state! #f)
(define (initialize)
  (reset
    (let ([requested-state (shift update
                             (set! update-state! update)
                             (update "Available"))])
      (log "request:" state "->" requested-state)

      (handle-state! (update-state state requested-state))

      (if error-state
          (log "error on update state:" error-state)
          (log "updated:" requested-state)))))

; 早期リターン
(define (app)
  (let/cc return

    (initialize)
    (when error-state (return error-state))

    (update-state! "Reserved")
    (when error-state (return error-state))

    (update-state! "Running")
    (when error-state (return error-state))

    (update-state! "Preparing")
    (when error-state (return error-state))

    (return "Done")))

(let ([app-result (app)])
  (if (is-error app-result)
      (log "error on app: " app-result)
      (log app-result)))
